#########################################################
### Function for initializing a UDE model that 
### uses a nurla network to capture denisty dependent
### effect on growth and the effect of coavariats X. 
### Covariates can also be modeled with linear coeficents β 
### recruitment from other patches is modeld with inverse 
### distance weighting
#########################################################
function inv_squared_distance(d,α) 
    return α^0.5 * exp.(-α*d.^2 ) 
end 

function inv_distance(d,α) 
    return α * exp.(-α*d) 
end 


function init_model(dat,X,nn_inputs,linear_inputs;hidden = 10)

    n_inputs = length(nn_inputs)
    n_linear = length(linear_inputs)
    println(n_linear)
    NN, NNparams = SimpleNeuralNetwork(n_inputs,1,hidden = hidden)
    
    function dudt(du,u,X,p,t)

        inputs = vcat(u,X)
        du[1] = NN(inputs[nn_inputs],p.NN)[1]+ sum(p.β .* inputs[linear_inputs]) + p.FE

        return du
    end

    if n_linear == 0

        function dudt2(du,u,X,p,t)

            inputs = vcat(u,X)
            du[1] = NN(inputs[nn_inputs],p.NN)[1] + p.FE
    
            return du
        end  
        
        init_params = (NN=NNparams,  FE = 0.0)


        model = CustomDerivatives(dat,X,dudt2,init_params, time_column_name = "year",
                                value_column_name = "value", variable_column_name = "variable")
        return model, NN
    end 

    init_params = (NN=NNparams, β  = zeros(n_linear),  FE = 0.0)


    model = CustomDerivatives(dat,X,dudt,init_params, time_column_name = "year",
                                value_column_name = "value", variable_column_name = "variable")

    return model, NN

end

# Avoid inplace operations for derivative matching 
function init_null_model(dat,N)

    function dudt(u,p,t)
        return zeros(N)
    end

    init_params = (r=0,)
    
    model = CustomDerivatives(dat,dudt,init_params,time_column_name = "year")

    return model, N

end