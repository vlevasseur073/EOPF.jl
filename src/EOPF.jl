module EOPF

include("EOProducts.jl")
include("LSTProcessor.jl")
include("EOTriggering.jl")

using Reexport: @reexport

@reexport using .EOProducts
@reexport using .EOTriggering
@reexport using .LSTProcessor

# export EOProduct, EOTriggering, LSTProcessor
# export EOProduct:eoproduct_dataset
end # module EOPF
