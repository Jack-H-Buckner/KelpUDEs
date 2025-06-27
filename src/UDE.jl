#########################################################
### Function for initializing a UDE model that 
### uses a nurla network to capture denisty dependent
### effect on growth and the effect of coavariats X. 
### Covariates can also be modeled with linear coeficents β 
### recruitment from other patches is modeld with inverse 
### distance weighting
#########################################################
include("/Users/johnbuckner/.julia/dev/UniversalDiffEq.jl/src/UniversalDiffEq.jl")
function inv_squared_distance(d,α) 
    return α^0.5 * exp.(-α*d.^2 ) 
end 

function inv_distance(d,α) 
    return α * exp.(-α*d) 
end 

function softplus(x)
    x/(1-exp(-x.+1e-10))
end

# Avoid inplace operations for derivative matching 
function init_model(dat,X,dist_mat,dist_weight,nn_inputs,linear_inputs;hidden = 10)

    n_sites = size(dist_mat)[1]
    n_inputs = length(nn_inputs)
    n_linear = length(linear_inputs)
    
    NN, NNparams = UniversalDiffEq.SimpleNeuralNetwork(n_inputs,1,hidden = hidden)

    if n_linear < 1
        function dudt(u,X,p,t)

            idw_matrix = dist_weight.(dist_mat, softplus(p.α)) # 
            dispersal =  idw_matrix * u
            du = []
            for i in 1:n_sites
                inputs = vcat(u[i:i],X)
                m = NN(inputs[nn_inputs],p.NN)[1] +p.FE[i]
                growth = softplus(p.r)*dispersal[i]
                du_i =  growth *(1-u[i])  - u[i]*softplus(m) #+ exp(p.r)*dispersal[i]/exp(u[i])
                du = vcat(du,du_i)  
            end
            return du
        end
        init_params = (NN=NNparams,r = 0.01, α = 1.0, FE = zeros(n_sites).+0.1)

        model = UniversalDiffEq.CustomDerivatives(dat,X,dudt,init_params,time_column_name = "year", 
                                        variable_column_name = "variable", value_column_name = "value")

        return model, NN
    end


    function dudt_2(u,X,p,t)

        idw_matrix = dist_weight.(dist_mat, softplus(p.α)) # 
        dispersal =  idw_matrix * u
        du = []
        for i in 1:n_sites
            inputs = vcat(u[i:i]./exp(p.K[i]),X)
            m = NN(inputs[nn_inputs],p.NN)[1] .+p.β .* inputs[linear_inputs] .+p.FE[i]
            growth = softplus(p.r)*dispersal[i]
            du_i =  growth *(1-u[i]/exp(p.K[i]))  - u[i]*softplus(m[1]) #+ exp(p.r)*dispersal[i]/exp(u[i]) + p.FE[i]
            du = vcat(du,du_i)  
        end

        return du
    end

    init_params = (NN=NNparams,r = 0.0, β  = zeros(n_linear), α = 1.0, FE = zeros(n_sites), K = zeros(n_sites))


    
    model = UniversalDiffEq.CustomDerivatives(dat,X,dudt_2,init_params,time_column_name = "year",variable_column_name = "variable", value_column_name = "value")

    return model, NN

end

