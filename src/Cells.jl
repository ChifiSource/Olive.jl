function build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any})
    hiddencell = div("cell$(cell.n)", class = "cell-hidden")
    name = a("cell$(cell.n)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end


function build(c::Connection, cm::ComponentModifier, cell::Cell{:code})
    text = replace(cell.source, "\n" => "</br>")
    tm = TextModifier(text)
    ToolipsMarkdown.julia_block!(tm)
    outside = div("cellcontainer$(cell.n)", class = cell)
    inside = ToolipsDefaults.textdiv("cell$(cell.n)", text = string(tm))
    on(c, inside, "focus") do cm::ComponentModifier
        cm["olivemain"] = "selected" => cell.id
    end
    codebox_cover = div("codecover$(cell.n)")
    style!(codebox_cover, "position" => "absolute", "z-index" => "5", "pointer-events" => "none",
    "background" => "transparent", "height" => 100percent, "width" => 100percent,
    "padding" => 20px, "font-size" => 14pt)
    maininputbox = div("maininputbox")
    style!(maininputbox, "width" => 60percent, "padding" => 0px)
    interiorbox = div("cellinterior$(cell.n)")
    inside[:class] = "input_cell"
    bottombox = div("cellside$(cell.n)")
    cell_drag = topbar_icon("cell$(cell.n)drag", "drag_indicator")
    cell_run = topbar_icon("cell$(cell.n)drag", "not_started")
    style!(cell_drag, "color" => "white", "font-size" => 17pt)
    style!(cell_run, "color" => "white", "font-size" => 17pt)
    style!(bottombox, "background-color" => "gray",
    "border-top-right-radius" => 0px, "border-top-left-radius" => 0px,
    "margin-top" => 0px, "width" => 10percent)
     style!(inside,# "color" => "white !important",
     "width" => 80percent, "border-bottom-left-radius" => 0px, "min-height" => 50px,
     "position" => "relative", "margin-top" => 0px)
     style!(outside, "transition" => 1seconds)
     push!(maininputbox, codebox_cover, inside)
     push!(interiorbox, maininputbox, bottombox)
    number = a("cell", text = "$(cell.n)", class = "cell_number")
    output = divider("cell$(cell.n)" * "out", class = "output_cell", text = cell.outputs)
    push!(bottombox, cell_drag, number, cell_run)
    push!(outside, interiorbox, output)
    outside
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:markdown})
    tlcell = div("cell$(cell.n)", class = "cell")
    innercell = tmd("cell$(cell.n)tmd", cell.source)
    on(c, cm, tlcell, "dblclick") do cm::ComponentModifier
        set_text!(cm, tlcell, replace(cell.source, "\n" => "</br>"))
        cm["olivemain"] = "cell" => string(cell.n)
        cm[tlcell] = "contenteditable" => "true"
    end
    tlcell[:children] = [innercell]
    tlcell
end


function build(c::Connection, cm::ComponentModifier, cell::Cell{:ipynb})
    filecell = div("cell$(cell.n)", class = "cell-ipynb")
    on(c, cm, filecell, "click") do cm::ComponentModifier
        cm["olivemain"] = "cell" => string(cell.n)
    end
    on(c, cm, filecell, "dblclick") do cm::ComponentModifier
        evaluate(c, cell, cm)
    end
    fname = a("$(cell.source)", text = cell.source)
    style!(fname, "color" => "white", "font-size" => 15pt)
    push!(filecell, fname)
    filecell
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:jl})
    hiddencell = div("cell$(cell.n)", class = "cell-jl")
    style!(hiddencell, "cursor" => "pointer")
    on(c, cm, hiddencell, "click") do cm::ComponentModifier
        cm["olivemain"] = "cell" => string(cell.n)
    end
    on(c, cm, hiddencell, "dblclick") do cm::ComponentModifier
        evaluate(c, cell, cm)
    end
    name = a("cell$(cell.n)label", text = cell.source)
    style!(name, "color" => "white")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:toml})
    hiddencell = div("cell$(cell.n)", class = "cell-toml")
    name = a("cell$(cell.n)label", text = cell.source)
    on(c, hiddencell, "dblclick") do cm::ComponentModifier
        evaluate(c, cell, cm)
    end
    style!(name, "color" => "white")
    push!(hiddencell, name)
    hiddencell
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:tomlcategory})
   catheading = h("cell$(cell.n)heading", 2, text = cell.source, contenteditable = true)
    contents = section("cell$(cell.n)")
    push!(contents, catheading)
    v = string(cell.outputs)
    equals = a("equals", text = " = ")
    style!(equals, "color" => "gray")
    for (k, v) in cell.outputs
        key_div = div("keydiv")
        push!(key_div,
        a("$(cell.n)$k", text = string(k), contenteditable = true), equals,
        a("$(cell.n)$k$v", text = string(v), contenteditable = true))
        push!(contents, key_div)
    end
    contents
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:tomlval})
        key_div = div("cell$(cell.n)")
        k = cell.source
        v = string(cell.outputs)
        equals = a("equals", text = " = ")
        style!(equals, "color" => "gray")
        push!(key_div,
        a("$(cell.n)$k", text = string(k), contenteditable = true), equals,
        a("$(cell.n)$k$v", text = string(v), contenteditable = true))
        key_div
end

function evaluate(c::Connection, cell::Cell{<:Any}, cm::ComponentModifier)

end

function evaluate(c::Connection, cell::Cell{:code}, cm::ComponentModifier)
    rawcode = cm["rawcell$(cell.n)"]["text"]
    execcode = replace(rawcode, "<div>" => "\n", "</div>" => "")
    cell.source = execcode
    text = replace(cell.source, "\n" => "</br>")
    selected = cm["olivemain"]["selected"]
    proj = c[:OliveCore].open[getip(c)]
    ret = ""
    i = IOBuffer()
    try
        #== if we sent `i` through this function, maybe we could observe output?
         for example, if someone adds a package; we could have the percentage
          of the package adding? We also need to start parsing the execcode
             and observing c's permissions.
         actually, with the implementation of the using cell, we will just
           check for using and always make the evaluation of that cell
             multi-threaded.
             TODO this is a continuing problem==#
        ret = proj.mod.evalin(Meta.parse(execcode))
    catch e
        ret = e
    end
    if isnothing(ret)
        #==
        What is discussed above would be helpful here, display any STDOUT --
        we can either do that OR we can find all symbols of print or show and
        do them into the OliveDisplay
        ==#
    end
    od = OliveDisplay()
    display(od,MIME"olive"(), ret)
    set_text!(cm, "cell$(cell.n)out", String(od.io.data))
end

function evaluate(c::Connection, cell::Cell{:toml}, cm::ComponentModifier)
    toml_cats = TOML.parse(read(cell.outputs, String))
    cs::Vector{Cell{<:Any}} = [begin if typeof(keycategory[2]) <: AbstractDict
        Cell(e, "tomlcategory", keycategory[1], keycategory[2], id = ToolipsSession.gen_ref())
    else
        Cell(e, "tomlval", keycategory[1], keycategory[2], id = ToolipsSession.gen_ref())
    end
    end for (e, keycategory) in enumerate(toml_cats)]
    Olive.load_session(c, cs, cm, cell.source, cell.outputs)
end

function evaluate(c::Connection, cell::Cell{:markdown}, cm::ComponentModifier)
    activemd = replace(cm["cell$(cell.n)"]["text"], "<div>" => "\n")
    cell.source = activemd
    newtmd = tmd("cell$(cell.n)tmd", activemd)
    set_children!(cm, "cell$(cell.n)", [newtmd])
    cm["cell$(cell.n)"] = "contenteditable" => "false"
end

function evaluate(c::Connection, cell::Cell{:ipynb}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_ipynb(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function evaluate(c::Connection, cell::Cell{:jl}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_jl(cell.outputs)
    [c.id = ToolipsSession.gen_ref() for c in cs]
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function directory_cells(dir::String = pwd(), access::Pair{String, String} ...)
    files = readdir(dir)
    return([build_file_cell(e, path) for (e, path) in enumerate(files)]::AbstractVector)
end

function build_file_cell(e::Int64, path::String)
    if ~(isdir(path))
        splitdir::Vector{SubString} = split(path, "/")
        fname::String = string(splitdir[length(splitdir)])
        fsplit = split(fname, ".")
        fending::String = ""
        if length(fsplit) > 1
            fending = string(fsplit[2])
        end
        Cell(e, fending, fname, path, id = ToolipsSession.gen_ref())
    else
        Cell(e, "dir", path, path, id = ToolipsSession.gen_ref())
    end
end
