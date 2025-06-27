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
function init_model(dat,X,K,mean_t1,mean_t2,K1,K2,padding,nn_inputs;hidden = 10)

    n_sites = size(dat[:,2:end])[2]
    n_inputs = length(nn_inputs)
    
    NN, NNparams = UniversalDiffEq.SimpleNeuralNetwork(2+2*padding+n_inputs,1,hidden = hidden)


    function dudt(u,X,p,t)

        du = []
        for i in 1:n_sites
            inputs = 0
            if i <= padding
                u_ = vcat(zeros(padding-i+1) .+ mean_t1(t),u[1:(i+padding)]) 
                K_ = vcat(zeros(padding-i+1) .+ K1, K[1:(i+padding)])
                inputs = vcat(u[i:i],u_.+log.(K_),X[nn_inputs])
            elseif (n_sites - i) <= padding
                u_ = vcat(u[(i-padding):end],zeros(padding - n_sites +i) .+ mean_t2(t)) 
                K_ = vcat(K[(i-padding):end],zeros(padding - n_sites +i) .+ K2)
                inputs = vcat(u[i:i],u_.+log.(K_),X[nn_inputs]) 
            else
                u_ = u[(i-padding):(i+padding)]
                K_ = K[(i-padding):(i+padding)]
                inputs = vcat(u[i:i],u_.+log.(K_),X[nn_inputs])
            end
            du_i = (NN(inputs,p.NN)[1].+ p.FE[i])*(1-exp(u[i])) 
            du = vcat(du,du_i)  
        end
        return du
    end

    init_params = (NN=NNparams,FE = zeros(n_sites).+1e-5)
    priors(parameters) = 10*sum(parameters.process_model.FE^2)
    model = UniversalDiffEq.CustomDerivatives(dat,X,dudt,init_params,priors,time_column_name = "year",variable_column_name = "variable", value_column_name = "value")

    return model, NN

end