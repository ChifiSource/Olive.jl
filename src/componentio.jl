function html_properties(s::AbstractString)
    propvec::Vector{SubString} = split(s, " ")
    properties::Dict{Symbol, Any} = Dict{Symbol, Any}(begin
        ppair::Vector{SubString} = split(segment, "=")
        if length(ppair) < 2
            Symbol(ppair[1]) => string(ppair[1])
        else
            Symbol(ppair[1]) => replace(string(ppair[2]), "\"" => "")
        end
    end for segment in propvec)
    properties::Dict{Symbol, Any}
end

"""
```julia
htmlcomponent(s::String, args ...) -> ::Vector{<:AbstractComponent}

htmlcomponent(s::String, names_only::Bool = true) -> ::Vector{Component{<:Any}}
htmlcomponent(s::String, readonly::Vector{String}) -> ::Vector{Component{<:Any}}
```
Reads components from an HTML `String`. Providing `names_only` as `false` will 
read elements without an `id` as well. Not doing so of course speeds up parsing of 
by excluding unneeded (unnamed in this case) elements. A `Vector{String}` of names 
may also be provided.
---
```example
comp = "<div id=\\"sample\\">hello</div>"

htmlcomponent(comp)["sample"]["text"]

"hello"
```
"""
function htmlcomponent(s::String, names_only::Bool = true)
    stop::Int64 = 1
    laststop::Int64 = 1
    comps::Vector{Component{<:Any}} = Vector{Component{<:Any}}()
    while true
        laststop = stop
        argfinish = findnext(">", s, stop)
        tagstart = findnext("<", s, stop)
        tagend = findnext(" ", s, stop)
        tagbefore = minimum(tagstart) > maximum(argfinish)
        if isnothing(argfinish) || isnothing(tagend) || isnothing(tagstart) || tagbefore
            break
        end
        tag::String = s[minimum(tagstart) + 1:minimum(tagend) - 1]
        finisher = findnext("</$tag>", s, maximum(argfinish) + 1)
        stop = maximum(argfinish) + 1
        if contains(tag, "/")
            continue
        end
        name::String = "component-$stop"
        idstart = findfirst("id=\"", s[minimum(tagstart):minimum(argfinish)])
        if isnothing(finisher)
            continue
        end
        if (isnothing(idstart) && names_only)
            continue
        end
        argstring::String = s[minimum(tagend) + 1:minimum(argfinish) - 1]
        properties::Dict{Symbol, Any} = html_properties(argstring)
        if :id in keys(properties)
            name = properties[:id]
            delete!(properties, :id)
        end
        text::String = ""
        try
            text = s[minimum(argfinish) + 1:minimum(finisher) - 1]
        catch
            text = s[minimum(argfinish) + 1:minimum(finisher) - 2]
        end
        push!(properties, :text => text)
        props = Dict{Symbol, Any}(Symbol(k[1]) => k[2] for k in properties)
        push!(comps, Component{Symbol(tag)}(name, tag, props))
    end
    return(comps)
end

function htmlcomponent(s::String, readonly::Vector{String})
    if readonly[1] == "none"
        return Vector{Servable}()
    end
    Vector{AbstractComponent}(filter!(x -> ~(isnothing(x)), [begin
        element_sect = findfirst(" id=\"$compname\"", s)
        if ~(isnothing(element_sect))
            starttag = findprev("<", s, element_sect[1])[1]
            ndtag = findnext(" ", s, element_sect[1])[1]
            argfinish = findnext(">", s, ndtag)[1] + 1
            tg = s[starttag + 1:ndtag - 1]
            finisher = findnext("</$tg", s, argfinish)
            fulltxt::String = ""
            if ~(isnothing(finisher))
                fulltxt = s[argfinish:finisher[1] - 1]
            end
            properties = html_properties(s[ndtag:argfinish - 2])
            name::String = ""
            if "id" in keys(properties)
                name = properties["id"]
                delete!(properties, "id")
            end
            push!(properties, :text => replace(fulltxt, "<br>" => "\n", "<div>" => "", 
            "&#36;" => "\$", "&#37;" => "%", "&#38;" => "&", "&nbsp;" => " ", "&#60;" => "<", "	&lt;" => "<", 
            "&#62;" => ">", "&gt;" => ">", "<br" => "\n", "&bsol;" => "\\", "&#63;" => "?"))
            Component{Symbol(tg)}(compname, tg, properties)
        else
        end
    end for compname in readonly]))::Vector{AbstractComponent}
end

componenthtml(comps::Vector{<:AbstractComponent}) = join([string(comp) for comp in comps])

md_string(comp::Component{<:Any}) = comp[:text]
md_string(comp::Component{:h1}) = "# $(comp[:text])\n"
md_string(comp::Component{:h2}) = "## $(comp[:text])\n"
md_string(comp::Component{:h3}) = "### $(comp[:text])\n"
md_string(comp::Component{:h4}) = "#### $(comp[:text])\n"
md_string(comp::Component{:h5}) = "##### $(comp[:text])\n"
md_string(comp::Component{:h6}) = "###### $(comp[:text])\n"
md_string(comp::Component{:hr}) = "---\n"
md_string(comp::Component{:code}) = begin
    "```\n$(comp[:text])\n```"
end
md_string(comp::Component{:b}) = "**\n$(comp[:text])\n**"
md_string(comp::Component{:i}) = "*\n$(comp[:text])\n*"
md_string(comp::Component{:a}) = begin
    if :href in keys(comp.properties)
        "[$(comp[:text])]($(comp[:href]))"
    else
        comp[:text]
    end
end

function componentmd(comps::Vector{<:AbstractComponent})
    [md_string(comp) for comp in comps]
end

"""
```julia
interpolate!(mdcomp::Component{:div}, components::Component{<:Any} ...; keyargs ...) -> ::Nothing
interpolate!(comp::Component{:div}, fillfuncs::Pair{String, <:Any} ...) -> ::Nothing
```
Interpolates markdown inside the `:text` of a `div` (typically created using `tmd`). 
The `Component{<:Any}` and key-word argument dispatch will interpolate in-line code blocks, as well 
as values with a `%` before them. The latter function will take a series of strings paired with functions. 

The functions will be passed the `String` of a code block, the return is another `String` -- the result.
---
```example


```
"""
function interpolate!(mdcomp::Component{:div}, components::Component{<:Any} ...; keyargs ...)
    replace_names = vcat([comp.name for comp in components], [string(arg[1]) for arg in keyargs])
    gen_dct = Dict{String, Any}(comp.name => string(comp) for comp in components)
    [push!(gen_dct, string(arg[1]) => string(arg[2])) for arg in keyargs]
    raw::String = mdcomp[:text]
    raw = replace(raw, ("<code>$(name_object[1])</code>" => name_object[2] for name_object in gen_dct) ..., 
    ("&#37;$(name_object[1])" => name_object[2] for name_object in gen_dct) ...)
    mdcomp[:text] = raw
    nothing::Nothing
end

interpolate!(comp::Component{:div}, fillfuncs::Pair{String, <:Any} ...) = begin
    raw::String = comp[:text]
    [begin
        name::String = name_func[1]
        f::Function = name_func[2]
        at::Int64 = 1
        while true
            position = findnext("<code class=\"language-$name\">", raw, at)
            if isnothing(position)
                break
            end
            elmax = maximum(position) + 1
            final_c = findnext("</code", raw, elmax)
            if isnothing(final_c)
                at = maximum(position)
                continue
            end
            section_end = minimum(final_c) - 1
            section::String = raw[elmax:section_end]
            section = f(section)
            # sometimes i h8 utf-8
            try
                raw = raw[1:minimum(position) - 1] * section * raw[section_end + 1:length(raw)]
            catch
                try
                    raw = raw[1:minimum(position) - 2] * section * raw[section_end + 1:length(raw)]
                catch
                    try
                        raw = raw[1:minimum(position) - 1] * section * raw[section_end - 1:length(raw)]
                    catch
                        at = maximum(position)
                        continue
                    end
                end
            end
            at += length(section)
        end
    end for name_func in fillfuncs]
    comp[:text] = raw
    nothing::Nothing
end

"""
```julia
interpolate(f::File{<:Any}, components::AbstractComponent ...; args ...) -> ::String
```
Interpolates values and components into any file, simply provide a `\$` before the component's name, or value's name. The value's name 
will be provided as the key-word argument key. Returns a `String`, the interpolated file.
---
```html
(example.html)
<div>
\$navbar
<h1>hello world</h1>
\$visit_n
</div>
```
```julia
using ToolipsServables
f = File("example.html")
pages = ("home", "about")
navbar = div("navbar", children = [a("menu\$n", text = n) for n in pages], align = "center")
ret = interpolate(f, navbarm visit_n = 1)
```
"""
function interpolate(f::File{<:Any}, components::AbstractComponent ...; args ...)
    rawfile::String = read(dir, String)
    [begin
        rawc = string(comp)
        rawfile = replace(rawfile, "\$$(comp.name)" => rawc)
    end for comp in components]
    [begin
        rawfile = replace(rawfile, "\$$(arg[1])" => arg[2])
    end for arg in args]
    write!(c, rawfile)
    string(rawfile)
end
