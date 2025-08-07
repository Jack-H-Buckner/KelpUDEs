
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



# Cell 5

include("UDE.jl")
model, NN =  init_null_model(dat)


function training!(model,reg_weight,proc_weight)
UniversalDiffEq.train!(model, loss_function = "spline gradient matching", regularization_weight = reg_weight, 
        optim_options = (maxiter = 200, step_size = 0.025), loss_options = (σ = 0.05, τ = proc_weight, T = 160),
        verbose = false)
end


# proc error = 0.2
UniversalDiffEq.leave_future_out(model, x->training!(x,1e1,0.2), 10; 
                            path = string("results/cv/null_0.2.csv"))



# proc error = 0.1
UniversalDiffEq.leave_future_out(model, x->training!(x,1e1,0.1), 10; 
                            path = string("results/cv/null_0.1.csv"))


# proc error = 0.05
UniversalDiffEq.leave_future_out(model, x->training!(x,1e1,0.05), 10; 
                            path = string("results/cv/null_0.05.csv"))


# proc error = 0.025
UniversalDiffEq.leave_future_out(model, x->training!(x,1e1,0.025), 10; 
                            path = string("results/cv/null_0.025.csv"))


