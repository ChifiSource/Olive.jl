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
using Toolips
using Toolips.Components
import Toolips.Components: Servable
import Toolips: AbstractRoute, AbstractConnection, AbstractComponent, Crayon, write!, Modifier, AbstractComponentModifier, on_start
using ToolipsSession
import ToolipsSession: KeyMap
using IPyCells
import IPyCells: Cell
using Pkg
using OliveHighlighters
using TOML

session = Session(["/"])

"""
```julia
build(c::AbstractConnection, ...) -> ::AbstractComponent
```
The `build` function is used as the translation layer between the
    `Olive` back-end and front-end. The client is HTML, these functions build 
    an HTML representation of a given parametric type. New cells, directories, 
    and projects can easily be created by extending this function with new methods.
```julia
# extensible methods for build:

```
For example, the `:code` cell is added to `Olive` using the `Method` 
`build(::Connection, ::ComponentModifier, ::Cell{:code}, ::Project{<:Any})`.
"""
function build end

global evalin(ex::Any) = begin
    Main.eval(ex)
end
#==
code/none
==#
#--
"""export evalin
### Olive 
```julia
olive_module(modname::String, environment::String) -> ::String
```
---
Creates a simple, minimalist `Olive` module. This comes in the form of a `String`, which parsed and evaluated.
#### example
```example
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
"""
### Olive 
```julia
olive_motd() -> ::Component{:div}
```
------------------
Creates a markdown component containing the `Olive` message of the day.
#### example
```example
using Olive

route("/") do c::Connection
    motd = Olive.olive_motd()
    write!(c, motd)
end
```
"""
function olive_motd()
    recent_str::String = """# olive editor
    ##### $(pkgversion(Olive)) (Beta I)
    - **thank you for using olive beta I !**
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
"""
### Olive
```julia
verify_clienty!(c::Connection) -> ::String
```
------------------
Verifies an incoming client, registers keys to names. Returns the username of the current `Connection`.
"""
function verify_client!(c::Connection)
    ip::String = get_ip(c)
    args = get_args(c)
    if ip in keys(c[:OliveCore].names)
        return(c[:OliveCore].names[ip])::String
    end
    if ~(:key in keys(args))
        coverimg::Component{:img} = olive_cover()
        olivecover::Component{:div} = div("topdiv", align = "center")
        logbutt = button("requestaccess", text = "request access")
        on(c, logbutt, "click") do cm::ComponentModifier
            log(c[:Logger], " someone is trying to login to olive! is this you?")
            y = readline()
            if y == "y"
                log(c[:Logger], " okay, logging in as root.")
                key = ToolipsSession.gen_ref(16)
                push!(c[:OliveCore].client_keys, [key] => c[:OliveCore].data["root"])
                redirect!(cm, "/?key=$(key)")
            end
        end
        push!(olivecover, coverimg,
        h2("mustconfirm", text = "request access (no key)"), logbutt)
        write!(c, olivecover)
        return("dead")
    end
    if ~(args[:key] in keys(c[:OliveCore].client_keys))
        write!(c, "bad key.")
        return("dead")
    end
    uname = c[:OliveCore].client_keys[args[:key]]
    if ~(ip in keys(c[:OliveCore].names))
        push!(c[:OliveCore].names, ip => uname)
    end
    uname::String
end
#==
code/none
==#
#--
"""
### Olive
```julia
load_default_project!(c::Connection) -> ::Environment
```
---
Creates the default `Olive` environment with the `getstarted` project.
"""
function load_default_project!(c::Connection)
    name::String = getname(c)
    oc::OliveCore = c[:OliveCore]
    cells = Vector{Cell}([Cell("getstarted", "")])
    env::Environment = Environment(name)
    env.pwd = oc.data["wd"]
    if "directories" in keys(oc.client_data[name])
        env.directories = Vector{Directory}([Directory(uri, dirtype = "saved") for uri in oc.client_data[name]["directories"]])
    end
    pwd_direc::Directory{:pwd} = Directory(env.pwd, dirtype = "pwd")
    projdict::Dict{Symbol, Any} = Dict{Symbol, Any}(:cells => cells,
    :pane => "one", :env => " ")
    sourced_path::String = " "
    if "home" in keys(oc.data)
        push!(projdict, :env => oc.data["home"])
        sourced_path = oc.data["home"]
    end
    myproj::Project{<:Any} = Project{:olive}("get started", projdict)
    oc.olmod.Olive.source_module!(c, myproj, sourced_path)
    insert!(env.directories, 1, pwd_direc)
    if oc.data["root"] == name
        if "home" in keys(oc.data)
            home_direc::Directory{:home} = Directory(oc.data["home"], dirtype = "home")
            insert!(env.directories, 2, home_direc)
        end
    end
    push!(env.projects, myproj)
    push!(oc.open, env)
    env::Environment
end
#==
code/none
==#
#--
"""
```julia
build(c::Connection, env::Environment{<:Any}) -> ::Environment
```
---
The `build` function for an `Olive` `Environment` assembles the various components 
which compose `Olive` into the `Olive` page. That being said, simply changing the loaded 
environment can alter how `Olive` loads entirely.
###### example
The calling of this function is done on a `Toolips.Route`, we are able to assemble our own `Environment` (`?(Environment)`) or use 
    `load_default_project!(::Connection)`.
```example
myr = route("/") do c::Connection
    uname = Olive.verify_client!(c)
    # check for environment, if none, we load the default.
    envsearch = findfirst(e::Environment -> e.name == uname, c[:OliveCore].open)
    if isnothing(envsearch)
        env::Environment = load_default_project!(c)
    else
        env = c[:OliveCore].open[getname(c)]
    end
    # setup base UI
    bod::Component{:body}, loadicondiv::Component{:div}, olmod::Module = build(c, env)
end
```
From here, we would still need to load the projects from our `Environment` into our olive main. For reference, this is how `session` does this.
```julia
script!(c, "load", ["olivemain"], type = "Timeout", time = 350) do cm::ComponentModifier
    load_extensions!(c, cm, olmod)
    style!(cm, "loaddiv", "opacity" => 0percent)
    next!(c, loadicondiv, cm, ["olivemain"]) do cm2::ComponentModifier
        remove!(cm2, "loaddiv")
        switch_work_dir!(c, cm2, env.pwd)
        [begin
            append!(cm2, "pane_\$(proj.data[:pane])_tabs", build_tab(c, proj))
            if proj.id != env.projects[1].id
                style_tab_closed!(cm2, proj)
            end
        end for proj in env.projects]
        if length(env.projects) > 0
            window::Component{:div} = olmod.build(c, cm2, env.projects[1])
            append!(cm2, "pane_\$(env.projects[1].data[:pane])", window)
            focus!(cm2, "cell\$(env.projects[1].data[:cells][1].id)")
            p2i = findfirst(proj -> proj[:pane] == "two", env.projects)
            if ~(isnothing(p2i))
                style!(cm2, "pane_container_two", "width" => 100percent, "opacity" => 100percent)
                append!(cm2,"pane_two", olmod.build(c, cm2, env.projects[1]))
            end
        end
    end
end
write!(c, bod)
```
###### extending
To extend, we start by creating a new symbolic dispatch, this one I am naming `customenv`
```example
import Olive: build
using Olive

function build(c::Connection, env::Environment{:customenv})
    ui_explorer::Component{:div} = projectexplorer()
    ui_explorer[:children] = Vector{Servable}([begin
        olmod.build(c, d)
    end for d in env.directories])
    olivemain::Component{:div} = olive_main()
    olivemain["pane"] = "1"
    pane_one::Component{:section} = section("pane_one")
    pane_one_tabs::Component{:div} = div("pane_one_tabs")
    ...
end
```
From here, we would need to build out the **entire** `Olive` UI. That being said, 
`Environment` extensions are likely the least approachable extensions, and it might be valuable 
to look at this Function (line 274 of Olive.jl) to get an idea of how it works, and how one might 
extend `Olive` using a new `Environment` type.
"""
function build(c::Connection, env::Environment{<:Any}; icon::AbstractComponent = olive_loadicon(), sheet::AbstractComponent = DEFAULT_SHEET)
    write!(c, sheet)
    olmod::Module = c[:OliveCore].olmod
    notifier::Component{:div} = olive_notific()
    ui_topbar::Component{:div} = topbar(c)
    style!(ui_topbar, "position" => "sticky")
    ui_explorer::Component{:div} = projectexplorer()
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
    push!(loadicondiv, icon)
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
### Olive
```julia
session(c::Connection; key::Bool = true, default::Function = load_default_project) -> ::Nothing
```
---
The `session` `Function` is responsible for comprising the initial `Olive` UI as it is served to 
an incoming `Connection`. Providing a `Connection` to this route will create an `Olive` page on that route. 
The `session` route consists of four major steps:
- verifying the client
- loading a default `Environment` for clients without an `Environment`
- build and serve the `Olive` UI
- load projects into the `Olive` UI.

Providing the key-word argument `key` as `false` will remove client verification from `Olive`. Be weary, as this will also remove
name registration. Providing a `default` function allows us to change the default `Environment` that is loaded. In order to use these arguments,
we will need to create a passthrough.
```example
using Olive

function example_function(c::Connection)
    Environment(getname(c))::Environment
end

function customstart()
    ws = Olive.start()
    ws["/"] = c::Connection -> session(c, key = false, default = example_function)
end
````
"""
function make_session(c::Connection; key::Bool = true, default::Function = load_default_project!, icon::AbstractComponent = olive_loadicon(), 
    sheet = olivesheet())
    if get_method(c) == "post"
        return
    end
    write!(c, Components.DOCTYPE())
    uname::String = ""
    if key
        uname = verify_client!(c)
        if uname == "dead"
            return
        end
    else
        if ~(get_ip(c) in keys(c[:OliveCore].names))
            throw("""You have an incorrectly configured `Olive` server... `key` is set to false, 
            but there is no loader loading your users into keys. The reason you would have `key` off is to 
            add your own authentication. You will need to setup the client's IP in `OliveCore.names` before calling `make_session`, 
            this is the exact check you failed; `~(get_ip(c) in keys(c[:OliveCore].names))`""")
        end
        uname = getname(c)
    end
    # check for environment, if none load.
    envsearch = findfirst(e::Environment -> e.name == uname, c[:OliveCore].open)
    if isnothing(envsearch)
        env::Environment = default(c)
    else
        env = c[:OliveCore].open[getname(c)]
    end
     # setup base UI
    bod::Component{:body}, loadicondiv::Component{:div}, olmod::Module = build(c, env, icon = icon, sheet = sheet)
    script!(c, "load", type = "Timeout", time = 50) do cm::ComponentModifier
        load_extensions!(c, cm, olmod)
        style!(cm, "loaddiv", "opacity" => 0percent)
        next!(c, cm, loadicondiv) do cm2::ComponentModifier
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
main = route(make_session, "/")
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
CORE::OliveCore = OliveCore("olive")
"""
### Olive 
```julia
start(IP::String = "127.0.0.1", PORT::Integer = 8000; path::String = homedir(), hostname::String = IP, warm::Bool = true) -> ::Toolips.WebServer
```
------------------
Starts your `Olive` server! This function puts together your `Olive` server and sources your `olive` home.  `path` is used to denote a path to run `Olive` from.
`warm` determines whether or not `Olive` should "warm up" your `Toolips` server by precompiling and invoking it.
#### example
```
using Olive

olive_server = Olive.start()

olive_server = Olive.start("127.0.0.1", 8001, warm = false, path = pwd())
```
"""
function start(IP::Toolips.IP4 = "127.0.0.1":8000; path::String = replace(homedir(), "\\" => "/"))
    ollogger::Toolips.Logger = Toolips.Logger()
    path = replace(path, "\\" => "/")
    if path[end] == '/'
        path = path[path:end - 1]
    end
    rootname::String = ""
    if ~(isdir("$path/olive"))
        setup_olive(ollogger, path)
    end
    try
        config::Dict{String, <:Any} = TOML.parse(read("$path/olive/Project.toml", String))
        Pkg.activate("$path/olive")
        CORE.data = config["olive"]
        rootname = CORE.data["root"]
        CORE.client_data = config["oliveusers"]
        CORE.data["home"] = path * "/olive"
        CORE.data["wd"] = pwd()
    catch e
        throw(StartError(e, "configuration load", "Failed to load `Project.toml`"))
        log(ollogger, """If you are unsure why this is happening, the best choice is probably just to start 
        with a fresh Project.toml configuration file. Would you like to recreate your olive configuration file? (y or n)""", 3)
    end
    try
        source_module!(CORE)
    catch e
        throw(StartError(e, "module load", "Failed to source olive home module."))
            log(ollogger, """If you are unsure why this is happening, the best choice is probably just to start 
        with a fresh olive.jl source file.""", 2)
    end
    try
        load_extensions!(CORE)
    catch e
        log(ollogger, "olive extensions failed to load.", 3)
        showerror(stdout, e)
    end
    rs::Vector{AbstractRoute} = Vector{Toolips.Route}([fourofour, main, icons, mainicon])
    start!(Olive, IP)
    if rootname != ""
        key = ToolipsSession.gen_ref(16)
        push!(CORE.client_keys, key => rootname)
        log(ollogger,
            "link for $(rootname): http://$(string(IP))/?key=$key", 2)
    end
end
#==
code/none
==#
#--
"""
### StartError{E <: Exception}
- on::**String**
- cause**::E**
- message**::String**

The `StartError` is used to articulate problems with `Olive` starting, such as bad configurations or home 
modules.
##### example
```example
try
    source_module!(oc)
catch e
    throw(StartError(e, " module load", "Failed to source olive home module."))
end
```
------------------
##### constructors
- `StartError(cause::Exception, on::String, message::String = "")`
"""
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
"""
### Olive 
```julia
restore_defaults!(server::Toolips.WebServer) -> ::Nothing
```
---
Restores `Olive` server and client settings to defaults.
#### example
```
using Olive

olive_server = Olive.start()

Olive.restore_defaults!(olive_server)
```
"""
function restore_defaults!(server)
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

"""
### Olive 
```julia
setup_olive(logger::Toolips.Logger, path::String) -> ::Nothing
```
---
Creates the default `olive` home environment and `olive` home
#### example
```
using Olive

olive_server = Olive.start()

Olive.restore_defaults!(olive_server)
```
"""
function setup_olive(logger::Toolips.Logger, path::String)
    log(logger, "welcome to olive! to set up olive, please provide a name.")
    print("name yourself: ")
    username::String = readline()
    log(logger, "creating $username's `olive` ...")
    create_project(path)
    config::Dict{String, Any} = TOML.parse(read(
    "$path/olive/Project.toml",String))
    log(logger, "creating user configuration")
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
    log(logger, "installing `olive` dependencies.")
    Pkg.activate("$path/olive")
    Pkg.add("Pkg")
    Pkg.add("Olive")
    log(logger, "olive setup completed successfully")
end
SES = ToolipsSession.Session()
#==
code/none
==#
#--
export CORE, main, icons, mainicon, make_session, SES, build, evalin
#==
code/none
==#
#--
end # - module
#==output[module]
Olive
==#
#==|||==#
