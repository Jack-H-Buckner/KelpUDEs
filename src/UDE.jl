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


function init_model(dat,X,dist_mat,dist_weight,nn_inputs,linear_inputs;hidden = 10)

    n_sites = size(dist_mat)[1]
    n_inputs = length(nn_inputs)
    n_linear = length(linear_inputs)

    
    NN, NNparams = SimpleNeuralNetwork(n_inputs,1,hidden = hidden)

    
    function dudt(du,u,X,p,t)

        idw_matrix = dist_weight.(dist_mat, p.α) # 
        dispersal =  idw_matrix * exp.(u)

        inputs = 0
        for i in 1:n_sites
            inputs = vcat(u[i:i],X)
            du[i] = NN(inputs[nn_inputs],p.NN)[1]+ sum(p.β  .* inputs[linear_inputs]) + exp(p.r)*dispersal[i]/exp(u[i]) + p.FE[i]
        end
        return du
    end

    if n_linear == 0

        function dudt(du,u,X,p,t)

            idw_matrix = dist_weight.(dist_mat, p.α) # 
            dispersal =  idw_matrix * exp.(u)

            inputs = 0
            for i in 1:n_sites
                inputs = vcat(u[i:i],X)
                du[i] = NN(inputs[nn_inputs],p.NN)[1] + exp(p.r)*dispersal[i]/exp(u[i]) + p.FE[i]
            end
            return du
        end  


        init_params = (NN=NNparams, r = 0.2,  α = 1.0, FE = zeros(n_sites))


        model = CustomDerivatives(dat,X,dudt,init_params, time_column_name = "year",
                                value_column_name = "value", variable_column_name = "variable")
        return model, NN
    end 


    init_params = (NN=NNparams,r = 0.2, β  = zeros(n_linear), α = 1.0, FE = zeros(n_sites))


    model = CustomDerivatives(dat,X,dudt,init_params,time_column_name = "year",
                                value_column_name = "value", variable_column_name = "variable")

    return model, NN

end


# Avoid inplace operations for derivative matching 
function init_model_matching(dat,X,dist_mat,dist_weight,nn_inputs,linear_inputs;hidden = 10)

    n_sites = size(dist_mat)[1]
    n_inputs = length(nn_inputs)
    n_linear = length(linear_inputs)
    
    NN, NNparams = SimpleNeuralNetwork(n_inputs,1,hidden = hidden)

    if n_linear < 1
        print("here")
        function dudt(u,X,p,t)

            idw_matrix = dist_weight.(dist_mat, p.α) # 
            dispersal =  idw_matrix * exp.(u)
            du = []
            for i in 1:n_sites
                inputs = vcat(u[i:i],X)
                du_i = NN(inputs[nn_inputs],p.NN)[1] + exp(p.r)*dispersal[i]/exp(u[i]) + p.FE[i]
                du = vcat(du,du_i)  
            end
            return du
        end
        init_params = (NN=NNparams,r = 0.0, α = 1.0, FE = zeros(n_sites))

        model = CustomDerivatives(dat,X,dudt,init_params,time_column_name = "year")

        return model, NN
    end


    function dudt_2(u,X,p,t)

        idw_matrix = dist_weight.(dist_mat, p.α) # 
        dispersal =  idw_matrix * exp.(u)
        du = []
        for i in 1:n_sites
            inputs = vcat(u[i:i],X)
            du_i = NN(inputs[nn_inputs],p.NN)[1]+ sum(p.β  .* inputs[linear_inputs]) + exp(p.r)*dispersal[i]/exp(u[i]) + p.FE[i]
            du = vcat(du,du_i)  
        end

        return du
    end

    init_params = (NN=NNparams,r = 0.0, β  = zeros(n_linear), α = 1.0, FE = zeros(n_sites))


    
    model = CustomDerivatives(dat,X,dudt_2,init_params,time_column_name = "year")

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