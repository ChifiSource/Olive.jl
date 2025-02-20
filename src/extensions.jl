#==
map
- file interpolation
- additional connections
- logger
- mount
==#
"""
```julia
MobileConnection <: AbstractConnection
```
- stream**::HTTP.Stream**
- data**::Dict{Symbol, Any}**
- ret**::Any**

A `MobileConnection` is used with multi-route and will be created when an incoming `Connection` is mobile. 
This is done by simply annotating your `Function`'s `Connection` argument when calling `route`. To create one 
page for both of these routes, we then use `route` to combine them.
```julia
module ExampleServer
using Toolips
main = route("/") do c::Connection
    write!(c, "this is a desktop.")
end

mobile = route("/") do c::Toolips.MobileConnection
    write!(c, "this is mobile")
end

# multiroute (will call `mobile` if it is a `MobileConnection`, meaning the client is on mobile)
home = route(main, mobile)

# then we simply export the multi-route
export home
end
using Toolips; Toolips.start!(ExampleServer)
```
- See also: `route`, `Connection`, `route!`, `Components`, `convert`, `convert!`

It is unlikely you will use this constructor unless you are calling 
`convert!`/`convert` in your own `route!` design. This `Connection` type is 
primarily meant to be dispatched as it is in the example.
```julia
MobileConnection(stream::HTTP.Stream, data::Dict{Symbol, Any}, routes::Vector{AbstractRoute})
```
"""
mutable struct MobileConnection{T} <: AbstractConnection
    stream::Any
    data::Dict{Symbol, Any}
    routes::Vector{AbstractRoute}
    MobileConnection(stream::Any, data::Dict{Symbol, <:Any}, routes::Vector{<:AbstractRoute}) = begin
        new{typeof(stream)}(stream, data, routes)
    end
end

function convert(c::AbstractConnection, routes::Routes, into::Type{MobileConnection})
    get_client_system(c)[2]::Bool
end

function convert!(c::AbstractConnection, routes::Routes, into::Type{MobileConnection})
    MobileConnection(c.stream, c.data, routes)::MobileConnection{typeof(c.stream)}
end

# for IO Connection specifically...
function convert!(c::IOConnection, routes::Routes, into::Type{MobileConnection})
    stream = Dict{Symbol, String}(:stream => c.stream, :args => get_args(c), :post => get_post(c), 
    :ip => get_ip(c), :method => get_method(c), :target => get_route(c), :host => get_host(c))
    MobileConnection(stream, c.data, routes)::MobileConnection{Dict{Symbol, String}}
end

get_ip(c::MobileConnection{Dict{Symbol, String}}) = c.stream[:ip]
get_method(c::MobileConnection{Dict{Symbol, String}}) = c.stream[:method]
get_args(c::MobileConnection{Dict{Symbol, String}}) = c.stream[:args]
get_route(c::MobileConnection{Dict{Symbol, String}}) = c.stream[:target]
get_host(c::MobileConnection{Dict{Symbol, String}}) = c.stream[:host]
get_post(c::MobileConnection{Dict{Symbol, String}}) = c.stream[:post]
write!(c::MobileConnection{Dict{Symbol, String}}, a::Any ...) = c.stream[:stream] = c.stream[:stream] * join(string(obj) for obj in a)

"""
```julia
Logger <: Toolips.AbstractExtension
```
- `crayons`**::Vector{Crayon}**
- `prefix`**::String**
- `write`**::Bool**
- `writeat`**::Int64**
- `prefix_crayon`**::Crayon**
```julia
Logger(prefix::String = "🌷 toolips> ", crayons::Crayon ...; dir::String = "logs.txt", write::Bool = false, 
writeat::Int64, prefix_crayon::Crayon = Crayon(foreground  = :blue, bold = true))
```
```example
module ExampleServer
using Toolips
crays = (Toolips.Crayon(foreground = :red), Toolips.Crayon(foreground = :black, background = :white, bold = true))
log = Toolips.Logger("yourserver>", crays ...)

# use logger
route("/") do c::Connection
    log(c, "hello world!", 1)
end
# load to server
export log
end
using Toolips; Toolips.start!(ExampleServer)
```
- See also: `route`, `Connection`, `Extension`
"""
mutable struct Logger <: AbstractExtension
    crayons::Vector{Crayon}
    prefix::String
    write::Bool
    writeat::UInt8
    prefix_crayon::Crayon
    function Logger(prefix::String = "🌷 toolips> ", crayons::Crayon ...; dir::String = "logs.txt",
        write::Bool = false, writeat::Int64 = 3, prefix_crayon = Crayon(foreground  = :blue, bold = true))
        if write && ~(isfile(dir))
            try
                touch(dir)
            catch
                throw("Logger tried to make log file \"$dir\", but could not.")
            end
        end
        if length(crayons) < 1
            crayons = [Crayon(foreground  = :light_blue, bold = true), Crayon(foreground = :yellow, bold = true), 
            Crayon(foreground = :red, bold = true)]
        end
        new([crayon for crayon in crayons], prefix, write, UInt8(writeat), prefix_crayon)
    end
end

function log(l::Logger, message::String, at::Int64 = 1)
    cray = l.crayons[at]
    println(l.prefix_crayon, l.prefix, cray, message)
end

"""
```julia
log(c::Connection, message::String, at::Int64 = 1) -> ::Nothing
```
`log` will print the message with your `Logger` using the crayon `at`. `Logger` 
will give a lot more information on this.
```example
module MyServer
using Toolips

logger = Toolips.Logger()

home = route("/") do c::Connection
    log(c, "hello server!")
    write!(c, "hello client!")
end

export home, logger
end
```
"""
log(c::AbstractConnection, args ...) = log(c[:Logger], args ...)

"""
```julia
mount(fpair::Pair{String, String}) -> ::Route{Connection}/::Vector{Route{Connection}}
```
`mount` will create a route that serves a file or a all files in a directory. 
The first part of `fpair` is the target route path, e.g. `/` would be home. If 
the provided path is as directory, the Function will return a `Vector{AbstractRoute}`. For 
a single file, this will be a route.
```example
module MyServer
using Toolips

logger = Toolips.Logger()

filemount::Route{Connection} = mount("/" => "templates/home.html")

dirmount::Vector{<:AbstractRoute} = mount("/files" => "public")

export filemount, dirmount, logger
end
```
"""
function mount(fpair::Pair{String, String})
    fpath::String = fpair[2]
    target::String = fpair[1]
    if ~(isdir(fpath))
        if ~(isfile(fpath))
            throw(RouteError{String}(fpair[1], "Unable to mount $(fpair[2]) (not a valid file or directory, or access denied)"))
        end
        return(route(c::AbstractConnection -> begin
            write!(c, File(fpath))
        end, target))::AbstractRoute
    end
    if length(target) == 1
        target = ""
    elseif target[length(target)] == "/"
        target = target[1:length(target)]
    end
    [begin
        route(c::AbstractConnection -> write!(c, File(path)), target * replace(path, fpath => "")) 
    end for path in route_from_dir(fpath)]::Vector{<:AbstractRoute}
end

"""
```julia
route_from_dir(path::String) -> ::Vector{String}
```
This is a (mostly) internal (but also handy) function that reads a directory, and 
    then recursively appends all of the paths in its underlying tree structure. This 
    is used for file mounting in `Toolips`.
```example
module MyServer
using Toolips

logger = Toolips.Logger()

filemount::Route{Connection} = mount("/" => "templates/home.html")

dirmount::Vector{<:AbstractRoute} = mount("/files" => "public")

export filemount, dirmount, logger
end
```
"""
function route_from_dir(path::String)
    dirs::Vector{String} = readdir(path)
    routes::Vector{String} = []
    [begin
        fpath = "$path/" * directory
        if isfile(fpath)
            push!(routes, fpath)
        else
            if ~(directory in routes)
                newrs::Vector{String} = route_from_dir(fpath)
                [push!(routes, r) for r in newrs]
            end
        end
    end for directory in dirs]
    routes::Vector{String}
end
