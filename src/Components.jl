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

function inputcell_style()
    st = Style("div.input_cell", border = "2px solid gray", padding = "20px",
    "bordier-radius" => 30px, "margin-top" => 30px, "transition" => 1seconds,
    "font-size" => 14pt)
    animate!(st, cell_in())
    st:"focus":["border-width" => 5px, "border-color" => "orange"]
    st::Style
end

function outputcell_style()
    st = Style("div.output_cell", border = "0px", padding = "10px",
    "margin-top" => 20px, "margin-right" => 200px, "border-radius" => 30px,
    "font-size" => 14pt)
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
function cellnumber_style()
    st = Style("h1.cell_number", color = "lightblue")
    st["font-family"] = "'Rubik', sans-serif"
    st
end

function ipy_style()
    Style("div.cell-ipynb",
    "background-color" => "orange",
     "width" => 75percent, "overflow-x" => "hidden", "border-color" => "gray",
     "border-width" => 2px,
    "padding" => 4px, "border-style" => "solid")::Style
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
    usingcell_style(), outputcell_style(), inputcell_style(), bdy, ipy_style())
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
    usingcell_style(), outputcell_style(), ipc, bdy)
    st
end

#==
    CELLS
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
    "</div>" => "", "\n" => ";", "\n        " => ";")
end


function cellcontainer(c::Connection, vc::Vector{Cell}, filename::String)
    cells::Vector{Servable} = [begin
        cellcomp = c[:OliveCore].celltypes[cell.ctype].cell(c, "cell$(vc.n)")
        c[:text] = cell.cont

    end for cell in vc]
end

function build(c::Connection, cell::Cell{:code})
    outside = div(class = cell)
    inside = div("cell$(cell.n)", class = "input_cell", text = cell.source,
     contenteditable = true, lastlen = 1)
     on(c, inside, "focus") do cm::ComponentModifier
         cm["olivemain"] = "cell" => string(cell.n)
     end
     on(c, inside, "keyup") do cm::ComponentModifier
         rawcode = unhighlight(cm["cell$(cell.n)"]["text"])
         if length(rawcode) == 0
             return
         end
         lastc::Char = rawcode[length(rawcode)]
         if (lastc == ' ' || lastc == '\n' || lastc == ';')

         end
     end
    number = h("cell", 1, text = cell.n, class = "cell_number")
    output = divider("cell$(cell.n)" * "out", class = "output_cell", text = cell.outputs)
    push!(outside, inside, output)
    outside
end

function build(c::Connection, cell::Cell{:md})
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
    fname = Toolips.b("$(cell.source)", text = cell.source)
    style!(fname, "color" => "white", "font-size" => 15pt)
    push!(filecell, fname)
    filecell
end

function build(c::Connection, cell::Cell{:jl})

end

function build(c::Connection, cell::Cell{:toml})

end

function cellcontainer(c::Connection, name::String)
    divider(name)
end

function projectexplorer()
    pexplore = divider("projectexplorer")
    examplefile = ul("hello", text = "wow")
    style!(pexplore, "background" => "transparent", "position" => "fixed",
    "z-index" => "1", "top" => "0", "overflow-x" => "hidden",
     "padding-top" => "30px", "width" => "0", "height" => "100%", "left" => "0",
     "transition" => "0.8s")
    push!(pexplore, examplefile)
    pexplore
end

function topbar(c::Connection)
    topbar = divider("menubar")
    leftmenu = span("leftmenu", align = "left")
    style!(leftmenu, "display" => "inline-block")
    rightmenu = span("rightmenu", align = "right")
    style!(rightmenu, "display" => "inline-block", "float" => "right")
    style!(topbar, "border-style" => "solid", "border-color" => "black",
    "border-radius" => "5px")
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
    fileicon = topbar_icon("fileico", "list")
    editicon = topbar_icon("editico", "notes")
    settingicon = topbar_icon("settingicon", "settings")
    styleicon = topbar_icon("styleico", "display_settings")
    darkicon = topbar_icon("darkico", "dark_mode")
    sendicon = topbar_icon("sendico", "send")
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
    push!(leftmenu, explorericon, fileicon, editicon)
    push!(rightmenu, styleicon, darkicon, settingicon, sendicon)
    push!(topbar, leftmenu, rightmenu)
    topbar
end

function topbar_icon(name::String, icon::String)
    ico = span(name, class = "material-symbols-outlined", text = icon,
     margin = "15px")
     style!(ico, "font-size" => "35pt")
     ico
end
