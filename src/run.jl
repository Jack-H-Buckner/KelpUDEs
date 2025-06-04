###################################################
### Train and run cross validation for UDE models
### describing changes in kelp abundnace along the 
### central california coast, 
### Full model with spatial predictors
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
include("conditional.jl")

# Load and parse arguments 
model_name, nn_inputs, linear_inputs, regularization_weight, process_errors = ARGS
nn_inputs = parse_list(nn_inputs)
linear_inputs = parse_list(linear_inputs)
regularization_weight_ = parse(Float64,regularization_weight)
process_errors_ = parse(Float64,process_errors)


# Load kelp data 
dat = CSV.read("processed_data/dat_point2.csv",DataFrame)[:,2:end]

# Load temperature data 
X = CSV.read("processed_data/covars.csv",DataFrame)[:,2:end]

# load distances between patches 
dists = CSV.read("processed_data/dists_point2.csv",DataFrame)[:,2:end]
dists = Matrix(dists)

# Initialize UDE model 
model, nn = init_model(dat,X,dists,inv_squared_distance,nn_inputs,linear_inputs;hidden = 5)

# Train the model
training!(model,regularization_weight_, process_errors_)
save_parameters(model,string("results/parameters/",model_name,"_",process_errors,"_",regularization_weight,".jld"))


plot_state_estimates(model)
savefig(string("results/diagnostics/",model_name,"_",process_errors,"_",regularization_weight,"_states.png"))

plot_predictions(model)
savefig(string("results/diagnostics/",model_name,"_",process_errors,"_",regularization_weight,"_preds.png"))


# Run cross validation 
training_routine = model -> training!(model,regularization_weight_, process_errors_)
cv_dir = string("results/cv/",model_name,"_",process_errors,"_",regularization_weight,".csv")
leave_future_out(model,training_routine,15,path=cv_dir)