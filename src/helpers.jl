using JLD2

function load_parameters!(model,path)
    pars = load_object(path) 
    model.parameters .= pars
end 

function save_parameters(model,path)
    save_object(path, Vector(model.parameters ) )
end 


function parse_list(str::String)
    # Remove brackets and split by comma
    str = replace(str, r"\[|\]" => "") 
    elements = split(str, ",")
    
    # Convert elements to numbers (or other types as needed)
    if elements == [""]
        return []
    end 
    return parse.(Int, elements)
end
