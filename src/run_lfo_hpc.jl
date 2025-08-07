proc_error,reg_weight = ARGS
proc_error_ = parse(Float64,proc_error)
reg_weight_ = parse(Float64,reg_weight)
## Cell 1
using CSV, DataFrames, Plots
dat = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2.csv",DataFrame)[:,vcat([2],20:30)]
dat1 = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2.csv",DataFrame)[:,19]
dat2 = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2.csv",DataFrame)[:,31]
dat[:,2:end] .= log.(dat[:,2:end] .+ 1e-2)


# Cell 2
dat_K = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2_K.csv",DataFrame)[:,20:30]
K1 = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2_K.csv",DataFrame)[:,19]
K2 = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2_K.csv",DataFrame)[:,31]
K = Matrix(dat_K)[1,:]


# Cell 3
using Statistics
mu_t1 = dat1
mu_t1 = vcat([mean(mu_t1)],mu_t1,[mean(mu_t1)])
years = vcat([1500],dat.year, [2500])

mu_t2 = dat2
mu_t2 = vcat([mean(mu_t2)],mu_t2,[mean(mu_t2)])
years = vcat([1500],dat.year, [2500])

function mu(t,mu_t)
    ind_lower = maximum(eachindex(years)[years .<= t])
    ind_upper = minimum(eachindex(years)[years .> t])
    t_lower = years[ind_lower]
    t_upper = years[ind_upper]
    mu_lower = mu_t[ind_lower]
    mu_upper = mu_t[ind_upper]

    mu = mu_lower + (t-t_lower)/(t_upper-t_lower)*(mu_upper-mu_lower)
    return mu
end 
tvals = 1983:0.25:2025
Plots.plot(tvals, broadcast(t ->mu(t,mu_t1), tvals), linewidth = 3)
Plots.plot!(tvals, broadcast(t ->mu(t,mu_t2), tvals), linewidth = 3)


# Cell 5
X = CSV.read("processed_data/sst_500m_bins.csv",DataFrame)[:,:2:end]
unique(X.variable)
X = X[broadcast(v -> v in names(dat),X.variable),: ]
print(X[1:4,:])
include("UDE.jl")
model, NN = init_model(dat,X,K,t -> mu(t,mu_t1),t -> mu(t,mu_t2),K1,K2,1,;hidden = 10)


function training!(model,reg_weight,proc_weight)
UniversalDiffEq.train!(model, loss_function = "spline gradient matching", regularization_weight = reg_weight, 
        optim_options = (maxiter = 750, step_size = 0.025), loss_options = (σ = 0.05, τ = proc_weight, T = 160),
        verbose = false)
end


# run cross validation
UniversalDiffEq.leave_future_out(model, x->training!(x,reg_weight_,proc_error_), 10; 
                            path = string(string("results/cv/lfo",proc_error,"_",reg_weight,".csv")))

