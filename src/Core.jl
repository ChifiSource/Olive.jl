
mutable struct OliveExtension
    name::String
    # bar, file, style
    type::Symbol
    component::AbstractComponent
end

mutable struct CellType
    name::String
    evaluator::Function
    color::String
    writer::Function
    function CellType(name::String, evaluator::Function,
        writer::Function;
        color::String = "#FFFFFF")
        new(name, evaluator, color, writer, reader)
    end
end

function revise_evaluator(s::String)
    return(p(text = s, color = "pink"))
end

function mdconverter(s::String)
    tmd("celltmd", s)
end

const OliveInputCell = CellType("input", revise_evaluator, IPy.create_code)

const OliveMarkdownCell = CellType("markdown", mdconverter, IPy.create_markdown)

mutable struct OliveCore <: ServerExtension
    pages::Vector{Pair{String, Function}}
    type::Symbol
    sessions::Dict{String, Pair{Vector{Cell}, String}}
    celltypes::Vector{CellType}
    extensions::Vector{OliveExtension}
    users::Dict{String, Vector{Servable}}
    function OliveCore()
        pages = ["session" => main, "home" => fourofour]
        sessions = Dict{String, Pair{Vector{Cell}, String}}()
        celltypes = [OliveInputCell, OliveMarkdownCell]
        users = Dict{String, Vector{Servable}}()
        new(pages, :connection, sessions, celltypes, extensions, users)
    end
end

function evaluate(c::Connection, cell::Cell)

end
