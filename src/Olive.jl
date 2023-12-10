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
#==
code/none
==#
#--
global evalin(ex::Any) = begin
    Main.eval(ex)
end
export evalin
#==
code/none
==#
#--
"""
### Olive 
````
olive_module(modname::String, environment::String) -> ::String
````
------------------
Creates a simple, minimalist `Olive` module. This comes in the form of a `String`, which parsed and evaluated.
#### example
```
mod = eval(Meta.parse(olive_module("mymod", "."))) 
```
"""
function olive_module(modname::String, environment::String)
    """
    baremodule $(modname)
    using Pkg
    using Base
    eval(e::Any) = Core.eval($(modname), e)
    function evalin(ex::Any)
            Pkg.activate("$environment")
            ret = eval(ex)
    end
    end
    """
end
#==
code/none
==#
#--
function olive_motd()
    recent_str::String = """# olive editor
    ##### $(pkgversion(Olive)) (pre-release) (Unstable)
    - **thank you for trying olive !**
    - [github](https://github.com/ChifiSource/Olive.jl)
    - [issues](https://github.com/ChifiSource/Olive.jl/issues)
    """
    tmd("olivemotd", recent_str)::Component{<:Any}
end
#==
code/none
==#
#--
include("Core.jl")
#==
include/none
==#
#--
include("UI.jl")
#==
include/none
==#
#--
function verify_client!(c::Connection)
    args = getargs(c)
    if ~(:key in keys(args))
        coverimg::Component{:img} = olive_cover()
        olivecover::Component{:div} = div("topdiv", align = "center")
        logbutt = button("requestaccess", text = "request access")
        on(c, logbutt, "click") do cm::ComponentModifier
            c[:Logger].log(" someone is trying to login to olive! is this you?")
            y = readline()
            if y == "y"
                c[:Logger].log(" okay, logging in as root.")
                key = ToolipsSession.gen_ref(16)
                push!(c[:OliveCore].client_keys, [key] => c[:OliveCore].data["root"])
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
    uname::String
end
#==
code/none
==#
#--
function load_default_project!(c::Connection)
    cells = Vector{Cell}([Cell(1, "getstarted", "")])
    env::Environment = Environment(getname(c))
    env.pwd = c[:OliveCore].data["wd"]
    pwd_direc::Directory{:pwd} = Directory(env.pwd, dirtype = "pwd")
    projdict::Dict{Symbol, Any} = Dict{Symbol, Any}(:cells => cells,
    :pane => "one", :env => " ")
    sourced_path::String = " "
    if "home" in keys(c[:OliveCore].data)
        push!(projdict, :env => c[:OliveCore].data["home"])
        sourced_path = c[:OliveCore].data["home"]
    end
    myproj::Project{<:Any} = Project{:olive}("get started", projdict)
    c[:OliveCore].olmod.Olive.source_module!(c, myproj, sourced_path)
    push!(env.directories, pwd_direc)
    if c[:OliveCore].data["root"] == getname(c)
        if "home" in keys(c[:OliveCore].data)
            home_direc::Directory{:home} = Directory(c[:OliveCore].data["home"], dirtype = "home")
            push!(env.directories, home_direc)
        end
    end
    push!(env.projects, myproj)
    push!(c[:OliveCore].open, env)
    env::Environment
end
#==
code/none
==#
#--

function build(c::Connection, env::Environment)
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
        olmod.build(c, d)
    end for d in env.directories])
    olivemain::Component{:div} = olive_main()
    olivemain["pane"] = "1"
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
    loadicondiv::Component{:div} = div("loaddiv", align = "center")
    style!(loadicondiv, "padding" => 10percent, "transition" => "1.5s")
    push!(loadicondiv, olive_loadicon())
    push!(pane_one, loadicondiv)
    push!(olivemain, pane_container_one, pane_container_two)
    style!(olivemain, "overflow-x" => "hidden", "position" => "relative",
    "width" => 100percent, "overflow-y" => "hidden",
    "height" => 90percent, "display" => "inline-flex")
    bod::Component{:body} = body("mainbody")
    style!(bod, "overflow" => "hidden")
    push!(bod, notifier,  ui_explorer, ui_topbar, ui_settings, olivemain)
    return(bod, loadicondiv, olmod)
end

#==
code/none
==#
#--
"""
### route ("/") (main)
--- 
This is the function/Route which runs olive's "session" page, the main editor
    for olive.
"""
function session(c::Connection; key::Bool = true)
    uname::String = c[:OliveCore].data["root"]
    if key
        uname = verify_client!(c)
    end
    # check for environment, if none load.
    envsearch = findfirst(e::Environment -> e.name == uname, c[:OliveCore].open)
    if isnothing(envsearch)
        env::Environment = load_default_project!(c)
    else
        env = c[:OliveCore].open[getname(c)]
    end
     # setup base UI
    bod::Component{:body}, loadicondiv::Component{:div}, olmod::Module = build(c, env)
    script!(c, "load", ["olivemain"], type = "Timeout", time = 350) do cm::ComponentModifier
        load_extensions!(c, cm, olmod)
        style!(cm, "loaddiv", "opacity" => 0percent)
        next!(c, loadicondiv, cm, ["olivemain"]) do cm2::ComponentModifier
            remove!(cm2, "loaddiv")
            switch_work_dir!(c, cm2, env.pwd)
            [begin
                append!(cm2, "pane_$(proj.data[:pane])_tabs", build_tab(c, proj))
                if proj.id != env.projects[1].id
                    style_tab_closed!(cm2, proj)
                end
            end for proj in env.projects]
            if length(env.projects) > 0
                window::Component{:div} = olmod.build(c, cm2, env.projects[1])
                append!(cm2, "pane_$(env.projects[1].data[:pane])", window)
                p2i = findfirst(proj -> proj[:pane] == "two", env.projects)
                if ~(isnothing(p2i))
                    style!(cm2, "pane_container_two", "width" => 100percent, "opacity" => 100percent)
                    append!(cm2,"pane_two", olmod.build(c, cm2, env.projects[1]))
                end
            end
        end
    end
    write!(c, bod)
end
#==
code/none
==#
#--
main = route("/", session)
#==
code/none
==#
#--
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
                     if cm["selector"]["text"] != homedir() && ~("path" in keys(c[:OliveCore].data))
                         srcdir = homedir()
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
                         username => Dict{String, String}())
                         c[:OliveCore].data["root"] = username
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
    end
    push!(bod, confirm_button)
    write!(c, bod)
end
#==
code/none
==#
#--
fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
#==
code/none
==#
#--
icons = route("/MaterialIcons.otf") do c::Connection
    srcdir = @__DIR__
    write!(c, Toolips.File(srcdir * "/fonts/MaterialIcons.otf"))
end
mainicon = route("/favicon.ico") do c::Connection
    srcdir = @__DIR__
    write!(c, Toolips.File(srcdir * "/images/favicon.ico"))
end
#==
code/none
==#
#--
"""
### Olive 
````
start(IP::String = "127.0.0.1", PORT::Integer = 8000; devmode::Bool = false, 
path::String = homedir(), free::Bool = false, hostname::String = IP) -> ::Toolips.WebServer
````
------------------
Starts your `Olive` server! This function puts together your `Olive` server and sources your `olive` home. 
Providing `devmode` will launch olive in experimental mode. This is not recommended, especially not for this 
version of `Olive`. Providing `path` will start `Olive` at the provided path. Starting in `free` mode 
will present a headless `Olive` with no `olive` home module.
#### example
```

```
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000;
    path::String = replace(homedir(), "\\" => "/"), hostname::String = IP)
    ollogger::Toolips.Logger = OliveLogger()
    oc::OliveCore = OliveCore("olive")
    rootname::String = ""
    if ~(isdir("$path/olive"))
        setup_olive(path)
    end
    try
        config::Dict{String, <:Any} = TOML.parse(read("$path/olive/Project.toml", String))
        Pkg.activate("$path/olive")
        oc.data = config["olive"]
        rootname = oc.data["root"]
        oc.client_data = config["oliveusers"]
        oc.data["home"] = path * "/olive"
        oc.data["wd"] = pwd()
    catch e
        throw(StartError(e, "configuration load", "Failed to load `Project.toml`"))
        ollogger.log(3, """If you are unsure why this is happening, the best choice is probably just to start 
        with a fresh Project.toml configuration file. Would you like to recreate your olive configuration file? (y or n)""")
    end
    try
        source_module!(oc)
    catch e
        throw(StartError(e, " module load", "Failed to source olive home module."))
            ollogger.log(3, """If you are unsure why this is happening, the best choice is probably just to start 
        with a fresh olive.jl source file.""")
    end
    try
        load_extensions!(oc)
    catch e
        ollogger.log(3, "olive extensions failed to load.")
        showerror(stdout, e)
    end
    rs::Vector{AbstractRoute} = routes(fourofour, main, icons, mainicon)
    server::WebServer = WebServer(IP, PORT, routes = rs, extensions = [ollogger,
    oc, Session(["/"])], hostname = hostname)
    server.start()
    if rootname != ""
        key = ToolipsSession.gen_ref(16)
        push!(oc.client_keys, key => rootname)
        server[:Logger].log(2,
            "link for $(rootname): http://$(IP):$(PORT)/?key=$key")
    end
    server::WebServer
end
#==
code/none
==#
#--
struct StartError{E <: Exception} <: Exception
    on::String
    cause::E
    message::String
    function StartError(cause::Exception, on::String, message::String = "")
        new{typeof(cause)}(on, cause, message)
    end
end
#==
code/none
==#
#--
function showerror(io::IO, err::StartError{<:Any})
    println(io, Toolips.Crayon(foreground = :red), """on $(err.on).\n$(err.message)\n$(showerror(io, err.cause))""")
end
#==
code/none
==#
#--
function rebuild_settings!()

end

function setup_olive(path::String)
    if cm["selector"]["text"] != homedir() && ~("path" in keys(c[:OliveCore].data))
        srcdir = homedir()
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
#==
code/none
==#
#--
export OliveCore, build, Pkg, TOML
export OliveExtension, OliveModifier, Cell
#==
code/none
==#
#--
end # - module
#==output[module]
Olive
==#
#==|||==#
