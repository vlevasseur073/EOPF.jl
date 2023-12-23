module EOTriggering

using TOML
using YAXArrays

import ..EOProducts: EOProduct

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

struct PayloadWorkflow
    mod::String
    processing_unit::String
    name::String
    inputs::Vector{String}
    function PayloadWorkflow(d::Dict)
        mod=d["module"]
        processing_unit=d["processing_unit"]
        name=d["name"]
        inputs=d["inputs"]
        new(mod,processing_unit,name,inputs)
    end
end

function dummy_processing_unit(inputs::Vector{EOProduct},args::Dict{String,Any})#::YAXArrays.Dataset
    @info "Hello !"
    var1=YAXArray(rand(2,2))
    return YAXArrays.Dataset(var1)
end

function parse_payload_file(file::String)
    TOML.tryparsefile(file)    
end

function processor_run(fn::Function,inputs::Vector{EOProduct},args::Dict{String,Any})::YAXArrays.Dataset
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
    inputs = Vector{EOProduct}()
    for item in io["inputs_products"]
        product = item["path"]
        name = item["id"]
        eo_product = EOProduct(name,product)
        push!(inputs,eo_product)
    end
    @info "List of inputs: "
    for p in inputs
        @info p.name,p.path
    end
    
    workflow = payload["workflow"]
    for w in workflow
        try
            PayloadWorkflow(w)
        catch e
            @error e
        end
    end
    @info workflow
    for pu in workflow
        workflow_inputs = [p for p in inputs if p.name in pu["inputs"]]
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
