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
    iconstyle(), hdeps_style(), Toolips.link("oliveicon", rel = "icon",
    href = "/favicon.ico", type = "image/x-icon"), title("olivetitle", text = "olive !"),
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
     "transition" => "0.8s", "overflow-y" => "hidden")
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

function work_menu(c::Connection)
    becell = "workmenu"
    env::Environment = c[:OliveCore].open[getname(c)]
    working_area = section(becell)
    open_heading = h("open$becell", 2, text = "open")
    pinfo_box = div("pinfo$becell")
    pinfo_box[:children] = Vector{Servable}(
    [work_preview(c, p) for p in env.projects]
    )
    dinfo_box = div("dinfo$becell")
    dinfo_box[:children] = Vector{Servable}(
    [work_preview(c, d) for d in env.directories]
    )
    push!(working_area, open_heading, pinfo_box, dinfo_box)
    working_area
end

function work_preview(c::Connection, p::Project{<:Any})
    name = p.id
    preview = div("preview$name")
    style!(preview, "display" => "inline-block", "border-radius" => 0px)
    name_label = a("label$name", text = p.name)
    style!(name_label, "color" => "#A2646F", "display" => "inline-block")
    savebutton = topbar_icon("save$name", "save")
    style!(savebutton, "font-size"  => 20pt, "color" => "gray", 
    "display" => "inline-block")
    on(c, savebutton, "click") do cm::ComponentModifier
        save_project(c, cm, p)
    end
    saveasbutton = topbar_icon("saveas$name", "save_as")
    style!(saveasbutton, "font-size"  => 20pt, "color" => "gray", 
    "display" => "inline-block")
    on(c, saveasbutton, "click") do cm::ComponentModifier
        save_project(c, cm, p)
    end
    push!(preview, name_label, br(), savebutton, saveasbutton)
    preview::Component{:div}
end

function work_preview(c::Connection, d::Directory{<:Any})
    becell = replace(d.uri, "/" => "|")
    preview = div("preview$becell", text = d.uri)
    style!(preview, "background-color" => "#A2646F", "color" => "white", "font-weight" => "bold")
    on(c, preview, "click") do cm::ComponentModifier

    end
    preview::Component{:div}
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

function olive_main()
    main = div("olivemain", ex = 0)
    style!(main, "transition" => ".8s", "overflow"  =>  "scroll", "padding" => 2px)
    main::Component{:div}
end
#==output[code]
olive_main (generic function with 2 methods)
==#
#==|||==#
function source_module!(p::Project{<:Any}, name::String)
    name = replace(ToolipsSession.gen_ref(10),
    [string(dig) => "" for dig in digits(1234567890)] ...)
    modstr = olive_module(name, p[:env])
    mod::Module = Main.evalin(Meta.parse(modstr))
    push!(p.data, :mod => mod)
end

function check!(p::Project{<:Any})

end

#==output[code]
UndefVarError: Cell not defined 
==#
#==|||==#

function add_to_session(c::Connection, cs::Vector{Cell{<:Any}},
    cm::ComponentModifier, source::String, fpath::String;
    type::String = "olive")
    all_paths::Vector{String} = [begin
        project[:path]
    end for project in c[:OliveCore].open[getname(c)].projects]
    if fpath in all_paths
        olive_notify!(cm, "project already open!", color = "red")
        return
    end
    fsplit::Vector{SubString} = split(fpath, "/")
    uriabove::String = join(fsplit[1:length(fsplit) - 1], "/")
    environment::String = ""
    if "Project.toml" in readdir(uriabove)
        environment = uriabove
    else
        environment = c[:OliveCore].data["home"]
    end
    projdict::Dict{Symbol, Any} = Dict{Symbol, Any}(:cells => cs,
    :path => fpath, :env => environment)
    myproj::Project{<:Any} = Project{Symbol(type)}(source, projdict)
    Base.invokelatest(c[:OliveCore].olmod.Olive.source_module!, myproj, source)
    Base.invokelatest(c[:OliveCore].olmod.Olive.check!, myproj)
    push!(c[:OliveCore].open[getname(c)].projects, myproj)
    tab::Component{:div} = build_tab(c, myproj)
    open_project(c, cm, myproj, tab)    
end

function open_project(c::Connection, cm::AbstractComponentModifier, proj::Project{<:Any}, tab::Component{:div})
    projects = c[:OliveCore].open[getname(c)].projects
    n_projects::Int64 = length(projects)
    append!(cm, "pinfoworkmenu", work_preview(c, proj))
    projbuild = build(c, cm, proj)
    if(n_projects == 2)
        style!(cm, "pane_container_two", "width" => 100percent, "opacity" => 100percent)
        proj.data[:pane] = "two"
        append!(cm, "pane_two", projbuild)
        append!(cm, "pane_two_tabs", tab)
        return
    elseif(n_projects == 1)
        proj.data[:pane] = "one"
        append!(cm, "pane_one", projbuild)
        append!(cm, "pane_one_tabs", tab)
        return
    end
    if(cm["olivemain"]["pane"] == "1")
        proj.data[:pane] = "one"
        inpane = findall(p::Project{<:Any} -> p[:pane] == "one", projects)
        [begin
            if projects[p].id != proj.id 
                style!(cm, """tab$(projects[p].id)""", "background-color" => "lightgray")
            end
        end  for p in inpane]
        append!(cm, "pane_one_tabs", tab)
        set_children!(cm, "pane_one", [projbuild])
    else
        proj.data[:pane] = "two"
        inpane = findall(p::Project{<:Any} -> p[:pane] == "two", projects)
        [begin
            if projects[p].id != proj.id 
                style!(cm, """tab$(projects[p].id)""", "background-color" => "lightgray")
            end
        end  for p in inpane]
        append!(cm, "pane_two_tabs", tab)
        set_children!(cm, "pane_two", [projbuild])
    end
end

#==output[code]
UndefVarError: Cell not defined 
==#
#==|||==#

function close_project(c::Connection, cm2::ComponentModifier, proj::Project{<:Any})
    name = proj.id
    fname = replace(name, " " => "")
    projs = c[:OliveCore].open[getname(c)].projects
    n_projects::Int64 = length(projs)
    nname = replace(name, " " => "")
    remove!(cm2, "$nname")
    remove!(cm2, "tab$(nname)")
    remove!(cm2, "preview$(proj.id)")
    if(n_projects == 1)
        # TODO start screen here
    elseif n_projects == 2
        lastproj = findfirst(pre -> pre.id != proj.id, projs)
        lastproj = projs[lastproj]
        if(lastproj.data[:pane] == "two")
            lpjn = lastproj.id
            remove!(cm2, lpjn)
            remove!(cm2, "tab$lpjn")
            lastproj.data[:pane] = "one"
            set_children!(cm2, "pane_one", Vector{Servable}([
                Base.invokelatest(c[:OliveCore].olmod.build, c, cm2, lastproj
            )]))
            append!(cm2, "pane_one_tabs", build_tab(c, lastproj))
        end
        style!(cm2, "pane_container_two", "width" => 0percent, "opacity" => 0percent)  
    end
    pos = findfirst(pro -> pro.id == proj.id,
    projs)
    deleteat!(projs, pos)
    olive_notify!(cm2, "project $(fname) closed", color = "blue")
end

function build_tab(c::Connection, p::Project{<:Any}; hidden::Bool = false)
    name = p.id
    fname = replace(name, " " => "")
    tabbody = div("tab$(fname)")
    style!(tabbody, "border-bottom-right-radius" => 0px,
    "border-bottom-left-radius" => 0px, "display" => "inline-block",
    "border-width" => 2px, "border-color" => "#333333", "border-bottom" => 0px,
    "border-style" => "solid", "margin-bottom" => "0px", "cursor" => "pointer",
    "margin-left" => 0px, "transition" => 1seconds)
    if(hidden)
        style!(tabbody, "background-color" => "gray")
    end
    tablabel = a("tablabel$(fname)", text = p.name)
    style!(tablabel, "font-weight" => "bold", "margin-right" => 5px,
    "font-size"  => 13pt, "color" => "#A2646F")
    push!(tabbody, tablabel)
    on(c, tabbody, "click") do cm::ComponentModifier
        if ~("$(fname)close" in keys(cm.rootc))
            closebutton = topbar_icon("$(fname)close", "close")
            on(c, closebutton, "click") do cm2::ComponentModifier
                close_project(c, cm2, p)
            end
            restartbutton = topbar_icon("$(fname)restart", "restart_alt")
            on(c, restartbutton, "click") do cm2::ComponentModifier
                new_name = string(split(fname, ".")[1])
                myproj = c[:OliveCore].open[getname(c)][fname]
                delete!(myproj.data, :mod)
                source_module!(myproj, new_name)
                olive_notify!(cm2, "module for $(fname) re-sourced")
            end
            add_button = topbar_icon("$(fname)add", "add_circle")
            on(c, add_button, "click") do cm2::ComponentModifier
                cells = c[:OliveCore].open[getname(c)][fname][:cells]
                new_cell = Cell(length(cells) + 1, "creator", "")
                push!(cells, new_cell)
                append!(cm2, fname, build(c, cm2, new_cell, cells, fname))
            end
            runall_button = topbar_icon("$(fname)run", "start")
            on(c, runall_button, "click") do cm2::ComponentModifier
                cells = c[:OliveCore].open[getname(c)][fname][:cells]
                [begin
                try
                    evaluate(c, cm2, cell, cells, fname)
                catch
                end
                end for cell in cells]
            end
            projects = c[:OliveCore].open[getname(c)].projects
            inpane = findall(proj::Project{<:Any} -> proj[:pane] == p[:pane], projects)
            [begin
                if projects[e].id != p.id 
                    style!(cm, """tab$(projects[e].id)""", "background-color" => "lightgray")
                    newtablabel = a("tab$label", text = p.name)
                    style!(newtablabel, "font-weight" => "bold", "margin-right" => 5px,
                    "font-size"  => 13pt, "color" => "#A2646F")
                    set_children!(cm, """tab$(projects[e].id)""", [newtablabel])
                end
            end  for e in inpane]
            projbuild = build(c, cm, p)
            set_children!(cm, "pane_$(p[:pane])", [projbuild])
            style!(cm, tabbody, "background-color" => "white")
            decollapse_button = topbar_icon("$(fname)dec", "arrow_left")
            on(c, decollapse_button, "click") do cm2::ComponentModifier
                remove!(cm2, closebutton)
                remove!(cm2, add_button)
                remove!(cm2, runall_button)
                remove!(cm2, restartbutton)
                remove!(cm2, decollapse_button)
            end
            style!(closebutton, "font-size"  => 17pt, "color" => "red")
            style!(restartbutton, "font-size"  => 17pt, "color" => "gray")
            style!(decollapse_button, "font-size"  => 17pt, "color" => "blue")
            style!(add_button, "font-size"  => 17pt, "color" => "gray")
            style!(runall_button, "font-size"  => 17pt, "color" => "gray")
            append!(cm, tabbody, decollapse_button)
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

function save_project(c::Connection, cm2::ComponentModifier, p::Project{<:Any})
    save_split = split(p.name, ".")
    if length(save_split) < 2
        save_type = "Any"
    else
        save_type = join(save_split[2:length(save_split)])
    end
    savepath = p[:path]
    cells = p[:cells]
    savecell = Cell(1, save_type, p.name, savepath)
    ret = olive_save(cells, savecell)
    if isnothing(ret)
        olive_notify!(cm2, "file $(savepath) saved", color = "green")
    else
        olive_notify!(cm2, "file $(savepath) saved", color = "$ret")
    end
end

function save_project(c::Connection, cm::ComponentModifier, p::Project{<:Any}, path::String)
    save_split = split(p.name, ".")
    if length(save_split) < 2
        save_type = "Any"
    else
        save_type = join(save_split[2:length(save_split)])
    end
    p[:path] = path
    cells = p[:cells]
    savecell = Cell(1, save_type, fname, savepath)
    ret = olive_save(cells, savecell)
    if isnothing(ret)
        olive_notify!(cm2, "file $(savepath) saved", color = "green")
    else
        olive_notify!(cm2, "file $(savepath) saved", color = "$ret")
    end
end
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
