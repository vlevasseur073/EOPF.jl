module LSTProcessor

import ..EOProducts: EOProduct

function slstr_common(inputs::Vector{EOProduct},args::Dict{String,Any})#::YAXArrays.Dataset

end
function lst_processor(inputs::Vector{EOProduct},args::Dict{String,Any})#::YAXArrays.Dataset
    @info "Starting LST Processor"
    # for p in inputs
    #     @info "Input ", p
    # end

    @info args
    common = slstr_common(inputs,args)


end
end #end of module