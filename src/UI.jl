function inputcell_style()
    st = Style("div.input_cell", border = "2px solid gray", padding = "20px",
    "border-radius" => 30px, "margin-top" => 30px, "transition" => 1seconds,
    "font-size" => 13pt, "letter-spacing" => 1px,
    "font-family" => """"Lucida Console", "Courier New", monospace;""",
    "line-height" => 15px, "width" => 90percent, "border-bottom-left-radius" => 0px,
    "min-height" => 50px, "position" => "relative", "margin-top" => 0px,
    "display" => "inline-block", "border-left-top-radius" => "0px !important",
    "border-top-left-radius" => 0px, "color" => "white", "caret-color" => "gray",
    "line-height" => 24px)
    st::Style
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
function outputcell_style()
    st = Style("div.output_cell", border = "0px", padding = "10px",
    "margin-top" => 20px, "margin-right" => 200px, "border-radius" => 30px,
    "font-size" => 14pt)
    st::Style
end
#==output[code]
outputcell_style (generic function with 1 method)
==#
#==|||==#
function ipy_style()
    s::Style = Style("div.cell-ipynb",
    "background-color" => "orange",
     "width" => 75percent, "overflow-x" => "hidden", "border-color" => "gray",
     "border-width" => 2px, "cursor" => "pointer",
    "padding" => 4px, "border-style" => "solid", "transition" => "0.5s")
    s:"hover":["scale" => "1.05"]
    s::Style
end
#==output[code]
ipy_style (generic function with 1 method)
==#
#==|||==#

function toml_style()
    s = Style("div.cell-toml", "background-color" => "blue", "text-color" => "white",
    "border-width" => 2px, "overflow-x" => "hidden", "padding" => 4px,
    "transition" => "0.5s",
    "border-style" => "solid", "width" => 75percent)
    s:"hover":["scale" => "1.05"]
    s::Style
end
#==output[code]
toml_style (generic function with 1 method)
==#
#==|||==#

function jl_style()
    s = Style("div.cell-jl", "background-color" => "#F55887", "text-color" => "white",
    "border-width" => 2px, "overflow-x" => "hidden", "padding" => 4px,
    "border-style" => "solid", "width" => 75percent, "transition" => "0.5s")
    s:"hover":["scale" => "1.05"]
    s::Style
end
#==output[code]
jl_style (generic function with 1 method)
==#
#==|||==#

function spin_forever()
    load = Animation("spin_forever", delay = 0.0, length = 1.0, iterations = 0)
    load[:to] = "transform" => "rotate(360deg)"
    load::Animation
end
#==output[code]
spin_forever (generic function with 1 method)
==#
#==|||==#

function load_spinner()
    mys = Style("img.loadicon", "transition" => ".5s")
    animate!(mys, spin_forever())
    mys::Style
end
#==output[code]
load_spinner (generic function with 1 method)
==#
#==|||==#

function usingcell_style()
    st::Style = Style("div.usingcell", border = "0px solid gray", padding = "40px",
    "border-radius" => 5px, "background-color" => "#CCCCFF")
    st::Style
end
#==output[code]
usingcell_style (generic function with 1 method)
==#
#==|||==#

function cell_style()
    st::Style = Style("div.cell", "border-color" => "gray", padding = "20px",
    "background-color" => "white", "border-top-left-radius" => 0px,
    "border-bottom-left-radius" => 0px, "width" => 100percent, "transition" => 1seconds)
    st:"focus":["border-width" => 2px, "border-color" => "magenta"]
    fade_up()
    st::Style
end
#==output[code]
cell_style (generic function with 1 method)
==#
#==|||==#

hdeps_style() = Style("h1.deps", color = "white")
#==output[code]
hdeps_style (generic function with 1 method)
==#
#==|||==#
olive_icons_font() = Style("@font-face", "font-family" => "'Material Icons'",
    "font-style" => "normal", "font-weight" => "400",
    "src" => """local('Material Icons'), local('MaterialIcons-Regular'),
    url(/MaterialIcons.otf) format('opentype')""")
#==output[code]
google_icons (generic function with 1 method)
==#
#==|||==#

function iconstyle()
    s = Style(".material-icons", cursor = "pointer",
    "font-family" => "'Material Icons'", "font-weight" => "normal",
    "font-style" => "normal", "display" => "inline-block", "line-height" => "1",
    "wewbkit-font-smoothing" => "antialiased", "text-rendering" => "optimizeLegibility",
    "font-size" => "100pt", "transition" => ".4s", "line-height" => "1",
    "text-transform" => "none", "letter-spacing" => "normal",
    "word-wrap" => "normal", "white-space" => "nowrap", "direction" => "ltr")
    s:"hover":["color" => "orange", "transform" => "scale(1.1)"]
    s
end
#==output[code]
iconstyle (generic function with 1 method)
==#
#==|||==#

function hidden_style()
    Style("div.cell-hidden",
    "background-color" => "gray",
     "width" => 75percent, "overflow-x" => "hidden",
    "padding" => 4px, "transition" => "0.5s")::Style
end
#==output[code]
hidden_style (generic function with 1 method)
==#
#==|||==#

function julia_style()
    defset = ("padding" => 0px, "font-size" => 16pt, "margin-top" => 0px,
    "margin-bottom" => 0px, "margin" => 0px, "letter-spacing" => 1px,
    "line-height" => 15px,
    "font-family" => """"Lucida Console", "Courier New", monospace;""")
    hljl_pre::Style = Style("pre.hljl", defset ...)
    hljl_nf::Style = Style("span.hljl-nf", "color" => "#2B80FA", defset ...)
    hljl_oB::Style = Style("span.hljl-oB", "color" => "purple", defset ...)
    hljl_n::Style = Style("span.hljl-n", defset ...)
    hljl_ts::Style = Style("span.hljl-ts", "color" => "orange", defset ...)
    hljl_cs::Style = Style("span.hljl-cs", "color" => "gray", defset ...)
    hljl_k::Style = Style("span.hljl-k", "color" => "#E45E9D", defset ...)
    hljl_s::Style = Style("span.hljl-s", "color" => "#3FBA41", defset ...)
    styles::Component{:sheet} = Component("codestyles", "sheet")
    push!(styles, hljl_k, hljl_nf, hljl_oB, hljl_n, hljl_cs, hljl_s,
    hljl_ts)
    styles::Component{:sheet}
end
#==output[code]
julia_style (generic function with 1 method)
==#
#==|||==#

function olivesheet()
    st = ToolipsDefaults.sheet("olivestyle", dark = false)
    bdy = Style("body", "background-color" => "white", "overflow-x" => "hidden")
    pr = Style("pre", "background" => "transparent")
    push!(st, olive_icons_font(), load_spinner(), spin_forever(),
    iconstyle(), hdeps_style(),
    usingcell_style(), outputcell_style(), inputcell_style(), bdy, ipy_style(),
    hidden_style(), jl_style(), toml_style(), julia_style(), pr,
    Style("progress::-webkit-progress-value", "background" => "pink", "transition" => 2seconds),
    Style("progress::-webkit-progress-bar", "background-color" => "whitesmoke"))
    st
end
#==output[code]
olivesheet (generic function with 1 method)
==#
#==|||==#

function projectexplorer()
    pexplore = divider("projectexplorer")
    style!(pexplore, "background" => "transparent", "position" => "fixed",
    "z-index" => "1", "top" => "0", "overflow-x" => "hidden",
     "padding-top" => 75px, "width" => "0", "height" => "100%", "left" => "0",
     "transition" => "0.8s")
    pexplore
end
#==output[code]
projectexplorer (generic function with 1 method)
==#
#==|||==#

function explorer_icon(c::Connection)
    explorericon = topbar_icon("explorerico", "drive_file_move_rtl")
    on(c, explorericon, "click") do cm::ComponentModifier
        if cm["olivemain"]["ex"] == "0"
            style!(cm, "projectexplorer", "width" => "500px")
            style!(cm, "olivemain", "margin-left" => "500px")
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
#==output[code]
UndefVarError: ComponentModifier not defined
==#
#==|||==#

function settings_menu(c::Connection)
    mainmenu = section("settingsmenu", open = "0")
    style!(mainmenu, "opacity" => 0percent,  "height" => 0percent,
    "overflow-y" => "scroll", "padding" => 0px)
    mainmenu::Component{:section}
end
#==output[code]
UndefVarError: Connection not defined
==#
#==|||==#

function olive_notify!(cm::AbstractComponentModifier, message::String,
    duration::Int64 = 2000;  color::String = "pink")
    set_text!(cm, "olive-notifier", message)
    style!(cm, "olive-notifier", "height" => 2percent, "opacity" => 100percent,
    "background-color" => color)
    script!(cm, "notifierdie", time = duration) do cm2
        style!(cm2, "olive-notifier", "height" => 0percent, "opacity" => 0percent)
    end
end
#==output[code]
UndefVarError: AbstractComponentModifier not defined
==#
#==|||==#

function olive_notific()
    notifier = div("olive-notifier", align = "center")
    style!(notifier, "background-color" => "pink", "color" => "white",
    "height" => 0percent, "position" => "sticky", "opacity" => 0percent,
    "width" => 99percent, "margin-left" => 0px, "z-index" => "8",
    "font-weight" => "bold", "border-top-right-radius" => 0px, "overflow" => "hidden",
    "border-top-left-radius" => 0px, "left" => 0percent, "top" => 0percent,
    "transition" => ".5s")
    notifier::Component{:div}
end
#==output[code]
olive_notific (generic function with 1 method)
==#
#==|||==#

function settings(c::Connection)
    settingicon = topbar_icon("settingicon", "settings")
    on(c, settingicon, "click", ["settingsmenu"]) do cm::ComponentModifier
        if cm["settingsmenu"]["open"] == "0"
            style!(cm, settingicon, "transform" => "rotate(-180deg)",
            "color" => "lightblue")
            style!(cm, "settingsmenu", "opacity" => 100percent,
            "height" => 50percent)
            cm["settingsmenu"] = "open" => "1"
            return
        end
        cm["settingsmenu"] =  "open" => "0"
        style!(cm, settingicon, "transform" => "rotate(0deg)",
        "color" => "black")
        style!(cm, "settingsmenu", "opacity" => 0percent, "height" => 0percent)
        save_settings!(c)
        olive_notify!(cm, "settings saved", color = "green")
    end
    settingicon::Component{:span}
end
#==output[code]
UndefVarError: ComponentModifier not defined
==#
#==|||==#

function topbar(c::Connection)
    topbar = divider("menubar")
    leftmenu = span("leftmenu", align = "left")
    style!(leftmenu, "display" => "inline-block")
    rightmenu = span("rightmenu", align = "right")
    style!(rightmenu, "display" => "inline-block", "float" => "right")
    style!(topbar, "border-style" => "solid", "border-color" => "black",
    "border-radius" => "5px", "overflow" =>  "hidden", "position" => "sticky",
    "top" => 0percent, "z-index" => "7", "background-color" => "white")
    tabmenu = div("tabmenu", align = "center")
    style!(tabmenu, "display" => "inline-block")
    push!(leftmenu, explorer_icon(c))
    push!(rightmenu, settings(c))
    push!(topbar, leftmenu, tabmenu, rightmenu)
    topbar::Component{:div}
end
#==output[code]
UndefVarError: Connection not defined
==#
#==|||==#

function topbar_icon(name::String, icon::String)
    ico = span(name, class = "material-icons", text = icon,
     margin = "15px")
     style!(ico, "font-size" => "35pt")
     ico
end
#==output[code]
topbar_icon (generic function with 1 method)
==#
#==|||==#

function olive_body(c::Connection)
    olivebody = body("olivebody")
    style!(olivebody, "overflow-x" => "hidden", "transition" => ".8s")
    olivebody::Component{:body}
end
#==output[code]
UndefVarError: Connection not defined
==#
#==|||==#

function olive_main(selected::String = "project")
    main = div("olivemain", cell = 1,  selected = selected, ex = 0)
    style!(main, "transition" => ".8s", "overflow"  =>  "scroll")
    main::Component{:div}
end
#==output[code]
olive_main (generic function with 2 methods)
==#
#==|||==#

"""
**load_session(c::Connection, cs::Vector{Cell{<:Any}}, cm::ComponentModifier,
source::String, fpath::String, d::Directory{<:Any})**

------------------
Loads an  olive session, pushes a project into directories. The `catchall` for
all directories...
#### example
```

```
"""
function load_session(c::Connection, cs::Vector{Cell{<:Any}},
    cm::ComponentModifier, source::String, fpath::String, d::Directory{<:Any})
    direc = d.uri
    myproj = Project{:olive}("hello", "ExampleProject")
    fsplit = split(fpath, "/")
    if typeof(d) == Directory{:subdir}
        d = Directory(d.access["toplevel"], "all" =>  "rw")
    end
    if "Project.toml" in readdir(d.uri)
        myproj.environment = d.uri
    else
        myproj.environment = c[:OliveCore].data["home"]
    end

    push!(myproj.directories, d)
    name = split(fsplit[length(fsplit)], ".")[1]
    modname = name * replace(ToolipsSession.gen_ref(10),
    [string(dig) => "" for dig in digits(1234567890)] ...)
    modstr = olive_module(modname, myproj.environment)
    mod::Module = eval(Meta.parse(modstr))
    projdict = Dict{Symbol, Any}(:mod => mod, :cells => cs, :path => fpath)
    push!(myproj.open, fsplit[length(fsplit)] =>  projdict)
    c[:OliveCore].open[getname(c)] = myproj
    redirect!(cm, "/session")
end
#==output[code]
UndefVarError: Cell not defined 
==#
#==|||==#

function add_to_session(c::Connection, cs::Vector{Cell{<:Any}},
    cm::ComponentModifier, source::String, fpath::String)
    myproj = c[:OliveCore].open[getname(c)]
    all_paths = [project[:path]  for project in values(myproj.open)]
    if fpath in all_paths
        olive_notify!(cm, "project already open!", color = "red")
        return
    end
    d = myproj.directories[1]
    if "Project.toml" in readdir(d.uri)
        myproj.environment = d.uri
    else
        myproj.environment = c[:OliveCore].data["home"]
    end
    fsplit = split(fpath, "/")
    name = split(fsplit[length(fsplit)], ".")[1]
    modname = name * replace(ToolipsSession.gen_ref(10),
    [string(dig) => "" for dig in digits(1234567890)] ...)
    modstr = olive_module(modname, myproj.environment)
    filepath_name::String = fsplit[length(fsplit)]
    mod::Module = eval(Meta.parse(modstr))
    projdict = Dict{Symbol, Any}(:mod => mod, :cells => cs, :path => fpath)
    push!(myproj.open, filepath_name =>  projdict)
    projbuild = build(c, cm, myproj, at = filepath_name)
    append!(cm, "olivemain", projbuild)
end
#==output[code]
UndefVarError: Cell not defined 
==#
#==|||==#

function build_tab(c::Connection, fname::String)
    tabbody = div("tab$(fname)")
    style!(tabbody, "border-bottom-right-radius" => 0px,
    "border-bottom-left-radius" => 0px, "display" => "inline-block",
    "border-width" => 2px, "border-color" => "lightblue",
    "border-style" => "solid", "margin-bottom" => "0px", "cursor" => "pointer",
    "margin-left" => 10px)
    tablabel = a("tablabel$(fname)", text = fname)
    style!(tablabel, "font-weight" => "bold", "margin-right" => 5px,
    "font-size"  => 13pt)
    push!(tabbody, tablabel)
    on(c, tabbody, "click") do cm::ComponentModifier
        if ~("$(fname)close" in keys(cm.rootc))
            closebutton = topbar_icon("$(fname)close", "close")
            on(c, closebutton, "click") do cm2::ComponentModifier
                remove!(cm2, "$(fname)over")
                delete!(c[:OliveCore].open[getname(c)].open, fname)
                olive_notify!(cm2, "project $(fname) closed", color = "blue")
            end
            savebutton = topbar_icon("$(fname)save", "save")
            on(c, savebutton, "click") do cm2::ComponentModifier
                save_type = split(fname, ".")[2]
                savepath = c[:OliveCore].open[getname(c)].open[fname][:path]
                cells = c[:OliveCore].open[getname(c)].open[fname][:cells]
                savecell = Cell(1, string(save_type), fname, savepath)
                ret = olive_save(cells, savecell)
                if isnothing(ret)
                    olive_notify!(cm2, "file $(savepath) saved", color = "green")
                else
                    olive_notify!(cm2, "file $(savepath) saved", color = "$ret")
                end
            end
            saveas_button = topbar_icon("$(fname)saveas", "save_as")
            on(c, saveas_button, "click") do cm2::ComponentModifier

            end
            restartbutton = topbar_icon("$(fname)restart", "restart_alt")
            on(c, restartbutton, "click") do cm2::ComponentModifier
                new_name = split(fname, ".")[1]
                myproj = c[:OliveCore].open[getname(c)]
                modname = new_name * replace(ToolipsSession.gen_ref(10),
                [string(dig) => "" for dig in digits(1234567890)] ...)
                modstr = """module $(modname)
                using Pkg

                function evalin(ex::Any)
                        Pkg.activate("$(myproj.environment)")
                        ret = eval(ex)
                end
                end"""
                mod::Module = eval(Meta.parse(modstr))
                myproj.open[fname][:mod] = mod
                olive_notify!(cm2, "module for $(fname) re-sourced")
            end
            add_button = topbar_icon("$(fname)add", "add_circle")
            on(c, add_button, "click") do cm2::ComponentModifier
                cells = c[:OliveCore].open[getname(c)].open[fname][:cells]
                new_cell = Cell(length(cells) + 1, "creator", "")
                push!(cells, new_cell)
                append!(cm2, fname, build(c, cm2, new_cell, cells, fname))
            end
            runall_button = topbar_icon("$(fname)run", "start")
            on(c, runall_button, "click") do cm2::ComponentModifier
                cells = c[:OliveCore].open[getname(c)].open[fname][:cells]
                [begin
                try
                    evaluate(c, cm2, cell, cells, fname)
                catch
                end
                end for cell in cells]
            end
            decollapse_button = topbar_icon("$(fname)dec", "arrow_left")
            on(c, decollapse_button, "click") do cm2::ComponentModifier
                remove!(cm2, savebutton)
                remove!(cm2, closebutton)
                remove!(cm2, saveas_button)
                remove!(cm2, add_button)
                remove!(cm2, runall_button)
                remove!(cm2, restartbutton)
                remove!(cm2, decollapse_button)
            end
            style!(closebutton, "font-size"  => 17pt, "color" => "red")
            style!(restartbutton, "font-size"  => 17pt, "color" => "gray")
            style!(savebutton, "font-size"  => 17pt, "color" => "gray")
            style!(saveas_button, "font-size"  => 17pt, "color" => "gray")
            style!(decollapse_button, "font-size"  => 17pt, "color" => "blue")
            style!(add_button, "font-size"  => 17pt, "color" => "gray")
            style!(runall_button, "font-size"  => 17pt, "color" => "gray")
            append!(cm, tabbody, decollapse_button)
            append!(cm, tabbody, savebutton)
            append!(cm, tabbody, saveas_button)
            append!(cm, tabbody, add_button)
            append!(cm, tabbody, restartbutton)
            append!(cm, tabbody, runall_button)
            append!(cm, tabbody, closebutton)
        end
    end
    tabbody
end
#==output[code]
UndefVarError: ComponentModifier not defined
==#
#==|||==#

function olive_loadicon()
    srcdir = @__DIR__
    iconb64 = read(srcdir * "/images/loadicon.png", String)
    myimg = img("olive-loader", src = iconb64, class = "loadicon")
    animate!(myimg, spin_forever())
    myimg

end
#==output[code]
olive_loadicon (generic function with 1 method)
==#
#==|||==#

function olive_cover()
    srcdir = @__DIR__
    iconb64 = read(srcdir * "/images/cover.png", String)
    img("olive-headerr", src = iconb64, width = 250)
end
#==output[code]
olive_cover (generic function with 1 method)
==#
#==|||==#

include("Cells.jl")
#==output[code]
SystemError: opening file "/home/emmac/dev/toolips/Olive/Cells.jl": No such file or directory
==#
#==|||==#


#==output[code]

==#
#==|||==#
