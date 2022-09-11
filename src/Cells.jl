#==
    CELLS
    This file implements `build` and `evaluate` for Olive.jl. Creating the base
    :code cell. These can still be overwritten with future methods and imports !
    Which is awesome, by the way. Anyway, cells are sprung into existence via
    a file cell. For example, we would implement a toml reader into Cells by
    creating a toml category and a toml section cell and then making a simple name.
    Below then is the infastructure to surround the cells, cell pages etc.
==#

function unhighlight(x::String)
    replace(x, "<pre class=\"hljl\">" => "", "</pre>" => "",
    "</span>" => "",
    "<span class=\"hljl-k\">" => "", "<span class=\"hljl-p\">" => "",
    "<span class=\"hljl-t\">" => "", "<span class=\"hljl-cs\">" => "",
    "<span class=\"hljl-oB\">" => "", "<span class=\"hljl-nf\">" => "",
    "<span class=\"hljl-n\">" => "", "<span class=\"hljl-s\">" => "",
    "<span class=\"hljl-ni\">" => "", "<b>" => "", "</b>" => "",
    "<font color=\"#ff0000\">" => "", "</font>" => "", "<div>" => "\n",
    "</div>" => "", "<font color=\"#e45e9d\">" => "",
    "<font color=\"#e45e9d\" face=\"monospace\"><span style=\"white-space: pre;\">" => "")
end

function build(c::Connection, cell::Cell{:code})
    outside = div(class = cell)
    inside = div("cell$(cell.n)", class = "input_cell", text = cell.source,
     contenteditable = true, lastpos = 1)
     style!(inside, "text-color" => "white !important")
     b = IOBuffer()
     highlight(b, MIME"text/html"(), cell.source,
      Highlights.Lexers.JuliaLexer)
     inside_cover = section("cellcover$(cell.n)", text = String(b.data))
     on(c, inside, "focus") do cm::ComponentModifier
         cm["olivemain"] = "cell" => string(cell.n)
     end
     on(c, inside, "keyup") do cm::ComponentModifier
         rawcode = cm["cell$(cell.n)"]["text"]
         if length(rawcode) == 0
             return
         end
#==         b = IOBuffer()
         highlight(b, MIME"text/html"(), replace(rawcode, "</br>" => "\n"),
          Highlights.Lexers.JuliaLexer)
         set_text!(cm, "cellcover$(cell.n)", String(b.data)) ==#
     end
    number = h("cell", 1, text = cell.n, class = "cell_number")
    output = divider("cell$(cell.n)" * "out", class = "output_cell", text = cell.outputs)
    push!(outside, inside, output)
    outside
end

function build(c::Connection, cell::Cell{:markdown})
    tlcell = div("cell$(cell.n)", class = "cell")
    innercell = tmd("cell$(cell.n)tmd", cell.source)
    on(c, tlcell, "dblclick") do cm::ComponentModifier
        set_text!(cm, tlcell, replace(cell.source, "\n" => "</br>"))
        cm["olivemain"] = "cell" => string(cell.n)
        cm[tlcell] = "contenteditable" => "true"
    end
    tlcell[:children] = [innercell]
    tlcell
end


function build(c::Connection, cell::Cell{:ipynb})
    filecell = div("cell$(cell.n)", class = "cell-ipynb")
    on(c, filecell, "click") do cm::ComponentModifier
        cm["olivemain"] = "cell" => string(cell.n)
    end
    fname = a("$(cell.source)", text = cell.source)
    style!(fname, "color" => "white", "font-size" => 15pt)
    push!(filecell, fname)
    filecell
end

function build(c::Connection, cell::Cell{<:Any})
    hiddencell = div("cell$(cell.n)", class = "cell-hidden")
    name = a("cell$(cell.n)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cell::Cell{:jl})
    hiddencell = div("cell$(cell.n)", class = "cell-jl")
    on(c, hiddencell, "click") do cm::ComponentModifier
        cm["olivemain"] = "cell" => string(cell.n)
    end
    name = a("cell$(cell.n)label", text = cell.source)
    style!(name, "color" => "white")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cell::Cell{:toml})
    hiddencell = div("cell$(cell.n)", class = "cell-toml")
    name = a("cell$(cell.n)label", text = cell.source)
    style!(name, "color" => "white")
    push!(hiddencell, name)
    hiddencell
end

function cellcontainer(c::Connection, name::String)
    divider(name)
end

"""this would be a great function to contribute to right now, or change the
build function to create the feign textbox!"""
function evaluate(c::Connection, cell::Cell{:code}, cm::ComponentModifier)
    rawcode = unhighlight(cm["cell$(cell.n)"]["text"])
    execcode = replace(rawcode, "\n" => ";", "</br>" => ";",
    "\n" => ";", "\n        " => ";")
    cell.source = rawcode
    key = cm["olive-token"]["text"]
    fname = cm["olivemain"]["fname"]
#    print(execcode)
    sinfo = c[:OliveCore].sessions[key].open[fname]
    ret = ""
    i = IOBuffer()
    try
        #== if we sent `i` through this function, maybe we could observe output?
         for example, if someone adds a package; we could have the percentage
          of the package adding? We also need to start parsing the execcode
             and observing c's permissions.
         actually, with the implementation of the using cell, we will just
           check for using and always make the evaluation of that cell
             multi-threaded. ==#

        ret = sinfo[1].evalin(Meta.parse(execcode))
    catch e
        throw(e)
        ret = e
    end
    if isnothing(ret)
        # spawn load-bar observer?
        ret = "loading"
    end
    b = IOBuffer()
    highlight(b, MIME"text/html"(), rawcode, Highlights.Lexers.JuliaLexer)
    out = replace(String(b.data), "\n" => "", "        " => "\n        ",
    "end" => "\nend")
    set_text!(cm, "cell$(cell.n)", out)
    od = OliveDisplay()
    display( od,MIME"nothing"(), ret)
    set_text!(cm, "cell$(cell.n)out", String(od.io.data))
end

function evaluate(c::Connection, cell::Cell{:markdown}, cm::ComponentModifier)
    activemd = replace(cm["cell$(cell.n)"]["text"], "<div>" => "\n")
    cell.source = activemd
    newtmd = tmd("cell$(cell.n)tmd", activemd)
    set_children!(cm, "cell$(cell.n)", [newtmd])
    cm["cell$(cell.n)"] = "contenteditable" => "false"
end

function evaluate(c::Connection, cell::Cell{<:Any}, cm::ComponentModifier)

end

function evaluate(c::Connection, cell::Cell{:ipynb}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_ipynb(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function evaluate(c::Connection, cell::Cell{:jl}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_jl(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function load_session(c::Connection, cs::Vector{Cell{<:Any}},
    cm::ComponentModifier, fname::String, fpath::String)
    session = OliveSession()
    key = ToolipsSession.gen_ref()
    modstr = """module Examp
    function evalin(ex::Any)
            eval(ex)
    end
end"""

    mod = eval(Meta.parse(modstr))
    push!(session.open, fname => mod => cs)
    push!(c[:OliveCore].sessions, key => session)
    redirect!(cm, "/session?key=$key")
end

mutable struct CellGroup{T} <: Servable
    cells::Vector{Cell{<:Any}}
    f::Function
    n::Int64
    function CellGroup(type::String, n::Int64, cells::Vector{Cell{<:Any}})
        f(c::Connection) = write!(c,
        [build(c, cell) for cell in cells]::Vector{Servable})
        new{Symbol(type)}(cells, f, n)::Servable
    end
end

function build(cg::CellGroup{:file}, label::String)
    lbl = h2("cellgroup$label-path", text = crllgroup)
    container = div("cellgroup$label")
end

mutable struct Explorer <: Servable
    token::Component{:token}
    groups::Vector{CellGroup{:file}}
    f::Function
    active::Int64
    data::Dict{Symbol, Any}
    function Explorer(v::Vector{CellGroup})
        f(c::Connection)
    end
end

mutable struct OliveSession <: Servable
    token::Component{:token}
    groups::Vector{CellGroup{<:Any}}
    f::Function
    active::Int64
    data::Dict{Symbol, Any}
    function OliveSession(v::Vector{CellGroup})

    end
end

function directory_cells(c::Connection, dir::String = pwd())
    routes = Toolips.route_from_dir(dir)
    notdirs = [routes[r] for r in findall(x -> ~(isdir(x)), routes)]
    [begin
    splitdir::Vector{SubString} = split(path, "/")
    fname::String = string(splitdir[length(splitdir)])
    fsplit = split(fname, ".")
    fending::String = ""
    if length(fsplit) > 1
        fending = string(fsplit[2])
    end
    Cell(e, fending, fname, path)
    end for (e, path) in enumerate(notdirs)]::AbstractVector
end
