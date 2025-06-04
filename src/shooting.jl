#####################################
## Training routine for kelp models
#####################################

function training!(model, regularization_weight, proces_errors; maxiter_1 = 100, maxiter_2 = 50)

    UniversalDiffEq.train!(model, loss_function = "shooting", 
         optim_options = (maxiter = maxiter_1, step_size = 0.05), verbose = true,
         loss_options = (d = 25,),regularization_weight = regularization_weight)

    UniversalDiffEq.train!(model, loss_function = "shooting", 
         optim_options = (maxiter = maxiter_2, step_size = 0.01), verbose = true,
         loss_options = (d = 25,),regularization_weight = regularization_weight)

end 