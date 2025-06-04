###################################################
### Train and run cross validation for UDE models
### describing changes in kelp abundnace along the 
### central california coast 
### Jack Buckner, Oregon State University, May 2025
###################################################
# Set up dependencies
import Pkg 
Pkg.activate(".")

# Load libraries
using DataFrames, Plots, CSV, UniversalDiffEq, JLD2

# Load required functions 
include("UDE.jl")
include("helpers.jl")

training,process_errors=ARGS[1]
process_errors_ = parse(Float64,process_errors)
include(string(training,".jl"))

# Load kelp data 
dat = CSV.read("processed_data/dat.csv",DataFrame)[:,2:18]

# Initialize UDE model 
model, nn = init_null_model(dat,16)
training!(model,0.0,process_errors_)

plot_state_estimates(model)
savefig(string("results/diagnostics/null_",training,"_",process_errors,"_states.png"))

plot_predictions(model)
savefig(string("results/diagnostics/null_",training,"_",process_errors,"_preds.png"))

# Train the model
save_parameters(model,string("results/parameters/null_",training,"_",process_errors,".jld"))

# Run cross validation 
training_routine = model -> training!(model,0.0, 0.05)
cv_dir = string("results/cv/null",training,"_",process_errors,".csv")
leave_future_out(model,training_routine,15,path=cv_dir)