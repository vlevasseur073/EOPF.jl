module LSTProcessor


function slstr_common(inputs::Vector{Pair{String,Dict}},args::Dict{String,Any})#::YAXArrays.Dataset

end
function lst_processor(inputs::Vector{Pair{String,Dict}},args::Dict{String,Any})#::YAXArrays.Dataset
    @info "Starting LST Processor"
    for (path,input) in inputs
        @info "Input ", path
    end

    @info args
    common = slstr_common(inputs,args)


end
end #end of module