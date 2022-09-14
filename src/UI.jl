#==
Default
    Styles
==#
function cell_in()
    cellin = Animation("cell_in", length = 1.5)
    cellin[:from] = "opacity" => "0%"
    cellin[:from] = "transform" => "translateY(100%)"
    cellin[:to] = "opacity" => "100%"
    cellin[:to] = "transform" =>  "translateY(0%)"
    cellin
end

function usingcell_style()
    st::Style = Style("div.usingcell", border = "0px solid gray", padding = "40px",
    "border-radius" => 5px, "background-color" => "#CCCCFF")
    animate!(st, cell_in()); st::Style
end

function cell_style()
    st::Style = Style("div.cell", "border-color" => "gray", padding = "20px",
    "background-color" => "white")
    st:"focus":["border-width" => 2px]
    animate!(st, cell_in())
    st::Style
end

hdeps_style() = Style("h1.deps", color = "white")

google_icons() = link("google-icons",
href = "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200",
rel = "stylesheet")

function iconstyle()
    s = Style(".material-symbols-outlined", cursor = "pointer",
    "font-size" => "100pt", "transition" => ".4s")
    s:"hover":["color" => "orange", "transform" => "scale(1.1)"]
    s
end

function hidden_style()
    Style("div.cell-hidden",
    "background-color" => "gray",
     "width" => 75percent, "overflow-x" => "hidden",
    "padding" => 4px, "transition" => "0.5s")::Style
end

function julia_style()
    hljl_nf::Style = Style("span.hljl-nf", "color" => "#2B80FA")
    hljl_oB::Style = Style("span.hljl-oB", "color" => "purple", "font-weight" => "bold")
    hljl_n::Style = Style("span.hljl-ts", "color" => "orange")
    hljl_cs::Style = Style("span.hljl-cs", "color" => "gray")
    hljl_k::Style = Style("span.hljl-k", "color" => "#E45E9D", "font-weight" => "bold")
    hljl_s::Style = Style("span.hljl-s", "color" => "#3FBA41")
    styles::Component{:sheet} = Component("codestyles", "sheet")
    push!(styles, hljl_k, hljl_nf, hljl_oB, hljl_n, hljl_cs, hljl_s)
    styles::Component{:sheet}
end

function olivesheet()
    st = ToolipsDefaults.sheet("olivestyle", dark = false)
    bdy = Style("body", "background-color" => "white")
    push!(st, google_icons(),
    cell_in(), iconstyle(), cellnumber_style(), hdeps_style(),
    usingcell_style(), outputcell_style(), inputcell_style(), bdy, ipy_style(),
    hidden_style(), jl_style(), toml_style())
    st
end

function olivesheetdark()
    st = ToolipsDefaults.sheet("olivestyle", dark = true)
    bdy = Style("body", "background-color" => "#360C1F", "transition" => ".8s")
    st[:children]["div"]["background-color"] = "#DB3080"
    st[:children]["div"]["color"] = "white"
    st[:children]["p"]["color"] = "white"
    st[:children]["h1"]["color"] = "orange"
    st[:children]["h2"]["color"] = "lightblue"
    ipc = inputcell_style()
    ipc["background-color"] = "#DABCDF"
    ipc["border-width"] = 0px
    push!(st, google_icons(),
    cell_in(), iconstyle(), cellnumber_style(), hdeps_style(),
    usingcell_style(), outputcell_style(), ipc, bdy, ipy_style(),
    hidden_style(), jl_style(), toml_style())
    st
end

function projectexplorer()
    pexplore = divider("projectexplorer")
    style!(pexplore, "background" => "transparent", "position" => "fixed",
    "z-index" => "1", "top" => "0", "overflow-x" => "hidden",
     "padding-top" => "30px", "width" => "0", "height" => "100%", "left" => "0",
     "transition" => "0.8s")
    pexplore
end

function explorer_icon(c::Connection)
    explorericon = topbar_icon("explorerico", "drive_file_move_rtl")
    on(c, explorericon, "click") do cm::ComponentModifier
        if cm["olivemain"]["ex"] == "0"
            style!(cm, "projectexplorer", "width" => "250px")
            style!(cm, "olivemain", "margin-left" => "250px")
            style!(cm, explorericon, "color" => "lightblue")
            set_text!(cm, explorericon, "folder_open")
            cm["olivemain"] = "ex" => "1"
        else
            style!(cm, "projectexplorer", "width" => "0px")
            style!(cm, "olivemain", "margin-left" => "0px")
            set_text!(cm, explorericon, "drive_file_move_rtl")
            style!(cm, explorericon, "color" => "black")
            cm["olivemain"] = "ex" => "0"
        end
    end
    explorericon::Component{:span}
end

function dark_mode(c::Connection)
    darkicon = topbar_icon("darkico", "dark_mode")
    on(c, darkicon, "click") do cm::ComponentModifier
        if cm["olivestyle"]["dark"] == "false"
            set_text!(cm, darkicon, "light_mode")
            set_children!(cm, "olivestyle", olivesheetdark()[:children])
            cm["olivestyle"] = "dark" => "true"
        else
            set_text!(cm, darkicon, "dark_mode")
            set_children!(cm, "olivestyle", olivesheet()[:children])
            cm["olivestyle"] = "dark" => "false"
        end
    end
    darkicon::Component{:span}
end

function settings(c::Connection)
    settingicon = topbar_icon("settingicon", "settings")
    settingicon::Component{:span}
end

function cellmenu(c::Connection)
    cellicon = topbar_icon("editico", "notes")
    cellicon::Component{:span}
end

function topbar(c::Connection)
    topbar = divider("menubar")
    leftmenu = span("leftmenu", align = "left")
    style!(leftmenu, "display" => "inline-block")
    rightmenu = span("rightmenu", align = "right")
    style!(rightmenu, "display" => "inline-block", "float" => "right")
    style!(topbar, "border-style" => "solid", "border-color" => "black",
    "border-radius" => "5px")
    push!(leftmenu, explorer_icon(c), cellmenu(c))
    push!(rightmenu, settings(c))
    push!(topbar, leftmenu, rightmenu)
    topbar::Component{:div}
end

function topbar_icon(name::String, icon::String)
    ico = span(name, class = "material-symbols-outlined", text = icon,
     margin = "15px")
     style!(ico, "font-size" => "35pt")
     ico
end

function build(c::Connection, cell::Cell{<:Any})
    hiddencell = div("cell$(cell.n)", class = "cell-hidden")
    name = a("cell$(cell.n)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end

build(f::Function, c::Connection) = begin
    c::AbstractComponent = f(c)
    if typeof(c) <: Toolips.StyleComponent

    end
end

function cell_up!(c::AbstractConnection, cm::Modifier)

end

function cell_down!(c::AbstractConnection, cm::Modifier)

end

function center_text(cc::AbstractConnection, m::Modifier)

end

#==
    CELLS
    This file implements `build` and `evaluate` for Olive.jl. Creating the base
    :code cell. These can still be overwritten with future methods and imports !
    Which is awesome, by the way. Anyway, cells are sprung into existence via
    a file cell. For example, we would implement a toml reader into Cells by
    creating a toml category and a toml section cell and then making a simple name.
    Below then is the infastructure to surround the cells, cell pages etc.
==#
function build(c::Connection, cell::Cell{:code})
    outside = div(class = cell)
    inside = div("cell$(cell.n)", class = "input_cell", text = cell.source,
     contenteditable = true, lastpos = 1)
     style!(inside, "text-color" => "white !important")
     b = IOBuffer()
     highlight(b, MIME"text/html"(), cell.source,
      Highlights.Lexers.JuliaLexer)
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

function read_project()

end
