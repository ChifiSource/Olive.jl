"""
Created in February, 2022 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
by team
[toolips](https://github.com/orgs/ChifiSource/teams/toolips)
This software is MIT-licensed.
#### | olive | - | pure julia notebook IDE
Welcome to olive! olive is an integrated development environment written in
julia and for other languages and data editing. Crucially, olive is abstract
    in definition and allows for the creation of unique types for names.
"""
module Olive

import Base: write, display, getindex, setindex!, string, showerror
using IPyCells
using IPyCells: Cell
using Pkg
using Toolips
import Toolips: AbstractRoute, AbstractConnection, AbstractComponent, Crayon, write!, Modifier
using ToolipsSession
import ToolipsSession: bind!, AbstractComponentModifier
using ToolipsDefaults
using ToolipsMarkdown
using ToolipsBase64
using TOML
using Revise
#==nothing#=-=#code==#
# --
global evalin(ex::Any) = begin
    Main.eval(ex)
end
export evalin
#==nothing#=-=#code==#
# --
function version()
    srcdir = replace(@__DIR__, "\\" => "/")
    splits = split(srcdir, "/")
    oliveprojdir = join(splits[1:length(splits) - 1], "/")
    projinfo = TOML.parse(read(oliveprojdir * "/Project.toml", String))
    projinfo["version"]
end
#==nothing#=-=#code==#
# --
function olive_module(modname::String, environment::String)
    """module $(modname)
    using Pkg

    function evalin(ex::Any)
            Pkg.activate("$environment")
            ret = eval(ex)
    end
    end"""
end
#==nothing#=-=#code==#
# --
function olive_motd()
    recent_str::String = """# olive editor
    ##### version $(version()) (pre-release)
    - Fixed Windows (the OS) directories (replaced backslashes with slashes).
    - Added new `Environment` to encompass projects.
    - Added parametric `Project` methods `source_module!` + `check!`.
    - Fixed event reference loss in linker.
    - **include** cells.
    - Changed REPL cells -- `Enter` to run, `Shift` + `Enter` runs to next cell.
    **note** that this requires `ToolipsSession` **0.3.4+**.
     If using an earlier version, both `Shift` + `Enter` and `Enter` will do
     the same thing -- run the cell.
    - Substantial improvements to **helprepl** and **pkgrepl** cells.
    - Fixed checkbox binding population in settings menu.
    - Updated **creator** cells to focus on new cell.
    - Save as binding in file menu.
    - Added drag indicator to file cells (no drag yet).
    - Removed last evaluation key from cell.
    - Updated directory styles.
    - Changed windowing from in-line to pane view
    - prevented defaults
    - added window key-bindings, shift focus (`shift + ArrowUp`)
    - Added syntax highlighting colors to settings panel.
    - Added workspace manager, directory additions.
    - Added pane-based window management
    - Revised highlighting
    - Changed extension dispatches
    - Changed cell dispatches to include projects
    - olive now opens any file
    This version was mainly focused on fixing the issues associated with
    the initial `0.0.8` release. There have also been substantial revisions 
    to windowing. There is now a new work-space manager with a split-pane view.
    There were also some slight tweaks made to the data structure within Olive. 
    Some cells have received updates, along with the addition of **include** cells, 
    **module** cells, and sub-projects.
    #### moving forward
    With the step from `0.0.9` to `0.1.0`, Olive is going to focus primarily on 
    memory management and performance, with a secondary focus on 
    making the features that olive already has better. This feature will 
    mostly seek to wrap up all that is incomplete in this release.
    """
    tmd("olivemotd", recent_str)::Component{<:Any}
end
#==nothing#=-=#code==#
# --
include("Core.jl")
#==nothing#=-=#code==#
# --
include("UI.jl")
#==nothing#=-=#code==#
# --
"""
### route ("/") (main)
--------------------
This is the function/Route which runs olive's "session" page, the main editor
    for olive. If you are providing this to a server directly with olive
functionality. Note that by  simply providing any server with the `OliveCore`
extension, this route, and also  ways to  populate directories...

It's  pretty smart because with `create` you could  very easily build  a whole
system out of this. I **am** putting this  in  the documentation so you may check
it out. Endemic of future projects? **definitely**
##### example
```
```
"""
main = route("/") do c::Connection
    args = getargs(c)
    if ~(:key in keys(args))
        coverimg::Component{:img} = olive_cover()
        olivecover = div("topdiv", align = "center")
        logbutt = button("requestaccess", text = "request access")
        on(c, logbutt, "click") do cm::ComponentModifier
            c[:Logger].log(" someone is trying to login to olive! is this you?")
            y = readline()
            if y == "y"
                c[:Logger].log(" okay, logging in as root.")
                key = ToolipsSession.gen_ref(16)
                push!(c[:OliveCore].client_keys[key] => c[:OliveCore].data["root"])
                redirect!(cm, "/?key=$(key)")
            end
        end
        push!(olivecover, coverimg,
        h("mustconfirm", 2, text = "request access (no key)"), logbutt)
        write!(c, olivecover)
        return
    end
    if ~(args[:key] in keys(c[:OliveCore].client_keys))
        write!(c, "bad key.")
        return
    end
    uname = c[:OliveCore].client_keys[args[:key]]
    if ~(getip(c) in keys(c[:OliveCore].names))
        push!(c[:OliveCore].names, getip(c) => uname)
    end
    c[:OliveCore].names[getip(c)] = uname
    # check for environment, if none load.
    envsearch = findfirst(e::Environment -> e.name == uname, c[:OliveCore].open)
    if isnothing(envsearch)
        cells = Vector{Cell}([Cell(1, "versioninfo", "")])
        env::Environment = Environment(getname(c))
        env.pwd = c[:OliveCore].data["wd"]
        pwd_direc = Directory(env.pwd)
        projdict::Dict{Symbol, Any} = Dict{Symbol, Any}(:cells => cells,
        :pane => "one", :env => c[:OliveCore].data["home"])
        myproj::Project{<:Any} = Project{:olive}("release notes", projdict)
        Base.invokelatest(c[:OliveCore].olmod.Olive.source_module!, myproj, 
        c[:OliveCore].data["home"])
        Base.invokelatest(c[:OliveCore].olmod.Olive.check!, myproj)
        push!(env.directories, pwd_direc)
        if c[:OliveCore].data["root"] == getname(c)
            home_direc = Directory(c[:OliveCore].data["home"])
            push!(env.directories, home_direc)
        end
        push!(env.projects, myproj)
        push!(c[:OliveCore].open, env)
    else
        env = c[:OliveCore].open[getname(c)]
    end
     # setup base UI
    write!(c, olivesheet())
    c[:OliveCore].client_data[getname(c)]["selected"] = "session"
    olmod::Module = c[:OliveCore].olmod
    notifier::Component{:div} = olive_notific()
    ui_topbar::Component{:div} = topbar(c)
    style!(ui_topbar, "position" => "sticky")
    ui_explorer::Component{:div} = projectexplorer()
    style!(ui_explorer, "background" => "transparent")
    ui_settings::Component{:section} = settings_menu(c)
    style!(ui_settings, "position" => "sticky")
    ui_explorer[:children] = Vector{Servable}([begin
    Base.invokelatest(olmod.build, c, d, olmod, exp = true)
    end for d in env.directories])
    olivemain::Component{:div} = olive_main()
    olivemain["pane"] = "2"
    pane_one::Component{:section} = section("pane_one")
    pane_one_tabs::Component{:div} = div("pane_one_tabs")
    style!(pane_one_tabs, "display" => "inline", "padding" => 0px, "width" => 50percent)
    pane_two_tabs::Component{:div} = div("pane_two_tabs")
    style!(pane_two_tabs, "display" => "inline", "padding" => 0px, "width" => 50percent)
    pane_container_one::Component{:div} = div("pane_container_one")
    style!(pane_container_one, "width" => 100percent, "overflow" => "hidden", "display" => "inline-block",
    "transition" => 1seconds)
    pane_container_two::Component{:div} = div("pane_container_two")
    style!(pane_container_two, "width" => 0percent, "overflow" => "hidden", "display" => "inline-block",
    "opacity" => 0percent, "transition" => 1seconds)
    on(c, pane_container_one, "click") do cm::ComponentModifier
        cm[olivemain] = "pane" => "1"
    end
    pane_two::Component{:section} = section("pane_two")
    on(c, pane_container_two, "click") do cm::ComponentModifier
        cm[olivemain] = "pane" => "2"
    end
    style!(pane_one, "display" => "inline-block", "width" => 100percent, "overflow-y" => "scroll",
    "overflow-x" => "hidden", "padding" => 0px, "max-height" => 95percent, "border-top-left-radius" => 0px, "border-top-right-radius" => 0px, 
    "border-color" => "#333333")
    style!(pane_two, "display" => "inline-block", "width" => 100percent, "overflow-y" => "scroll",
    "overflow-x" => "hidden", "padding" => 0px, "max-height" => 95percent, "border-top-left-radius" => 0px, "border-top-right-radius" => 0px, 
    "border-color" => "#333333")
    push!(pane_container_one, pane_one_tabs, pane_one)
    push!(pane_container_two, pane_two_tabs, pane_two)
    loadicondiv = div("loaddiv", align = "center")
    style!(loadicondiv, "padding" => 10percent, "transition" => "1.5s")
    push!(loadicondiv, olive_loadicon())
    push!(pane_one, loadicondiv)
    push!(olivemain, pane_container_one, pane_container_two)
    style!(olivemain, "overflow-x" => "hidden", "position" => "relative",
    "width" => 100percent, "overflow-y" => "hidden",
    "height" => 90percent, "display" => "inline-flex")
    bod = body("mainbody")
    style!(bod, "overflow" => "hidden")
    push!(bod, notifier,  ui_explorer, ui_topbar, ui_settings, olivemain)
    script!(c, "load", ["olivemain"], type = "Timeout") do cm::ComponentModifier
        load_extensions!(c, cm, olmod)
        style!(cm, "loaddiv", "opacity" => 0percent)
        ToolipsSession.insert!(cm, "projectexplorer", 1, work_menu(c))
        next!(c, loadicondiv, cm, ["olivemain"]) do cm2::ComponentModifier
            remove!(cm2, "loaddiv")
            switch_work_dir!(c, cm, env.pwd)
            [begin
                window::Component{:div} = Base.invokelatest(olmod.build, c,
                cm2, proj)
                append!(cm2, "pane_$(proj.data[:pane])", window)
                append!(cm2, "pane_$(proj.data[:pane])_tabs", build_tab(c, proj))
            end for proj in env.projects]
            if length(findall(proj -> proj[:pane] == "two", env.projects)) > 0
                style!(cm2, "pane_container_two", "width" => 100percent, "opacity" => 100percent)
            end
        end
    end
    write!(c, bod)
end
#==nothing#=-=#code==#
# --
 """
 ### devmode ("/") (devmode)
 --------------------
This is a route that autoloads an active Olive sourceable module -- in addition
to offering some examples.
 ##### example
 ```
 ```
 """
devmode = route("/") do c::Connection
    
end
#==nothing#=-=#code==#
# --
setup = route("/") do c::Connection
    write!(c, olivesheet())
    bod = body("mainbody")
    cells = [Cell(1, "setup", "welcome to olive"),
    Cell(2, "dirselect", c[:OliveCore].data["home"])]
    built_cells = Vector{Servable}([build(c, cell) for cell in cells])
    bod[:children] = built_cells
    confirm_button = button("confirm", text = "confirm")
    questions = section("questions")
    style!(questions, "opacity" => 0percent, "transition" => 2seconds,
    "transform" => "translateY(50%)")
    push!(questions, h("questions-heading", 2, text = "a few more things ..."))
    opts = [button("no", text = "no"), button("yes", text = "yes")]
    push!(questions, h("questions-defaults", 4, text = "would you like to add OliveDefaults?"))
    push!(questions, p("defaults-explain", text = """this extension adds a documentation browser, 
    style customizer, and autocomplete functionality for code cells."""))
    defaults_q = ToolipsDefaults.button_select(c, "defaults_q", opts)
    push!(questions, defaults_q)
    push!(questions, h("questions-name", 2,
    text = "lastly, a username?"))
    namebox::Component{:div} = ToolipsDefaults.textdiv("namesetup",
    text = "root")
    style!(namebox, "outline" => "none", "background-color" => "darkblue",
    "color" => "white", "font-weight" => "bold")
    on(c, namebox, "click") do cm
        set_text!(cm, "namesetup", "")
    end
    push!(questions, namebox)
    confirm_questions = button("conf-q", text = "confirm")
    on(c, confirm_questions, "click") do cm::ComponentModifier
        dfaults = cm[defaults_q]["value"]
        statindicator = a("statind", text = "okay! i'll get this set up for you.")
        loadbar = ToolipsDefaults.progress("oliveprogress", value = "0")
        style!(loadbar, "webkit-progreess-value" => "pink", "background-color" => "orange",
         "radius" => 4px, "transition" => 1seconds, "width" => 0percent,
         "opacity" => 0percent)
         append!(cm, bod, loadbar)
         append!(cm, questions, br())
         append!(cm, questions, statindicator)
         style!(cm, questions, "border-radius" => 0px)
         next!(c, questions, cm) do cm2
             set_text!(cm2, statindicator, "setting up olive ...")
             style!(cm2, loadbar, "opacity" => 100percent, "width" => 100percent)
             next!(c, loadbar, cm2) do cm3
                 username::String = replace(cm3[namebox]["text"],
                 " " => "_")
                 if ~(isdir(cm["selector"]["text"] * "/olive"))
                     if cm["selector"]["text"] != homedir()
                         srcdir = @__DIR__
                         touch("$srcdir/home.txt")
                         open("$srcdir/home.txt", "w") do o
                             write(o, cm["selector"]["text"])
                         end
                     end
                     create_project(replace(cm["selector"]["text"], "\\" => "/"))
                     config = TOML.parse(read(
                     "$(cm["selector"]["text"])/olive/Project.toml",String))
                     users = Dict{String, Any}(
                     username => Dict{String, Vector{String}}(
                     "group" => ["all", "root"])
                     )
                     push!(config,
                     "olive" => Dict{String, String}("root" => username),
                     "oliveusers" => users)
                     open("$(cm["selector"]["text"])/olive/Project.toml", "w") do io
                         TOML.print(io, config)
                     end
                 end
                 set_text!(cm3, statindicator, "project created !")
                 Pkg.activate("$(cm["selector"]["text"])/olive")
                 Pkg.add("Pkg")
                 Pkg.add(url = "https://github.com/ChifiSource/Olive.jl")
                 cm3[loadbar] = "value" => ".50"
                 style!(cm3, loadbar, "opacity" => 99percent)
                 next!(c, loadbar, cm3) do cm4
                     txt = ""
                     if dfaults == "yes"
                         Pkg.add(
                         url = "https://github.com/ChifiSource/OliveDefaults.jl"
                         ) 
                         txt = txt * "defaults loaded! "
                     end
                     set_text!(cm4, statindicator, txt)
                     cm4[loadbar] = "value" => "1"
                     style!(cm4, loadbar, "opacity" => 100percent)
                     next!(c, loadbar, cm4) do cm5
                         deleteat!(c.routes, 1)
                         deleteat!(c.routes, 1)
                         oc = c[:OliveCore]
                         direc = cm["selector"]["text"]
                         oc.data["home"] = "$direc/olive"
                         source_module!(oc)
                         push!(c.routes, fourofour, main)
                         unamekey = ToolipsSession.gen_ref(16)
                         push!(c[:OliveCore].client_keys, unamekey => username)
                         push!(c[:OliveCore].client_data,
                         "emmy" => Dict{String, String}())
                         redirect!(cm5, "/?key=$(unamekey)")
                     end
                 end
             end
         end
    end
    push!(questions, confirm_questions)
    on(c, confirm_button, "click") do cm::ComponentModifier
        selected = cm["selector"]["text"]
        insert!(questions[:children], 1, h("selector", 1, text = selected))
        [style!(cm, b_cell, "transform" => "translateX(-110%)", "transition" => 2seconds) for b_cell in built_cells]
        style!(cm, confirm_button, "transform" => "translateX(-120%)", "transition" => 2seconds)
        append!(cm, bod, questions)
        next!(c, confirm_button, cm) do cm2
            [remove!(cm2, b_cell) for b_cell in built_cells]
            style!(cm2, questions, "transform" => "translateY(0%)", "opacity" => 100percent)
        end
        #
    end
    push!(bod, confirm_button)
    write!(c, bod)
end
#==nothing#=-=#code==#
# --
fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
#==nothing#=-=#code==#
# --
icons = route("/MaterialIcons.otf") do c::Connection
    srcdir = @__DIR__
    write!(c, Toolips.File(srcdir * "/fonts/MaterialIcons.otf"))
end
mainicon = route("/favicon.ico") do c::Connection
    srcdir = @__DIR__
    write!(c, Toolips.File(srcdir * "/images/favicon.ico"))
end
#==nothing#=-=#code==#
# --
"""
start(IP::String, PORT::Integer, extensions::Vector{Any}); devmode::Bool = false -> ::Toolips.WebServer
--------------------
The start function comprises routes into a Vector{Route} and then constructs
    a ServerTemplate before starting and returning the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000;
    devmode::Bool = false, path::String = homedir())
    homedirec = path
    if devmode
        s = OliveServer(OliveCore("Dev"))
        s.start()
        s[:Logger].log("started new olive server in devmode.")
        return
    end
    srcdir = @__DIR__
    if isfile("$srcdir/home.txt") && path == homedir()
        homedirec = read("$srcdir/home.txt", String)
    end
    oc::OliveCore = OliveCore("olive")
    if Sys.iswindows()
        homedirec = replace(homedirec, "\\" => "/")
    end
    oc.data["home"] = homedirec
    oc.data["wd"] = pwd()
    rootname::String = ""
    rs::Vector{AbstractRoute} = Vector{AbstractRoute}()
    if ~(isdir("$homedirec/olive"))
        rs = routes(setup, fourofour, icons, mainicon)
    else
        try
            config = TOML.parse(read("$homedirec/olive/Project.toml", String))
            Pkg.activate("$homedirec/olive")
            Pkg.instantiate()
            oc.data = config["olive"]
            rootname = oc.data["root"]
            oc.client_data = config["oliveusers"]
            oc.data["home"] = homedirec * "/olive"
            oc.data["wd"] = pwd()
        catch e
            throw(StartError(e, "configuration load", "Failed to load `Project.toml`"))
            @info """If you are unsure why this is happening, the best choice is probably just to start 
            with a fresh Project.toml configuration file. Would you like to recreate your olive configuration file? (y or n)"""
        end
        try
            source_module!(oc)
        catch e
            throw(StartError(e, " module load", "Failed to source olive home module."))
            @info """If you are unsure why this is happening, the best choice is probably just to start 
            with a fresh olive.jl source file. Would you like to recreate your olive source file? (y or n)"""
        end
        rs = routes(fourofour, main, icons, mainicon)
    end
    server = WebServer(IP, PORT, routes = rs, extensions = [OliveLogger(),
    oc, Session(["/"])])
    server.start();
    if rootname != ""
        key = ToolipsSession.gen_ref(16)
        push!(oc.client_keys, key => rootname)
        server[:Logger].log(2,
            "link for $(rootname): http://$(IP):$(PORT)/?key=$key")
    end
    server::Toolips.ToolipsServer
end

struct StartError{E <: Exception} <: Exception
    on::String
    cause::E
    message::String
    function StartError(cause::Exception, on::String, message::String = "")
        new{typeof(cause)}(on, cause, message)
    end
end

function showerror(io::IO, err::StartError{<:Any})
    println(io, """on $(err.on).\n$(err.message)\n$(showerror(io, err.cause))""")
end

#==nothing#=-=#code==#
# --
export OliveCore, build, Pkg, TOML
export OliveExtension, OliveModifier, Cell
#==nothing#=-=#code==#
# --
end # - module
#==output[module]
Olive
==#
#==|||==#
