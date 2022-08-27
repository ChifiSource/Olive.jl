
mutable struct OliveExtension
    name::String
    # bar, file, style
    type::Symbol
    component::AbstractComponent
end

mutable struct OliveCore <: ServerExtension
    pages::Vector{AbstractRoute}
    type::Symbol
    sessions::Dict{String, Pair{Vector{Cell}, String}}
    extensions::Vector{OliveExtension}
    users::Dict{String, Vector{Servable}}
    function OliveCore()
        pages = [main, fourofour]
        sessions = Dict{String, Pair{Vector{Cell}, String}}()
        users = Dict{String, Vector{Servable}}()
        extensions = Vector{OliveExtension}()
        new(pages, :connection, sessions, extensions, users)
    end
end

function evaluate(c::Connection, cell::Cell{:md}, cm::ComponentModifier)
    activemd = cm["cell$(cell.n)"]["text"]
    cell.source = activemd
    newtmd = tmd("cell$(cell.n)tmd", activemd)
    set_children!(cm, "cell$(cell.n)", [newtmd])
    cm["cell$(cell.n)"] = "contenteditable" => "false"
end
