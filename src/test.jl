
function parse_list(str::String)
    # Remove brackets and split by comma
    str = replace(str, r"\[|\]" => "") 
    elements = split(str, ",")
    
    # Convert elements to numbers (or other types as needed)
    return parse.(Float64, elements)
end

if length(ARGS) > 0
    list_str = ARGS[1]
    my_list = parse_list(list_str)
    println("Received list 1: ", my_list)

    list_str = ARGS[2]
    my_list = parse_list(list_str)
    println("Received list 2: ", sum(my_list))
else
    println("No arguments provided.")
end