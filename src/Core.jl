
mutable struct OliveExtension
    name::String
    # bar, file, style
    type::Symbol
    component::AbstractComponent
end

mutable struct CellType
    name::String
    cell::Function
    function CellType(name::String, evaluator::Function, cell::AbstsractComponent
        writer::Function)
        new(name, evaluator, cell, writer)
    end
end

function olivein(c::CellType, c::Cell)

end

function evaluate(c::CellType, c::Cell)

end

function write(c::CellType, c::Cell)

end

function mdevaluator(s::String)
    tmd("celltmd", s)
end

const OliveInputCell = CellType("input", revise_evaluator, IPy.create_code)

const OliveMarkdownCell = CellType("markdown", mdconverter, IPy.create_markdown)

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
