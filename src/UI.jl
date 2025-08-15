function inputcell_style()
    st = Style("div.input_cell", "border" => "2px solid gray", "padding" => "20px",
    "border-radius" => 8px, "margin-top" => 30px, "transition" => 1000ms,
    "font-size" => 13pt, "letter-spacing" => 1px,
    "font-family" => """"Lucida Console", "Courier New", monospace;""",
    "line-height" => 19px, "width" => 90percent, "border-bottom-left-radius" => 0px,
    "min-height" => 50px, "position" => "relative", "margin-top" => 0px,
    "display" => "inline-block", "border-left-top-radius" => "0px !important",
    "border-top-left-radius" => 0px, "color" => "white", "caret-color" => "gray",
    "max-width" => 90percent, "overflow-wrap" => "break-word")
    st::Style
end

function cellside_style()
    st = Style("div.cellside", "display" => "inline-block",
    "border-bottom-right-radius" => 0px, "border-top-right-radius" => 0px,
    "overflow" => "hidden", "border-style" => "solid", "border-width" => 1px, 
    "transition" => 650ms)
    st::Style
end

function spin_forever()
    load = keyframes("spin_forever",  duration = 600ms, iterations = 0)
    keyframes!(load, 0percent, "transform" => "scale(.9)")
    keyframes!(load, 50percent, "transform" => "scale(1)")
    keyframes!(load, 100percent, "transform" => "scale(.9)")
    load
end

function load_spinner()
    mys = Style("img.loadicon", "transition" => ".5s")
    style!(mys, spin_forever())
    mys::Style
end

function cell_style()
    st::Style = Style("div.cell", "transition" => 350ms)
    st:"focus":["border-width" => 2px, "border-color" => "magenta"]
    st::Style
end

hdeps_style() = Style("h1.deps", "color" => "white")

olive_icons_font() = Style("@font-face", "font-family" => "'Material Icons'",
    "font-style" => "normal", "font-weight" => "400",
    "src" => """local('Material Icons'), local('MaterialIcons-Regular'),
    url(/MaterialIcons.otf) format('opentype')""")::Style

function iconstyle()
    s = Style(".material-icons", "cursor" => "pointer",
    "font-family" => "'Material Icons'", "font-weight" => "normal",
    "font-style" => "normal", "display" => "inline-block", "line-height" => "1",
    "wewbkit-font-smoothing" => "antialiased", "text-rendering" => "optimizeLegibility",
    "font-size" => "100pt", "transition" => ".4s", "line-height" => "1",
    "text-transform" => "none", "letter-spacing" => "normal",
    "word-wrap" => "normal", "white-space" => "nowrap", "direction" => "ltr", "user-select" => "none")
    s:"hover":["color" => "#fc8208", "transform" => "scale(1.03)"]
    s
end

function filec_style()
    s = Style("div.file-cell", "padding" => 10px,
    "background-color" => "gray","overflow" => "visible", "cursor" => "pointer", "overflow" => "visible",
    "padding" => 4px, "transition" => "0.5s", "border-radius" => 0px, "border-top-left-radius" => 0px, 
    "border-top-right-radius" => 0px, "border-right" => "2px solid 	#232b2b", 
    "width" => 100percent)
    s:"hover":["border-left" => "5px solid magenta", "transform" => "scale(1.02)"]
    s::Style
end

function default_divstyle(;padding::Integer = 7, radius1::Integer = 15)
    Style("div", "padding" => padding, "background" => "transparent",
    "border-radius" => "$(radius1)px", "overflow-y" => "scroll")
end

function default_buttonstyle(;face_padding::Integer = 5,
    radius2::Integer = 8)
    s = Style("button", "padding" => face_padding, "color" => "#754679",
    "background-color" => "#F9AFEC", "border-style" => "none",
    "border-radius" => "$(radius2)px", "transition" => 1seconds)
    s:"hover":["background-color" => "#A2DEBD", "transform" => "scale(1.1)"]
    s
end

function default_tabstyle(; radiustop::Int64 = 5,
    face_padding::Int64 = 5)
    Style("tab", "padding" => face_padding, "transition" => 1seconds,
    "backgroundcolor" => "#754679", "color" => "#754679")::Style
end

default_astyle() = Style("a", "color" => "#2c4c3b", "transition" => 700ms)

default_pstyle(; textsize = 12pt) = Style("p",
    "color" => "#141414", "font-size" => "14pt")::Style

function default_sectionstyle(;padding::Any = 30px,
    radius::Any = 10px)
    Style("section", "border-color" => "#754679",
    "border-width" => "2px", "border-radius" => 10px, "border-style" => "solid",
    "transition" => 1seconds)::Style
end

function sheet(name::String,p::Pair{String, Any} ...;
    textsize::Integer = 14, face_textsize::Integer = 12,
    padding::Integer = 7, face_padding::Integer = 5,
    radius1::Integer = 15, radius2::Integer = 8,
    transition::Float64 = 0.5,
    args ...)
    msheet = Component{:sheet}(name, p ..., args ...)
    divs = default_divstyle()
    buttons = default_buttonstyle()
    as = default_astyle()
    ps = default_pstyle(textsize = textsize)
    sectionst = default_sectionstyle(padding = padding)
    tabs = default_tabstyle()
    h1s = Style("h1", "color" => "#754679")
    h2s = Style("h2", "color" => "#797ef6")
    h3s = Style("h3", "color" => "#241124")
    h4s = Style("h4", "color" => "#292828")
    h5s = Style("h5", "color" => "#851576")
    scrollbars = Style("::-webkit-scrollbar", "width" => "5px")
    scrtrack = Style("::-webkit-scrollbar-track", "background" => "transparent")
    scrthumb = Style("::-webkit-scrollbar-thumb", "background" => "#797ef6",
    "border-radius" => "5px")
    push!(msheet, divs, buttons, sectionst, as, ps, h1s,
    h2s, h3s, h4s, h5s, scrollbars, scrtrack, scrthumb)
    msheet
end

"""
```julia
olivesheet() -> ::Component{:sheet}
```
Returns the default `Olive` stylesheet/theme (`pastel-pride`) -- a great template to start from when creating 
your own styles.
```julia
new_sheet = Olive.olivesheet()
for sty in new_sheet[:children]
    @warn sty.name
    @info string(sty)
end
```
- See also: `build_findbar`, `containersection`, `Olive`
"""
function olivesheet()
    st = sheet("olivestyle", dark = false)
    bdy = Style("body", "background-color" => "white", "overflow-x" => "hidden")
    pr = Style("pre", "background" => "transparent")
    # fadeup:
    fade_upanim = keyframes("fadeup")
    keyframes!(fade_upanim, 0percent, "opacity" => 0percent, "transform" => translateY(5percent))
    keyframes!(fade_upanim, 100percent, "opacity" => 100percent, "transform" => translateY(0percent))
    # topbar:
    topbar_style = style("div.topbar", "border-color" => "black", 
        "border-radius" => "5px", "background-color" => "white", "transition" => 500ms, 
        "border-style" => "solid", "top" => 0percent, "position" => "sticky", "animation-name" => "fadeup", "animation-duration" => 700ms)
    topbar_icons_s = style("span.topbaricons", "font-size" => "35pt")
    #tabs:
    tabclosed_style = style("div.tabclosed", "border-width" => 2px, "border-color" => "#333333",
        "border-style" => "solid", "background-color" => "gray", "border-width" => 2px, "border-color" => "#333333", 
        "border-bottom-width" => 0px, "border-style" => "solid", "background-color" => "lightgray", "border-bottom-right-radius" => 0px, 
        "border-bottom-left-radius" => 0px, "display" => "inline-block", "margin-bottom" => "0px", "cursor" => "pointer", 
        "margin-left" => 0px, "transition" => 1seconds, 
        "animation-name" => "fadeup", "animation-duration" => 700ms)
    tabopen_style = style("div.tabopen", 
        "border-width" => 2px, "border-color" => "#333333", "border-bottom" => "0px solid white",
        "border-style" => "solid", "background-color" => "white", "border-bottom-right-radius" => 0px, "border-bottom-left-radius" => 0px, 
        "display" => "inline-block", "margin-bottom" => "0px", "cursor" => "pointer",
        "margin-left" => 0px, "transition" => 1seconds, "border-radius" => 8px, 
        "animation-name" => "fadeup", "animation-duration" => 800ms)
    tablabel = style("a.tablabel", "font-size"  => 13pt, "color" => "#A2646F", 
        "font-weight" => "bold", "margin-right" => 5px,
        "transition" => "250ms", "padding-right" => 5px, "user-select" => "none")
    tab_icon = style("span.tablabel", "font-size"  => 17pt, "cursor" => "pointer",
        "font-family" => "'Material Icons'", "font-weight" => "normal",
        "font-style" => "normal", "display" => "inline-block")
    tab_icon:"hover":["transform" => "scale(1.01)", "color" => "darkgray"]
    # projects:
    project_window = Style("div.projectwindow", "overflow-y" => "show", "overflow-x" => "hidden", "padding" => 7px, 
    "animation-name" => "fadeup", "animation-duration" => 850ms, "min-height" => 100percent)
    # project explorer:
    p_explorer = style("div.pexplorer", "position" => "absolute", "z-index" => "1", "top" => "0", "overflow" => "visible",
        "height" => "90%", "left" => "8", "padding" => 0px,
        "transition" => 800ms, "margin-top" => 85px, "border-radius" => 0px, 
        "overflow-y" => "visible")
    p_explorer_open = style("div.pexplorer-open", "width" => "500px", 
        "opacity" => 100percent, "overflow-y" => "scroll", "pointer-events" => "auto")
    p_explorer_closed = style("div.pexplorer-closed", "opacity" => 0percent, 
        "position" => "absolute", "z-index" => "1", "top" => "0", "overflow" => "visible",
        "width" => "0", "height" => "90%", "left" => "8", "padding" => 0px,
        "transition" => "0.8s", "margin-top" => 85px, "border-radius" => 0px, 
        "overflow-y" => "visible", "pointer-events" => "none", "padding" => 5px)
    icon_selected = style(".material-icons-selected", "color" => "lightblue", "overflow-x" => "hidden")
    # settings:
    settings = style("div.settings", "opacity" => "0 !important",  "height" => "0px !important",
    "overflow-y" => "scroll", "padding" => 0px, "transition" => 1s, "position" => "sticky", 
    "pointer-events" => "none ! important")
    settings_exp = style("div.settings-expanded", "opacity" => "1 !important",
        "height" => "90% !important", "padding" => 10px, "transition" => 1s, "pointer-events" => "auto")
    # container sections:
    section_container = style("section.outers", "background-color" => "white", "padding" => 3px, "transition" => 1seconds)
    section_container_labels = style(".containerlabels", "display" => "inline-block", "color" => "#333333", 
    "font-weight" => "bold")
    section_innerc = style("div.inner-closed", "opacity" => 0percent, "height" => 0percent, 
    "padding" => 0px, "transition" => 500ms, "pointer-events" => "none")
    section_innero = style("div.inner-open", "opacity" => 100percent, "height" => 70percent, 
            "pointer-events" => "auto", "padding" => 5px, "transition" => 500ms, "overflow-x" => "hidden")
    container_arrow = Style("span.containerarrow", "cursor" => "pointer",
    "font-size" => 13pt, "color" => "#1e1e1e")
    # cells:
    output_style = style("div.output_cell", "max-height" => 750px, "overflow-y" => "scroll")
    code_side = Style("div.codeside", "background-color" => "pink")
    md_side = Style("div.mdside", "background-color" => "#452b20")
    output_style = style("div.output_cell", "max-height" => 200px, "overflow-y" => "scroll")
    selected_side = Style("div.selectedside", "background-color" => "#485eae")
    input_selected = style("div.inputselected", "border-color" => "#485eae")
    file_cell_icons = style("span.fileicon", "color" => "white", "font-size" => 17pt)
    file_names = style("a.filelabel", "color" => "white", "font-weight" => "bold",
    "font-size" => 14pt, "margin-left" => 5px, "pointer-events" => "none")
    cell_icons = style("span.cell-icons", "font-size" => 17pt, "color" => "white !important")
    # dialogs:
    dialog_box = style("div.confdialog", "background-color" => "white", "border" => "3px solid #333333", "padding" => 15px, 
    "position" => "absolute", "width" => 50percent, "height" => 20percent, "top" => 25percent, "left" => 25percent, 
    "overflow-x" => "hidden", "overflow-wrap" => "anywhere", "overflow-y" => "hidden", "z-index" => "15", 
    "animation-name" => "fadeup", "animation-duration" => 850ms)
    dialog_text = style("div.dialogtext", "font-size" => 14pt, "font-weight" => "bold")
    # search:
    searchboxes = style("div.searchboxes", "padding" => 3px, "background-color" => "white", "border-radius" => 2px, 
    "border" => 1px * "solid #1e1e1e", "width" => 95percent)
    find_cont = style("div.findcontainer", "padding" => 1px, "background-color" => "#1e1e1e", "border-top-left-radius" => 0px, 
    "border-top-right-radius" => 0px, "position" => "absolute", "top" => 0, "width" => 99percent, "z-index" => 10)
    # push:
    push!(st, olive_icons_font(), load_spinner(), spin_forever(),
    iconstyle(), hdeps_style(), Component{:link}("oliveicon", rel = "icon",
    href = "/favicon.ico", type = "image/x-icon"), title("olivetitle", text = "olive !"),
    inputcell_style(), bdy, cellside_style(), filec_style(), pr, cell_style(),
    Style("::-webkit-progress-value", "background" => "pink", "transition" => 2seconds),
    Style("::-webkit-progress-bar", "background-color" => "whitesmoke"), 
    Style("progress", "-webkit-appearance" => "none"), topbar_style, tabclosed_style, 
    tabopen_style, tablabel, icon_selected, p_explorer, p_explorer_open, settings, settings_exp, section_container, 
    section_container_labels, section_innerc, section_innero, container_arrow, tab_icon, output_style, project_window, 
    dialog_box, dialog_text, fade_upanim, code_side, selected_side, input_selected, searchboxes, find_cont, p_explorer_closed, 
    file_cell_icons, file_names, topbar_icons_s, cell_icons, md_side)
    st::Component{:sheet}
end

const DEFAULT_SHEET = begin
    new_sheet = olivesheet()
    compress!(new_sheet)
    new_sheet::Component{:sheet}
end

"""
```julia
projectexplorer() -> ::Component{:div}
```
Builds the `Olive` project explorer.
```julia
```
- See also: `close_project_explorer!`, `explorer_icon`, `settings`, `open_project_explorer!`
"""
function projectexplorer()::Component{:div}
    div("projectexplorer", class = "pexplorer pexplorer-closed")
end

"""
```julia
close_project_explorer!(cm::AbstractComponentModifier) -> ::Nothing
```
Closes the project explorer by changing its class. The inverse of `open_project_explorer!`
```julia
```
- See also: `open_project_explorer!`, `explorer_icon`
"""
function close_project_explorer!(cm::AbstractComponentModifier)
    cm["projectexplorer"] = "class" => "pexplorer pexplorer-closed"
    style!(cm, "menubar", "border-bottom-left-radius" => 5px)
    style!(cm, "olivemain", "margin-left" => "0px")
    set_text!(cm, "explorerico", "drive_file_move_rtl")
    cm["explorerico"] = "class" => "material-icons topbaricons"
    cm["olivemain"] = "ex" => "0"
    nothing::Nothing
end

"""
```julia
open_project_explorer!(cm::AbstractComponentModifier) -> ::Nothing
```
Opens the project explorer by changing its class. The inverse of `close_project_explorer!`.
```julia
```
- See also: `close_project_explorer!`, `Olive`, `projectexplorer`, `explorer_icon`, `olivesheet`
"""
function open_project_explorer!(cm::AbstractComponentModifier)
    if ~(haskey(CORE.data, "headless") || haskey(CORE.data, "noset"))
        close_settings_menu!(cm)
    end
    cm["projectexplorer"] = "class" => "pexplorer pexplorer-open"
    style!(cm, "olivemain", "margin-left" => "500px")
    cm["explorerico"] = "class" => "material-icons topbaricons material-icons-selected"
    style!(cm, "menubar", "border-bottom-left-radius" => 0px)
    set_text!(cm, "explorerico", "folder_open")
    cm["olivemain"] = "ex" => "1"
    nothing::Nothing
end

"""
```julia
explorer_icon(c::Connection) -> ::Component{:span}
```
Creates an explorer icon automatically bound to `close_project_explorer!` and `open_project_explorer!`
```julia
```
- See also: `projectexplorer`, `open_project_explorer!`, `containersection`, `olivesheet`, `settings_menu`
"""
function explorer_icon(c::Connection)
    explorericon = topbar_icon("explorerico", "drive_file_move_rtl")
    on(c, explorericon, "click") do cm::ComponentModifier
        if cm["olivemain"]["ex"] == "0"
            open_project_explorer!(cm)
            return
        end
        close_project_explorer!(cm)
    end
    explorericon::Component{:span}
end

"""
```julia
settings_menu(c::Connection) -> ::Component{:span}
```
Creates an explorer icon automatically bound to `close_project_explorer!` and `open_project_explorer!`
```julia
```
- See also: `projectexplorer`, `open_project_explorer!`, `containersection`, `olivesheet`, `settings_menu`
"""
function settings_menu(c::Connection)
    div("settingsmenu", open = "0", class = "settings")::Component{:div}
end

"""
```julia
containersection(c::Connection, name::String, level::Int64 = 3; 
text::String = name, fillto::Int64 = 80)
```
This function creates a simple `Olive`-styled collapsible container. 
    These are used in the **settings** menu and the **inspector** inside 
    of `Olive`.
```julia

```
"""
function containersection(c::Connection, name::String, level::Int64 = 3;
    text::String = name, fillto::Int64 = 60)
    arrow::Component{:span} = topbar_icon("$name-expander", "expand_more")
    arrow[:class] = "material-icons containerarrow"
    outersection::Component{:section} = section("outer$name", ex = "0", class = "outers")
    heading::Component{<:Any} = Component{Symbol("h$level")}("$name-heading", text = text, class = "containerlabels")
    upperdiv::Component{:div} = div("$name-upper")
    push!(upperdiv, heading, arrow, Component{:sep}("sep$name"))
    push!(outersection, upperdiv)
    innersection::Component{:div} = div("$name", class = "inner-closed")
    on(c, arrow, "click") do cm::ComponentModifier
        if cm[outersection]["ex"] == "0"
            cm[name] = "class" => "inner-open"
            cm[outersection] = "ex" => "1"
            return
        end
        cm[name] = "class" => "inner-closed"
        cm[outersection] = "ex" => "0"
    end
    push!(outersection, innersection)
    outersection::Component{:section}
end

"""
```julia
switch_work_dir!(c::Connection, cm::AbstractComponentModifier, path::String) -> ::Nothing
```
Switches the active working directory (`Environment.pwd`) to the provided path. 
This will also decollapse the **inspector** and open the **project explorer**
```julia

```
"""
function switch_work_dir!(c::Connection, cm::AbstractComponentModifier, path::String)
    env::Environment = CORE.users[getname(c)].environment
    if ~(contains(path, split(env.pwd, "/")[1])) && ~(CORE.data["root"] == getname(c))
        olive_notify!(cm, "you do not have permission to access this directory!", color = "red")
        return
    end
    env.pwd = path
    if isfile(path)
        pathsplit = split(path, "/")
        path = string(join(pathsplit[1:length(pathsplit) - 1], "/"))
    end
    newcells = directory_cells(string(path), wdtype = :switchdir)
    pwddi = findfirst(d -> typeof(d) == Directory{:pwd}, env.directories)
    if isnothing(pwddi)
        return
    end
    if path != env.directories[pwddi].uri
        newcells = vcat([Cell("retdir", "")], newcells)
    end
    newd = Directory(path)
    childs = Vector{Servable}([begin
        build(c, mcell, newd)
    end
    for mcell in newcells])
    set_text!(cm, "selector", string(path))
    set_children!(cm, "pwdbox", childs)
    nothing::Nothing
end

function switch_work_dir!(cm::AbstractComponentModifier, path::String)
    if isfile(path)
        pathsplit = split(path, "/")
        path = string(join(pathsplit[1:length(pathsplit) - 1], "/"))
    end
    newcells = directory_cells(string(path), wdtype = :switchdir)
    pwddi = findfirst(d -> typeof(d) == Directory{:pwd}, env.directories)
    if isnothing(pwddi)
        return
    end
    if path != env.directories[pwddi].uri
        newcells = vcat([Cell("retdir", "")], newcells)
    end
    newd = Directory(path)
    childs = Vector{Servable}([begin
        build(c, mcell, newd)
    end
    for mcell in newcells])
    set_text!(cm, "selector", string(path))
    set_children!(cm, "pwdbox", childs)
end

"""
```
create_new(c::Connection, cm::AbstractComponentModifier, oe::OliveExtension{<:Any}) -> ::Nothing
```
Creates a new project from a given template. Each method for this function will 
create a new button inside of the **create** menu in the **explorer**.
```

```
"""
function create_new(c::Connection, cm::AbstractComponentModifier, oe::OliveExtension{:jl}, path::String, finalname::String)
    projdata = Dict{Symbol, Any}(:cells => Vector{Cell}([Cell("code", "")]), 
    :env => c[:OliveCore].data["home"], :path => path * "/" * finalname)
    touch(path * "/" * finalname)
    newproj = Project{:olive}(finalname, projdata)
    source_module!(c, newproj)
    projtab = build_tab(c, newproj)
    open_project(c, cm, newproj, projtab)
end

function create_new(c::Connection, cm::AbstractComponentModifier, oe::OliveExtension{:module}, path::String, finalname::String)
    finalname = split(finalname, ".")[1]
    try
        Pkg.generate(path * "/" * finalname)
        open(path * "/" * finalname * "/src/$finalname.jl", "w") do o
            write(o, """
            module $finalname
            function greet()
                println("hello world")
            end
            end
            #==
            code/hello world!
            ==#
            #--
            #==output[module]
            $finalname
            ==#
            #==|||==#""")
        end
        olive_notify!(cm, "successfully created $finalname !"; color = "green")
        cells = IPyCells.read_jl(path * "/$finalname/src/$finalname.jl")
        add_to_session(c, cells, cm, "$finalname.jl", path * "/$finalname/src/")
    catch e
        print(e)
        olive_notify!(cm, "failed to create $finalname !", color = "red")
    end
end

function create_new(c::Connection, cm::AbstractComponentModifier, oe::OliveExtension{:directory}, path::String, finalname::String)
    path = path * "/" * replace(finalname, ".directory" => "")
    mkdir(path)
    olive_notify!(cm, "created directory", color = "darkgreen")
    switch_work_dir!(c, cm, path)
end

"""
```julia
olive_notify!(cm::AbstractComponentModifier, message::String, 
duration::Int64 = 2000, color::String = "#333333") -> ::Nothing
```
Sends a notification to the top of the user's session. `duration` changes how 
long the message is displayed and `color` changes the background color of the message.
```julia

```
"""
function olive_notify!(cm::AbstractComponentModifier, message::String,
    duration::Int64 = 2000;  color::String = "#333333")
    set_text!(cm, "olive-notifier", message)
    style!(cm, "olive-notifier", "height" => 2percent, "opacity" => 100percent,
    "background-color" => color)
    on(cm, time = duration) do cm2
        style!(cm2, "olive-notifier", "height" => 0percent, "opacity" => 0percent)
    end
    nothing::Nothing
end

"""
```julia
olive_notific() -> ::Component{:div}
```
Sends a notification to the top of the user's session. `duration` changes how 
long the message is displayed and `color` changes the background color of the message.
```julia

```
"""
function olive_notific()
    notifier::Component{:div} = div("olive-notifier", align = "center")
    style!(notifier, "background-color" => "pink", "color" => "white",
    "height" => 0percent, "position" => "sticky", "opacity" => 0percent,
    "width" => 99percent, "margin-left" => 0px, "z-index" => "8",
    "font-weight" => "bold", "border-top-right-radius" => 0px, "overflow" => "hidden",
    "border-top-left-radius" => 0px, "left" => 0percent, "top" => 0percent,
    "transition" => ".5s")
    notifier::Component{:div}
end

function open_settings_menu!(cm::AbstractComponentModifier)
    close_project_explorer!(cm)
    style!(cm, "settingicon", "transform" => "rotate(-180deg)")
    cm["settingicon"] = "class" => "material-icons topbaricons material-icons-selected"
    cm["settingsmenu"] = "class" => "settings-expanded"
    cm["settingsmenu"] = "open" => "1"
end

function close_settings_menu!(cm::AbstractComponentModifier)
    if ~("settingsmenu" in cm)
        return
    end
    cm["settingsmenu"] =  "open" => "0"
    style!(cm, "settingicon", "transform" => "rotate(0deg)")
    cm["settingicon"] = "class" => "material-icons topbaricons"
    cm["settingsmenu"] = "class" => "settings"
    cm["settingsmenu"] = "open" => "0"
end

function settings(c::Connection)
    settingicon = topbar_icon("settingicon", "settings")
    on(c, settingicon, "click") do cm::ComponentModifier
        if cm["settingsmenu"]["open"] == "0"
            open_settings_menu!(cm)
            return
        end
        close_settings_menu!(cm)
        save_settings!(c)
        olive_notify!(cm, "settings saved", color = "green")
    end
    settingicon::Component{:span}
end

function topbar(c::Connection, settings_enabled::Bool = true, extras::Component{<:Any} ...)
    topbar = div("menubar", class = "topbar")
    leftmenu = span("leftmenu", align = "left")
    style!(leftmenu, "display" => "inline-block")
    rightmenu = span("rightmenu", align = "right")
    style!(rightmenu, "display" => "inline-block", "float" => "right")
    style!(topbar, "overflow" =>  "hidden", "position" => "sticky", "z-index" => "7")
    tabmenu = div("tabmenu", align = "center")
    style!(tabmenu, "display" => "inline-block")
    if ~(haskey(CORE.data, "noexp"))
        push!(leftmenu, explorer_icon(c))
    end
    if ~(haskey(CORE.data, "headless")) && settings_enabled
        push!(rightmenu, settings(c))
    end
    push!(topbar, leftmenu, tabmenu, rightmenu)
    topbar::Component{:div}
end

function topbar_icon(name::String, icon::String)
    ico::Component{:span} = span(name, class = "material-icons topbaricons", text = icon,
     margin = "15px")::Component{:span}
end

function olive_main()
    main = div("olivemain", ex = 0)
    style!(main, "transition" => ".8s", "overflow"  =>  "scroll", "padding" => 2px)
    main::Component{:div}
end

"""
```julia
source_module!(c::Connection, p::Project{<:Any}, name::String)
```
Sources the project's module. This function can be overwritten for a new project to change how the 
`proj[:mod]` is sourced. For example, for `Python` you would likely want to load `PyCall` in each `Module`.
```julia

```
"""
function source_module!(c::Connection, p::Project{<:Any}, name::String = p.id)
    openmods::Vector{String} = c[:OliveCore].pool
    if length(openmods) > 0
        name = openmods[1]
        deleteat!(openmods, 1)
    else
        name = replace(ToolipsSession.gen_ref(10),
    [string(dig) => "" for dig in digits(1234567890)] ...)
    end
    modstr::String = olive_module(name, p[:env])
    Main.evalin(Meta.parse(modstr))
    if haskey(CORE.data, "threads")
        push!(p.data, :thread => CORE.users[getname(c)]["threads"])
        @everywhere include_string(Main, $(modstr))
    end
    mod::Module = getfield(Main, Symbol(name))
    push!(p.data, :mod => mod, :modid => name)
    nothing::Nothing
end

"""
```julia
check!(p::Project{<:Any}) -> ::Nothing
```
`check!` is an open-ended function that is called whenever a 
`Project` is loaded. For this base `Project`, this does absolutely nothing, 
but could be useful for extensions.
```julia

```
"""
function check!(p::Project{<:Any})
    nothing::Nothing
end

"""
```julia
add_to_session(c::Connection, cs::Vector{<:IPyCells.AbstractCell}, 
cm::ComponentModifier, source::String, fpath::String, projpairs::Pair{Symbol, <:Any})
```
This is the function `Olive` uses to load files into projects. This function 
    will find your project's environment, source its module, then add it to the 
    client's page.
```julia

```
"""
function add_to_session(c::Connection, cs::Vector{<:IPyCells.AbstractCell},
    cm::ComponentModifier, source::String, fpath::String, projpairs::Pair{Symbol, <:Any} ...;
    type::String = "olive")
    user = CORE.users[getname(c)]
    all_paths = (begin
        if :path in keys(project.data)
            project[:path]
        end
    end for project in user.environment.projects)
    cldata = user.data
    if ~("recents" in keys(cldata))
        push!(cldata, "recents" => Vector{String}())
    end
    recents::Vector{String} = cldata["recents"]
    if ~(fpath in recents)
        push!(cldata["recents"], fpath)
    end
    if length(recents) > 5
        cldata["recents"]::Vector{String} = recents[2:6]
    end
    if fpath in all_paths
        n_open = length(findall(path -> path == fpath, all_paths))
        source = "$source | $(n_open + 1)"
    end
    fsplit::Vector{SubString} = split(fpath, "/")
    uriabove::String = join(fsplit[1:length(fsplit) - 1], "/")
    environment::String = ""
    projdict::Dict{Symbol, Any} = Dict{Symbol, Any}(:cells => cs,
    :env => environment, :path => fpath, projpairs ...)
    if "Project.toml" in readdir(uriabove)
        environment = uriabove
    else
        if "home" in keys(c[:OliveCore].data)
            environment = c[:OliveCore].data["home"]
            if fpath != c[:OliveCore].data["home"]
                push!(projdict, :path => fpath)
            end
        end
    end
    @async save_settings!(c)
    myproj::Project{<:Any} = Project{Symbol(type)}(source, projdict)
    c[:OliveCore].olmod.Olive.source_module!(c, myproj)
    c[:OliveCore].olmod.Olive.check!(myproj)
    push!(user.environment.projects, myproj)
    tab::Component{:div} = build_tab(c, myproj)
    open_project(c, cm, myproj, tab)
    myproj::Project{<:Any}
end

"""
```julia
open_project(c::Connection, cm::AbstractComponentModifier, proj::Project{<:Any}, tab)
```
This is the function `Olive` uses to load a project into its UI.
```example

```
"""
function open_project(c::Connection, cm::AbstractComponentModifier, proj::Project{<:Any}, tab::Component{:div})
    projects = c[:OliveCore].users[getname(c)].environment.projects
    if  ~(proj in projects)
        push!(projects, proj)
    end
    n_projects::Int64 = length(projects)
    projbuild = build(c, cm, proj)
    inpane2 = findall(p::Project{<:Any} -> if haskey(p.data, :pane) p[:pane] == "two" else false end, projects)
    if length(inpane2) == 0
        proj.data[:pane]::String = "one"
        set_children!(cm, "pane_one", [projbuild])
        append!(cm, "pane_one_tabs", tab)
        [begin
            if pro.id != proj.id
                style_tab_closed!(cm, pro)
            end
        end  for pro in projects]
        return
    end
    if(cm["olivemain"]["pane"] == "1")
        inpane = findall(p::Project{<:Any} -> p[:pane] == "one", projects)
        proj.data[:pane]::String = "one"
        append!(cm, "pane_one", projbuild)
        append!(cm, "pane_one_tabs", tab)
        [begin
        if projects[p].id != proj.id
            style_tab_closed!(cm, projects[p])
        end
        end  for p in inpane]
    else
        proj.data[:pane]::String = "two"
        append!(cm, "pane_two", projbuild)
        append!(cm, "pane_two_tabs", tab)
        [begin
        if projects[p].id != proj.id
            style_tab_closed!(cm, projects[p])
        end
        end  for p in inpane2]
    end
end
#==output[code]
inputcell_style (generic function with 1 method)
==#
#==|||==#
"""
````
style_tab_closed!(cm::ComponentModifier, proj::Project{<:Any}) -> ::Nothing
````
This function is called on a project whenever its tab is minimized.
    All that happens here for most projects is that the tab changes style.
```

```
"""
function style_tab_closed!(cm::ComponentModifier, proj::Project{<:Any})
    cm["tab$(proj.id)"] = "class" => "tabclosed"
end

function style_tab_closed!(cm::ComponentModifier, proj::Project{:include})
    style!(cm, """tab$(proj.id)""", "background-color" => "#1E5631")
end

function style_tab_closed!(cm::ComponentModifier, proj::Project{:module})
    style!(cm, """tab$(proj.id)""", "background-color" => "darkred")
end

"""
```julia
switch_pane!(c::Connection, cm::AbstractComponentModifier, proj::Project{<:Any}) -> ::Nothing
```
This function is called on a project whenever its tab is minimized.
    All that happens here for most projects is that the tab changes style.
```julia

```
"""
function switch_pane!(c::Connection, cm::AbstractComponentModifier, proj::Project{<:Any})
    projects::Vector = c[:OliveCore].users[getname(c)].environment.projects
    name::String = proj.id
    if proj.data[:pane]::String == "one"
        pane = "two"
    else
        pane = "one"
    end
    proj.data[:pane]::String = pane
    inpane = findall(p::Project{<:Any} -> p[:pane] == proj[:pane], projects)
    [begin
    if projects[e].id != proj.id 
            style_tab_closed!(cm, projects[e])
        end
    end  for e in inpane]
    remove!(cm, "$name")
    remove!(cm, "tab$(name)")
    set_children!(cm, "pane_$pane", [build(c, cm, proj)])
    append!(cm, "pane_$(pane)_tabs", build_tab(c, proj))
    if pane == "one"
        if length(findall(p::Project{<:Any} -> p[:pane] == "two", projects)) == 0
            style!(cm, "pane_container_two", "width" => 0percent, "opacity" => 0percent)
        end
    else
        if length(findall(p::Project{<:Any} -> p[:pane] == "two", projects)) == 1
            style!(cm, "pane_container_two", "width" => 100percent, "opacity" => 100percent)
        end
    end
end

"""
```julia
re_source!(c::Connection, p::Project{<:Any}) -> ::Nothing
```
Removes the project's current `Module` and calls `source_module!`, thereby creating a new empty active 
environment.
```julia
```
"""
re_source!(c::Connection, p::Project{<:Any})::Nothing = begin
    delete!(p.data, :mod)
    source_module!(c, p)
end

"""
```julia
tab_controls(c::Connection, p::Project{<:Any}) -> ::Component{:div}
```
Returns the default set of tab controls for a `Project`.
```julia
```
"""
function tab_controls(c::Connection, p::Project{<:Any})
    fname::String = p.id
    closebutton::Component{:span} = span("$(fname)close", text = "close", class = "tablabel")
    on(c, closebutton, "click") do cm2::ComponentModifier
        close_project(c, cm2, p)
    end
    restartbutton::Component{:span} = span("$(fname)restart", text = "restart_alt", class = "tablabel")
    on(c, restartbutton, "click") do cm2::ComponentModifier
        re_source!(c, p)
        olive_notify!(cm2, "module for $(fname) re-sourced")
    end
    add_button::Component{:span} = span("$(fname)add", text = "add_circle", class = "tablabel")
    on(c, add_button, "click") do cm2::ComponentModifier
        cells = p[:cells]
        new_cell = Cell("creator", "")
        push!(cells, new_cell)
        append!(cm2, fname, build(c, cm2, new_cell, p))
        focus!(cm2, "cell$(new_cell.id)")
    end
    runall_button::Component{:span} = span("$(fname)run", text = "start", class = "tablabel")
    on(c, runall_button, "click") do cm2::ComponentModifier
        step_evaluate(c, cm2, p)
    end
    switchpane_button::Component{:span} = span("$(fname)switch", text = "compare_arrows", class = "tablabel")
    on(c, switchpane_button, "click") do cm2::ComponentModifier
        switch_pane!(c, cm2, p)
    end
    style!(closebutton, "font-size"  => 17pt, "color" => "red")
    return([add_button, switchpane_button, restartbutton, runall_button, closebutton])::Vector{<:AbstractComponent}
end

function tab_controls(c::Connection, p::Project{:include})
    fname = p.id
    closebutton = topbar_icon("$(fname)close", "close")
    on(c, closebutton, "click") do cm2::ComponentModifier
        close_project(c, cm2, p)
    end
    add_button = topbar_icon("$(fname)add", "add_circle")
    on(c, add_button, "click") do cm2::ComponentModifier
        cells = p[:cells]
        new_cell = Cell("creator", "")
        push!(cells, new_cell)
        append!(cm2, fname, build(c, cm2, new_cell, p))
    end
    runall_button = topbar_icon("$(fname)run", "start")
    on(c, runall_button, "click") do cm2::ComponentModifier
        step_evaluate(c, cm2, p)
    end
    switchpane_button = topbar_icon("$(fname)switch", "compare_arrows")
    on(c, switchpane_button, "click") do cm2::ComponentModifier
        switch_pane!(c, cm2, p)
    end
    style!(closebutton, "font-size"  => 17pt, "color" => "red")
    style!(switchpane_button, "font-size"  => 17pt, "color" => "white")
    style!(add_button, "font-size"  => 17pt, "color" => "white")
    style!(runall_button, "font-size"  => 17pt, "color" => "white")
    [add_button, switchpane_button, runall_button, closebutton]
end

function tab_controls(c::Connection, p::Project{:module})
    fname = p.id
    closebutton = topbar_icon("$(fname)close", "close")
    on(c, closebutton, "click") do cm2::ComponentModifier
        close_project(c, cm2, p)
    end
    add_button = topbar_icon("$(fname)add", "add_circle")
    on(c, add_button, "click") do cm2::ComponentModifier
        cells = p[:cells]
        new_cell = Cell("creator", "")
        push!(cells, new_cell)
        append!(cm2, fname, build(c, cm2, new_cell, p))
    end
    runall_button = topbar_icon("$(fname)run", "start")
    on(c, runall_button, "click") do cm2::ComponentModifier
        step_evaluate(c, cm2, p)
    end
    switchpane_button = topbar_icon("$(fname)switch", "compare_arrows")
    on(c, switchpane_button, "click") do cm2::ComponentModifier
        switch_pane!(c, cm2, p)
    end
    style!(closebutton, "font-size"  => 17pt, "color" => "red")
    style!(switchpane_button, "font-size"  => 17pt, "color" => "white")
    style!(add_button, "font-size"  => 17pt, "color" => "white")
    style!(runall_button, "font-size"  => 17pt, "color" => "white")
    [add_button, switchpane_button, runall_button, closebutton]
end

"""
```julia
step_evaluate(c::Connection, cm::AbstractComponentModifier, proj::Project{<:Any}, e::Int64 = 0)
```
Step evaluate evaluates each cell in descending order, typical to that of notebook
convention. `e` in this case is the specific number of cells to evaluate.
```

```
"""
function step_evaluate(c::Connection, cm::AbstractComponentModifier, proj::Project{<:Any}, e::Int64 = 0)
    e += 1
    if length(proj.data[:cells]) == 0
        return
    end
    on(c, cm, 100) do cm2::ComponentModifier
        evaluate(c, cm2, proj.data[:cells][e], proj)
        if e == length(proj.data[:cells]) - 1
            return
        end
        step_evaluate(c, cm2, proj, e)
    end
end

"""
```julia
close_project(c::Connection, cm::AbstractComponentModifier, proj::Project{<:Any})
```
This is the function `Olive` uses to close the project in the UI.
```julia

```
"""
function close_project(c::Connection, cm2::AbstractComponentModifier, proj::Project{<:Any})
    name::String = proj.id
    projs::Vector{Project} = c[:OliveCore].users[getname(c)].environment.projects
    n_projects::Int64 = length(projs)
    set_children!(cm2, "pane_$(proj.data[:pane])", Vector{Servable}())
    remove!(cm2, "tab$(name)")
    if(n_projects == 1)
        remove!(cm2, proj.id)
    elseif n_projects == 2
        lastproj = findfirst(pre -> pre.id != proj.id, projs)
        lastproj = projs[lastproj]
        if(lastproj.data[:pane] == "two")
            lpjn = lastproj.id
            remove!(cm2, lpjn)
            remove!(cm2, "tab$lpjn")
            lastproj.data[:pane]::String = "one"
            append!(cm2, "pane_one_tabs", build_tab(c, lastproj))
                        set_children!(cm2, "pane_one", Vector{Servable}([
                Base.invokelatest(c[:OliveCore].olmod.build, c, cm2, lastproj
            )]))
        end
        style!(cm2, "pane_container_two", "width" => 0percent, "opacity" => 0percent)  
    end
    pos = findfirst(pro -> pro.id == proj.id,
    projs)
    push!(c[:OliveCore].pool, proj.id)
    olive_notify!(cm2, "project $(proj.name) closed", color = "blue")
    empty_module!(c, proj)
    deleteat!(projs, pos)
    proj = nothing
    nothing::Nothing
end

"""
```julia
empty_module!(c::Connection, proj::Project{<:Any}) -> ::Nothing
```
Completely removes a `Module` from a project, adding it back to the `OliveCore` pool.
```julia

```
"""
function empty_module!(c::Connection, proj::Project{<:Any})
    if ~(haskey(proj.data, :mod))
        return(nothing)
    end
    push!(c[:OliveCore].pool, proj.id)
    if haskey(proj.data, :thread)
        modstr::String = olive_module(proj.id, p[:env])
        @everywhere include_string(Main, $(modstr))
    end
    mod = proj[:mod]
    re_source!(c, proj)
    Base.GC.gc()
    nothing::Nothing
end

"""
```julia
build_findbar(c::AbstractConnection, cm::AbstractComponentModifier, cells::Vector{Cell}, 
    proj::Project{<:Any}, found_items::Dict{String, Vector{UnitRange{Int64}}}) -> ::Component{:div}
```
Builds the `find` bar used for searching `Olive`cells.
```julia

```
"""
function build_findbar(c::AbstractConnection, cm::AbstractComponentModifier, cells::Vector{Cell}, 
    proj::Project{<:Any}, found_items::Dict{String, Vector{UnitRange{Int64}}})
    find_box = textdiv("findbox", text = "", class = "searchboxes")
    replace_box = textdiv("replacebox", text = "", class = "searchboxes")
    style!(replace_box, "margin-top" => 5px)
    pos_pre = a(text = "   in project: ")
    style!(pos_pre, "color" => "lightgreen")
    position_indicator = a("find-position", text = "0/0")
    common = ("color" => "white", "font-weight" => "bold", "font-size" => 13pt)
    style!(position_indicator, common ...)
    cell_pos_pre = a(text = "   in cell: ")
    style!(cell_pos_pre, "color" => "lightpink")
    cell_position_indicator = a("find-cell", text = "0/0")
    style!(cell_position_indicator, common ...)
    selected_text = ""
    count = 0
    total = 0
    prev_cell = ""
    active_key = 0
    inner_count = 0
    item_keys = nothing
    km = ToolipsSession.KeyMap()
    find_f = cm2::ComponentModifier -> begin
        active_text::String = cm2["findbox"]["text"]
        if length(keys(found_items)) == 0 || (selected_text != "" && active_text != selected_text)
            selected_text = active_text
            cells_containing = findall(cell::Cell{<:Any} -> contains(cell.source, selected_text), cells)
            found_items = Dict{String, Vector{UnitRange{Int64}}}(begin
                cell = cells[cellindex]
                positions = findall(selected_text, cell.source)
                cell.id => positions
            end for cellindex in sort(cells_containing))
            for (cell_key, positions) in found_items
                hl = get_highlighter(c, cells[cell_key])
                style!(hl, :pfounds, "color" => "black", "background-color" => "lightgreen", "border-radius" => 1px)
                for pos in positions
                    push!(hl, pos => :pfounds)
                end
                cell_highlight!(c, cm2, cells[cell_key], proj)
            end
    
            active_key = 1
            total = sum([length(k) for k in values(found_items)])
            item_keys = [keys(found_items) ...]
            count = 0
            inner_count = 0
        end
    
        if total > 0
            count += 1
            inner_count += 1
            active_cell = item_keys[active_key]
            active_cell_items = found_items[active_cell]
            n_active_items = length(active_cell_items)
            if inner_count > n_active_items
                active_key += 1
                if active_key > length(item_keys)
                    active_key = 1
                    count = 1
                    inner_count = 1
                    active_cell = item_keys[1]
                else
                    active_cell = item_keys[active_key]
                    inner_count = 1
                end
                active_cell_items = found_items[active_cell]
                n_active_items = length(active_cell_items)
            end
            position = active_cell_items[inner_count]
    
            hl = get_highlighter(c, cells[active_cell])
            style!(hl, :found, "color" => "white", "font-weight" => "bold", "background-color" => "#D90166", "border-radius" => 1px)
            style!(hl, :founds, "color" => "black", "background-color" => "lightpink", "border-radius" => 1px)
            # Override "pfounds" in the selected cell for better visibility
            push!(hl, position => :found)
            for pos in filter(p -> p != position, active_cell_items)
                push!(hl, pos => :founds)
            end
            cell_highlight!(c, cm2, cells[active_cell], proj)
    
            if prev_cell != "" && inner_count == 1
                current_prev = prev_cell
                on(c, cm2, 150) do cm3::ComponentModifier
                    hl = get_highlighter(c, cells[current_prev])
                    style!(hl, :pfounds, "color" => "black", "background-color" => "lightgreen", "border-radius" => 1px)
                    for pos in found_items[current_prev]
                        push!(hl, pos => :pfounds)
                    end
                    cm3["cell$current_prev"] = "class" => get_cell_class(cells[current_prev])
                    cell_highlight!(c, cm3, cells[current_prev], proj)
                    current_prev = nothing
                end
            end
            ToolipsSession.scroll_to!(cm2, "cell$active_cell")
            prev_cell = active_cell
            cm2["cell$active_cell"] = "class" => "input_cell inputselected"
        else
            count = 0
        end
        set_text!(cm2, "find-position", "$count/$total")
        set_text!(cm2, "find-cell", "$inner_count/$n_active_items")
    end
    ToolipsSession.bind(find_f, km, "Enter", prevent_default = true)
    ToolipsSession.bind(km, "Tab") do cm2::ComponentModifier
        focus!(cm2, "replacebox")
    end
    ToolipsSession.bind(km, "F", :ctrl, :shift, prevent_default = true) do cm2::ComponentModifier
        remove!(cm2, "findbar")
        if prev_cell != ""
            current_prev = prev_cell
            on(c, cm2, 150) do cm3::ComponentModifier
                cm3["cell$current_prev"] = "class" => get_cell_class(cells[current_prev])
                cell_highlight!(c, cm3, cells[current_prev], proj)
            end
        end
        prev_cell, inner_count = nothing, nothing
        count, total, selected_text = nothing, nothing, nothing
    end
    replace_f = cm2::ComponentModifier -> begin
      if selected_text == ""
            olive_notify!(cm2, "No found items to replace, use find first with `Enter`", color = "darkred")
            return
        end
        replace_text = cm2["replacebox"]["text"]
        for (cell_key, _) in found_items
            cell_object::Cell{<:Any} = cells[cell_key]
            cell_object.source = replace(cell_object.source, selected_text => replace_text)
            set_text!(cm2, "cell$cell_key", cell_object.source)
            on(c, cm2, 100) do cm::ComponentModifier
                cell_highlight!(c, cm, cell_object, proj)
            end
        end
        olive_notify!(cm2, "Replaced all occurrences of '$selected_text' across found items", color = "darkgreen")
        found_items = Dict{String, Vector{UnitRange{Int64}}}()
    end
    ToolipsSession.bind(replace_f, km, "Enter", :shift)
    replace_cell_f = cm2::ComponentModifier -> begin
        if selected_text == ""
            olive_notify!(cm2, "no found items to replace, use find fist with `Enter`", color = "darkred")
            return
        end
        active_cell = item_keys[active_key]
        replace_text = cm2["replacebox"]["text"]
        cell_object::Cell{<:Any} = cells[active_cell]
        cell_object.source = replace(cell_object.source, selected_text => replace_text)
        set_text!(cm2, "cell$active_cell", cell_object.source)
        on(c, cm2, 100) do cm::ComponentModifier
            cell_highlight!(c, cm, cell_object, proj)
        end
        found_items = Dict{String, Vector{UnitRange{Int64}}}()
    end
    ToolipsSession.bind(replace_cell_f, km, "A", :ctrl, :shift, prevent_default = true)
    ToolipsSession.bind(c, cm, find_box, km)
    delete!(km.keys, "Tab")
    ToolipsSession.bind(km, "Tab") do cm2::ComponentModifier
        focus!(cm2, "findbox")
    end
    ToolipsSession.bind(c, cm, replace_box, km)
    texts_box = div("findtexts", children = [find_box, replace_box])
    style!(texts_box, "display" => "inline-block", "width" => 45percent)
    button_find = button("find_b", text = "find (enter)")
    button_replace = button("rep_b", text = "replace in project (shift + enter)")
    button_rep_in_cell = button("rep_cell", text = "replace in cell (ctrl + shift + A)")
    on(find_f, c, button_find, "click")
    on(replace_f, c, button_replace, "click")
    on(replace_cell_f, c, button_rep_in_cell, "click")
    button_box = div("button_box", children = [button_find, button_replace, pos_pre, position_indicator, 
    button_rep_in_cell, cell_pos_pre, cell_position_indicator])
    style!(button_box, "display" => "inline-block", "width" => 45percent)
    mainbar = div("findbar", children = [texts_box, button_box], class = "findcontainer")
    mainbar
end

"""
```julia
build_tab(c::Connection, p::Project{<:Any}; hidden::Bool = false) -> ::Component{:div}
```
Creates a tab for the project, including its controls. These tabs are then provided 
    to `open_project`.
```

```
"""
function build_tab(c::Connection, p::Project{<:Any}; hidden::Bool = false)
    fname::String = p.id
    tabbody::Component{:div} = div("tab$(fname)", class = "tabopen")
    if(hidden)
        tabbody[:class]::String = "tabclosed"
    end
    tablabel::Component{:a} = a("tablabel$(fname)", text = p.name, class = "tablabel")
    push!(tabbody, tablabel)
    on(c, tabbody, "click") do cm::ComponentModifier
        if p.id in cm
            return
        end
        projects::Vector{Project{<:Any}} = CORE.users[getname(c)].environment.projects
        inpane = findall(proj::Project{<:Any} -> proj[:pane] == p[:pane], projects)
        [begin
            if projects[e].id != p.id 
                style_tab_closed!(cm, projects[e])
            end
            nothing
        end  for e in inpane]
        projbuild::Component{:div} = build(c, cm, p)
        set_children!(cm, "pane_$(p[:pane])", [projbuild])
        cm["tab$(fname)"] = :class => "tabopen"
        if length(p.data[:cells]) > 0
            focus!(cm, "cell$(p[:cells][1].id)")
        end
    end
    on(c, tabbody, "dblclick") do cm::ComponentModifier
        if "$(fname)dec" in cm
            return
        end
        decollapse_button::Component{:span} = span("$(fname)dec", text = "arrow_left", class = "tablabel")
        on(c, decollapse_button, "click") do cm2::ComponentModifier
            remove!(cm2, "$(fname)close")
            remove!(cm2, "$(fname)add")
            remove!(cm2, "$(fname)restart")
            remove!(cm2, "$(fname)run")
            remove!(cm2, "$(fname)switch")
            remove!(cm2, "$(fname)dec")
        end
        style!(decollapse_button, "color" => "blue")
        controls::Vector{<:AbstractComponent} = tab_controls(c, p)
        insert!(controls, 1, decollapse_button)
        [begin append!(cm, tabbody, serv); nothing end for serv in controls]
    end
    tabbody::Component{:div}
end

"""
```julia
save_project(c::Connection, cm2::AbstractComponentModifier, p::Project{<:Any}) -> ::Nothing
```
Saves a project to the URI contained within the :path key of its `data` field.
```julia

```
"""
function save_project(c::Connection, cm2::AbstractComponentModifier, p::Project{<:Any})
    save_split = split(p.name, ".")
    if ~(:path in keys(p.data))
        save_project_as(c, cm2, p)
        return
    end
    if length(save_split) < 2
        save_type = "Any"
    else
        save_type = join(save_split[2:length(save_split)])
    end
    if :export in keys(p.data)
        pe::ProjectExport{<:Any} = ProjectExport{Symbol(p[:export])}()
    else
        pe = ProjectExport{Symbol(save_type)}()
    end
    ret = olive_save(p, pe)
    if isnothing(ret)
        olive_notify!(cm2, "project $(p.name) saved", color = "green")
    else
        olive_notify!(cm2, "file $(p.name) failed to save.", color = "red")
    end
end

"""
```julia
save_project(c::Connection, cm2::AbstractComponentModifier, p::Project{<:Any}) -> ::Nothing
```
Saves a project to a new path.
```

```
"""
function save_project_as(c::Connection, cm::AbstractComponentModifier, p::Project{<:Any})
    creatorcell::Cell{:creator} = Cell("creator", "", "save")
    open_project_explorer!(cm)
    insert!(cm, "pwdmain", 2, build(c, creatorcell, p, cm))
end

function olive_loadicon()
    circ = Component{:circle}("circloader", r = 7, cx = 10, cy = 10)
    style!(circ, "fill" => "#ef6292")
    myimg = svg("olive-loader", width = 20, height = 20, children = [circ], 
    style = "transition:600ms;")
    style!(circ, spin_forever())
    myimg
end

"""
```julia
olive_confirm_dialog(f::Function, c::AbstractConnection, message::String) -> ::Component{:div}
```
Creates a confirmation dialog that will only run `f` if `ok` is pressed.
```julia

```
"""
function olive_confirm_dialog(f::Function, c::AbstractConnection, message::String)
    dialog_text::Component{:p} = p("dialog-text", text = message, class = "dialogtext")
    okbutton::Component{:button} = button("okdialog", text = "ok")
    cancel_button::Component{:button} = button("canceldialog", text = "cancel")
    button_box::Component{:div} = div("buttondialog", align = "right", children = [cancel_button, okbutton])
    on(cancel_button, "click") do cm::ClientModifier
        remove!(cm, "confirm-dialog")
    end
    on(c, okbutton, "click") do cm::ComponentModifier
        f(cm)
        remove!(cm, "confirm-dialog")
    end
    confirm_dialog::Component{:div} = div("confirm-dialog", children = [dialog_text, button_box], class = "confdialog")
    confirm_dialog::Component{:div}
end

include("Cells.jl")
