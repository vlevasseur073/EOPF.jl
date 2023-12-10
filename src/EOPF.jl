module EOPF

include("EOProduct.jl")
include("LSTProcessor.jl")
include("EOTriggering.jl")

export EOProduct, EOTriggering, LSTProcessor
# export EOProduct:eoproduct_dataset
end # module EOPF
