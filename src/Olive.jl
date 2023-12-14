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
function session(c::Connection; key::Bool = true, default::Function = load_default_project!)
    uname::String = c[:OliveCore].data["root"]
    if key
        uname = verify_client!(c)
    end
    # check for environment, if none load.
    envsearch = findfirst(e::Environment -> e.name == uname, c[:OliveCore].open)
    if isnothing(envsearch)
        env::Environment = default(c)
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
                focus!(cm2, "cell$(env.projects[1].data[:cells][1].id)")
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
    path::String = replace(homedir(), "\\" => "/"), hostname::String = IP, warm::Bool = true)
    ollogger::Toolips.Logger = OliveLogger()
    oc::OliveCore = OliveCore("olive")
    rootname::String = ""
    if ~(isdir("$path/olive"))
        setup_olive(ollogger, path)
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
    if warm
        __precompile__()
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
function restore_defaults!(server::Toolips.WebServer)
    path::String = server[:OliveCore].data["home"]
    root_name::String = server[:OliveCore].data["root"]
    rm("$path/Project.toml"); rm("$path/Manifest.toml")
    Pkg.activate(path)
    Pkg.add("Pkg")
    Pkg.add("Olive")
    config::Dict{String, Any} = TOML.parse(read(
    "$path/Project.toml",String))
    users::Dict{String, Any} = Dict{String, Any}(
        username => Dict{String, Vector{String}}(
        "group" => ["all", "root"])
        )
    push!(config,
        "olive" => Dict{String, String}("root" => username),
        "oliveusers" => users)
    open("$path/olive/Project.toml", "w") do io
        TOML.print(io, config)
    end
    server[:Logger].log("restored olive settings to defaults!")
end

function setup_olive(logger::Toolips.Logger, path::String)
    logger.log("welcome to olive! to set up olive, please provide a name.")
    print("name yourself: ")
    username::String = readline()
    logger.log("creating $username's `olive` ...")
    create_project(replace(path, "\\" => "/"))
    config::Dict{String, Any} = TOML.parse(read(
    "$path/olive/Project.toml",String))
    logger.log("creating user configuration")
    users::Dict{String, Any} = Dict{String, Any}(
    username => Dict{String, Vector{String}}(
    "group" => ["all", "root"])
    )
    push!(config,
    "olive" => Dict{String, String}("root" => username),
    "oliveusers" => users)
    open("$path/olive/Project.toml", "w") do io
        TOML.print(io, config)
    end
    logger.log("installing `olive` dependencies.")
    Pkg.activate("$path/olive")
    Pkg.add("Pkg")
    Pkg.add("Olive")
    logger.log("olive setup completed successfully")
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
