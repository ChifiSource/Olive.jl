
mutable struct OliveExtension
    # bar, file, style
    name::String
    type::Symbol
    component::AbstractComponent
end

abstract type CellType end

mutable struct OliveCore <: ServerExtension
    pages::Vector{AbstractRoute}
    type::Symbol
    sessions::Dict{String, Pair{Vector{Cell}, String}}
    celltypes::Vector{CellType}
    extensions::Vector{OliveExtension}
    users::Dict{String, Vector{Servable}}
    function OliveCore()
        pages = ["login" => div("login")]
    end
end
