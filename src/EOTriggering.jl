module EOTriggering

using TOML
using YAXArrays
# using ..EOProduct

PayloadTag = [
    "workflow",
    "I/O",
    "breakpoints",
    "logging"
]

struct Payload
    workflow
    io_config
    breakpoints
    logging
end

function dummy_processing_unit(inputs::Vector{Pair{String,Dict}},args::Dict{String,Any})#::YAXArrays.Dataset
    @info "Hello !"
    var1=YAXArray(rand(2,2))
    return YAXArrays.Dataset(var1)
end

function parse_payload_file(file::String)
    TOML.tryparsefile(file)    
end

function processor_run(fn::Function,inputs::Vector{Pair{String,Dict}},args::Dict{String,Any})::YAXArrays.Dataset
    @info "processor_run",args
    return fn(inputs,args)
end

function run(file::String)
    payload = parse_payload_file(file)

    if !reduce(&,map(x->haskey(payload,x),PayloadTag))
        msg = """Invalid payload file $(file)
              File must contain the following tag $(PayloadTag)"""
        throw(ErrorException(msg))
    end

    io = payload["I/O"]
    inputs = Dict{String,Pair{String,Dict}}()
    for item in io["inputs_products"]
        product = item["path"]
        @info product
        input_dict = eoproduct_dataset(product)
        inputs[item["id"]] = Pair(product,input_dict)
    end
    @info "List of inputs: "
    for (id,p) in inputs
        @info id,p.first
    end
    
    workflow = payload["workflow"]
    for pu in workflow
        workflow_inputs = [inputs[id] for id in pu["inputs"] if id in keys(inputs)]
        #TODO
        #Add intermediate inputs from previous PU output. 
        #Input is referenced with the name of the previous PU
        # push!(workflow,output[pu["inputs"]
        name = pu["name"]
        mod = pu["module"]
        process = pu["processing_unit"]
        params = pu["parameters"]
        # println(params)
        try
            m = getfield(Main,Symbol(mod))
            fn = getfield(m,Symbol(process))
            if isa(fn,Function)
                @info "Running $(name)($(mod).$(process))"
                processor_run(fn,workflow_inputs,params)
                # return fn()
            else
                @error "processing_unit requested in workflow is not a Function $(pu)"
                # throw(TypeError)
            end
        catch e
            if isa(e,UndefVarError)
                @error "Unknown function requested in workflow $(pu)"
                throw(UndefVarError)
            end
        end


    end
end

end # module EOTriggering
