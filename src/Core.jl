
mutable struct OliveExtension
    name::String
    # bar, file, style
    type::Symbol
    component::AbstractComponent
end

mutable struct CellType{N}
    name::String
    CellType(name::String) = new{Symbol(name)}(name)
end

function olivein(c::CellType{:input}, c::Cell)

end

function evaluate(c::CellType{:input}, c::Cell)

end

function write(c::CellType{:input}, c::Cell)

end

function evaluate(c::CellType{:md}, c::Cell)

end

mutable struct OliveCore <: ServerExtension
    pages::Vector{AbstractRoute}
    type::Symbol
    sessions::Dict{String, Pair{Vector{Cell}, String}}
    celltypes::Vector{CellType}
    extensions::Vector{OliveExtension}
    users::Dict{String, Vector{Servable}}
    function OliveCore()
        pages = [main, fourofour]
        sessions = Dict{String, Pair{Vector{Cell}, String}}()
        celltypes = [OliveInputCell, OliveMarkdownCell]
        users = Dict{String, Vector{Servable}}()
        extensions = Vector{OliveExtension}()
        new(pages, :connection, sessions, celltypes, extensions, users)
    end
end

function evaluate(c::Connection, cell::Cell)

end
