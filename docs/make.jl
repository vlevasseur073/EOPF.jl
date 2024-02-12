using Documenter
using EOPF

makedocs(
    sitename = "EOPF.jl",
    format = Documenter.HTML(),
    modules = [ EOPF ],
    # pages = [
    #     "Home" => "index.md"
    # ],
#    repo = Documenter.Remotes.GitHub("vlevasseur073", "EOPF.jl")

)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
