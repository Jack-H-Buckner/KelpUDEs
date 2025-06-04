#####################################
## Training routine for kelp models
#####################################

function training!(model, regularization_weight, proces_errors; maxiter_1 = 500, maxiter_2 = 250)

    UniversalDiffEq.train!(model, loss_function = "derivative matching", 
         optim_options = (maxiter = maxiter_1, step_size = 0.05), verbose = true,
         loss_options = (d = 25,),regularization_weight = regularization_weight)

    UniversalDiffEq.train!(model, loss_function = "derivative matching", 
         optim_options = (maxiter = maxiter_2, step_size = 0.01), verbose = true,
         loss_options = (d = 25,),regularization_weight = regularization_weight)

end 