
## Cell 1
using CSV, DataFrames, Plots
dat = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2.csv",DataFrame)[:,vcat([2],18:32)]
dat1 = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2.csv",DataFrame)[:,17]
dat2 = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2.csv",DataFrame)[:,33]
dat[:,2:end] .= log.(dat[:,2:end] .+ 1e-2)


# Cell 2
dat_K = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2_K.csv",DataFrame)[:,18:32]
K1 = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2_K.csv",DataFrame)[:,17]
K2 = CSV.read("processed_data/kelp_bins_50_500m_cenca_model_2_K.csv",DataFrame)[:,33]
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
X = CSV.read("processed_data/covars.csv",DataFrame)[:,:2:end]
include("UDE2.jl")
model, NN = init_model(dat,X,K,t -> mu(t,mu_t1),t -> mu(t,mu_t2),K1,K2,1,[2];hidden = 10)


function training!(model,reg_weight,obs_weight)
UniversalDiffEq.train!(model, loss_function = "spline gradient matching", regularization_weight = reg_weight, 
        optim_options = (maxiter = 1500, step_size = 0.025), loss_options = (σ = 0.05^2, τ = obs_weight^2, T = 160),
        verbose = false)
end


UniversalDiffEq.leave_future_out(model, x->training!(x,1e1,0.2), 10; 
                            path = string("results/cv/model2_1e1_0.2.csv"))

print("run 1")
UniversalDiffEq.leave_future_out(model, x->training!(x,1e5,0.2), 10; 
                            path = string("results/cv/model2_1e5_0.2.csv"))

print("run 2")
UniversalDiffEq.leave_future_out(model, x->training!(x,1e6,0.2), 10; 
                            path = string("results/cv/model2_1e6_0.2.csv"))

print("run 3")
UniversalDiffEq.leave_future_out(model, x->training!(x,1e7,0.2), 10; 
                            path = string("results/cv/model2_1e7_0.2.csv"))

print("run 4")                            
UniversalDiffEq.leave_future_out(model, x->training!(x,1e8,0.2), 10; 
                            path = string("results/cv/model2_1e8_0.2.csv"))

print("run 5")
UniversalDiffEq.leave_future_out(model, x->training!(x,1e9,0.2), 10; 
                            path = string("results/cv/model2_1e9_0.2.csv"))

