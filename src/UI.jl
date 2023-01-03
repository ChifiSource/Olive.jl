#==
Default
    Styles
==#
function cellnumber_style()
    st = Style("h1.cell_number", color = "white")
    st["font-family"] = "'Rubik', sans-serif"
    st
end

function inputcell_style()
    st = Style("div.input_cell", border = "2px solid gray", padding = "20px",
    "bordier-radius" => 30px, "margin-top" => 30px, "transition" => 1seconds,
    "font-size" => 14pt)
    animate!(st, fade_up())
    st::Style
end

function outputcell_style()
    st = Style("div.output_cell", border = "0px", padding = "10px",
    "margin-top" => 20px, "margin-right" => 200px, "border-radius" => 30px,
    "font-size" => 14pt)
    animate!(st, fade_up())
    st::Style
end
function ipy_style()
    s::Style = Style("div.cell-ipynb",
    "background-color" => "orange",
     "width" => 75percent, "overflow-x" => "hidden", "border-color" => "gray",
     "border-width" => 2px,
    "padding" => 4px, "border-style" => "solid", "transition" => "0.5s")
    s:"hover":["scale" => "1.05"]
    s::Style
end

function toml_style()
    s = Style("div.cell-toml", "background-color" => "blue", "text-color" => "white",
    "border-width" => 2px, "overflow-x" => "hidden", "padding" => 4px,
    "transition" => "0.5s",
    "border-style" => "solid", "width" => 75percent)
    s:"hover":["scale" => "1.05"]
    s::Style
end

function jl_style()
    s = Style("div.cell-jl", "background-color" => "#F55887", "text-color" => "white",
    "border-width" => 2px, "overflow-x" => "hidden", "padding" => 4px,
    "border-style" => "solid", "width" => 75percent, "transition" => "0.5s")
    s:"hover":["scale" => "1.05"]
    s::Style
end

function spin_forever()
    load = Animation("spin_forever", delay = 0.0, length = 1.0, iterations = 0)
    load[:to] = "transform" => "rotate(360deg)"
    load::Animation
end

function load_spinner()
    mys = Style("img.loadicon", "transition" => ".5s")
    animate!(mys, spin_forever())
    mys::Style
end

function fade_up()
    cellin = Animation("fade_up", length = 1.5)
    cellin[:from] = "opacity" => "0%"
    cellin[:from] = "transform" => "translateY(100%)"
    cellin[:to] = "opacity" => "100%"
    cellin[:to] = "transform" =>  "translateY(0%)"
    cellin::Animation
end

function usingcell_style()
    st::Style = Style("div.usingcell", border = "0px solid gray", padding = "40px",
    "border-radius" => 5px, "background-color" => "#CCCCFF")
    animate!(st, fade_up()); st::Style
end

function cell_style()
    st::Style = Style("div.cell", "border-color" => "gray", padding = "20px",
    "background-color" => "white", "border-top-left-radius" => 0px,
    "border-bottom-left-radius" => 0px)
    st:"focus":["border-width" => 2px]
    animate!(st, fade_up())
    st::Style
end

hdeps_style() = Style("h1.deps", color = "white")

google_icons() = link("google-icons",
href = "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200",
rel = "stylesheet")

function iconstyle()
    s = Style(".material-symbols-outlined", cursor = "pointer",
    "font-size" => "100pt", "transition" => ".4s")
    s:"hover":["color" => "orange", "transform" => "scale(1.1)"]
    s
end

function hidden_style()
    Style("div.cell-hidden",
    "background-color" => "gray",
     "width" => 75percent, "overflow-x" => "hidden",
    "padding" => 4px, "transition" => "0.5s")::Style
end

function julia_style()
    hljl_nf::Style = Style("span.hljl-nf", "color" => "#2B80FA")
    hljl_oB::Style = Style("span.hljl-oB", "color" => "purple", "font-weight" => "bold")
    hljl_n::Style = Style("span.hljl-ts", "color" => "orange")
    hljl_cs::Style = Style("span.hljl-cs", "color" => "gray")
    hljl_k::Style = Style("span.hljl-k", "color" => "#E45E9D", "font-weight" => "bold")
    hljl_s::Style = Style("span.hljl-s", "color" => "#3FBA41")
    styles::Component{:sheet} = Component("codestyles", "sheet")
    push!(styles, hljl_k, hljl_nf, hljl_oB, hljl_n, hljl_cs, hljl_s)
    styles::Component{:sheet}
end

function olivesheet()
    st = ToolipsDefaults.sheet("olivestyle", dark = false)
    bdy = Style("body", "background-color" => "white")
    push!(st, google_icons(), load_spinner(), spin_forever(),
    fade_up(), iconstyle(), cellnumber_style(), hdeps_style(),
    usingcell_style(), outputcell_style(), inputcell_style(), bdy, ipy_style(),
    hidden_style(), jl_style(), toml_style())
    st
end

function olivesheetdark()
    st = ToolipsDefaults.sheet("olivestyle", dark = true)
    bdy = Style("body", "background-color" => "#360C1F", "transition" => ".8s")
    st[:children]["div"]["background-color"] = "#DB3080"
    st[:children]["div"]["color"] = "white"
    st[:children]["p"]["color"] = "white"
    st[:children]["h1"]["color"] = "orange"
    st[:children]["h2"]["color"] = "lightblue"
    ipc = inputcell_style()
    ipc["background-color"] = "#DABCDF"
    ipc["border-width"] = 0px
    push!(st, google_icons(),
    fade_up(), iconstyle(), cellnumber_style(), hdeps_style(),
    usingcell_style(), outputcell_style(), ipc, bdy, ipy_style(),
    hidden_style(), jl_style(), toml_style())
    st
end

function projectexplorer()
    pexplore = divider("projectexplorer")
    style!(pexplore, "background" => "transparent", "position" => "fixed",
    "z-index" => "1", "top" => "0", "overflow-x" => "hidden",
     "padding-top" => "30px", "width" => "0", "height" => "100%", "left" => "0",
     "transition" => "0.8s")
    pexplore
end

function explorer_icon(c::Connection)
    explorericon = topbar_icon("explorerico", "drive_file_move_rtl")
    on(c, explorericon, "click") do cm::ComponentModifier
        if cm["olivemain"]["ex"] == "0"
            style!(cm, "projectexplorer", "width" => "250px")
            style!(cm, "olivemain", "margin-left" => "250px")
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

function settings(c::Connection)
    settingicon = topbar_icon("settingicon", "settings")
    settingicon::Component{:span}
end

function cellmenu(c::Connection)
    cellicon = topbar_icon("editico", "notes")
    cellicon::Component{:span}
end

function topbar(c::Connection)
    topbar = divider("menubar")
    leftmenu = span("leftmenu", align = "left")
    style!(leftmenu, "display" => "inline-block")
    rightmenu = span("rightmenu", align = "right")
    style!(rightmenu, "display" => "inline-block", "float" => "right")
    style!(topbar, "border-style" => "solid", "border-color" => "black",
    "border-radius" => "5px")
    push!(leftmenu, explorer_icon(c), cellmenu(c))
    push!(rightmenu, settings(c))
    push!(topbar, leftmenu, rightmenu)
    topbar::Component{:div}
end

function topbar_icon(name::String, icon::String)
    ico = span(name, class = "material-symbols-outlined", text = icon,
     margin = "15px")
     style!(ico, "font-size" => "35pt")
     ico
end

function olive_body(c::Connection)
    olivebody = body("olivebody")
    style!(olivebody, "overflow-x" => "hidden", "transition" => ".8s")
    olivebody::Component{:body}
end

function olive_main(selected::String = "project")
    main = div("olivemain", cell = 1,  selected = selected, ex = 0)
    style!(main, "transition" => ".8s")
    main::Component{:div}
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{<:Any})
    hiddencell = div("cell$(cell.n)", class = "cell-hidden")
    name = a("cell$(cell.n)label", text = cell.source)
    style!(name, "color" => "black")
    push!(hiddencell, name)
    hiddencell
end

function cell_up!(c::AbstractConnection, cm::ComponentModifier)

end

function cell_down!(c::AbstractConnection, cm::ComponentModifier)

end
#==
    CELLS
    This portion implements `build` and `evaluate` for Olive.jl. Creating the base
    :code cell. These can still be overwritten with future methods and imports !
    Which is awesome, by the way. Anyway, cells are sprung into existence via
    a file cell. For example, we would implement a toml reader into Cells by
    creating a toml category and a toml section cell and then making a simple name.
    Below then is the infastructure to surround the cells, cell pages etc.
==#
function build(c::Connection, cm::ComponentModifier, cell::Cell{:code})
    text = replace(cell.source, "\n" => "</br>")
    tm = TextModifier(text)
    ToolipsMarkdown.julia_block!(tm)
    outside = div("cellcontainer$(cell.n)", class = cell)
    inside = ToolipsDefaults.textdiv("cell$(cell.n)", text = string(tm))
    interiorbox = div("cellinterior$(cell.n)")
    inside[:class] = "input_cell"
    sidebox = div("cellside$(cell.n)")
    style!(sidebox, "display" => "inline-block", "background-color" => "gray",
    "border-top-right-radius" => 0px, "border-bottom-right-radius" => 0px,
    "margin-top" => 0px)
     style!(inside, "text-color" => "white !important", "display" => "inline-block",
     "width" => 60percent, "border-top-left-radius" => 0px,
     "border-bottom-left-radius" => 0px, "min-height" => 50px)
     style!(outside, "transition" => 1seconds)
     push!(interiorbox, sidebox, inside)
    number = h("cell", 1, text = "$(cell.n)", class = "cell_number")
    output = divider("cell$(cell.n)" * "out", class = "output_cell", text = cell.outputs)
    push!(sidebox, number)
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

function cellcontainer(c::Connection, name::String)
    divider(name)
end

function evaluate(c::Connection, cell::Cell{<:Any}, cm::ComponentModifier)

end

function evaluate(c::Connection, cell::Cell{:code}, cm::ComponentModifier)
    rawcode = cm["rawcell$(cell.n)"]["text"]
    execcode = replace(rawcode, "<div>" => "\n", "</div>" => "")
    cell.source = execcode
    text = replace(cell.source, "\n" => "</br>")
    tm = TextModifier(text)
    ToolipsMarkdown.julia_block!(tm)
    set_text!(cm, "cell$(cell.n)", string(tm))
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

function evaluate(c::Connection, cell::Cell{:markdown}, cm::ComponentModifier)
    activemd = replace(cm["cell$(cell.n)"]["text"], "<div>" => "\n")
    cell.source = activemd
    newtmd = tmd("cell$(cell.n)tmd", activemd)
    set_children!(cm, "cell$(cell.n)", [newtmd])
    cm["cell$(cell.n)"] = "contenteditable" => "false"
end

function load_session(c::Connection, cs::Vector{Cell{<:Any}},
    cm::ComponentModifier, source::String, fpath::String)
    myproj = Project{:olive}("hello", "ExampleProject")
    #==
    TODO Name project, activate environment in evalin
    ==#
    push!(myproj.open, "source" =>  cs)
    c[:OliveCore].open[getip(c)] = myproj
    redirect!(cm, "/session")
end

function evaluate(c::Connection, cell::Cell{:ipynb}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_ipynb(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function evaluate(c::Connection, cell::Cell{:jl}, cm::ComponentModifier)
    cs::Vector{Cell{<:Any}} = IPy.read_jl(cell.outputs)
    load_session(c, cs, cm, cell.source, cell.outputs)
end

function directory_cells(dir::String = pwd(), access::Pair{String, String} ...)
    routes = Toolips.route_from_dir(dir)
    notdirs = [routes[r] for r in findall(x -> ~(isdir(x)), routes)]
    dirs = [Directory(dir, access ...) for dir in findall(x -> isdir(x), routes)]
    return([begin
    splitdir::Vector{SubString} = split(path, "/")
    fname::String = string(splitdir[length(splitdir)])
    fsplit = split(fname, ".")
    fending::String = ""
    if length(fsplit) > 1
        fending = string(fsplit[2])
    end
    Cell(e, fending, fname, path)
end for (e, path) in enumerate(notdirs)]::AbstractVector, dirs)
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

function evaluate(c::Connection, cell::Cell{:toml}, cm::ComponentModifier)
    toml_cats = TOML.parse(read(cell.outputs, String))
    cs::Vector{Cell{<:Any}} = [begin if typeof(keycategory[2]) <: AbstractDict
        Cell(e, "tomlcategory", keycategory[1], keycategory[2])
    else
        Cell(e, "tomlval", keycategory[1], keycategory[2])
    end
    end for (e, keycategory) in enumerate(toml_cats)]
    Olive.load_session(c, cs, cm, cell.source, cell.outputs)
end

function olive_loadicon()
    iconb64 = """data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAMS0lEQVR4Xu1af2xVVx0/575Xyq8QWcuMi3GSqRsaZWMDW6bESqKZCduEtqyIkOgMGUzFBZYsLvpk4iJjhEzHUmwZZayNOJwMR4HBIDEOnP/rZlzmlDDd2HRkW3+8d+/x++N8zzn3vZb32tcOEnqT9t1377nnnO/n+/l+vt9z7tPqMj/0ZW6/mgBgggGXOQITIXCZE2BCBD+QEDjRtrVe1ajrIpX5lDHxtVrpa7RWtcg+rQ38T9ATAyZSr2RM/HIS6b/l+/pfaurJnRtvho4bAGCWPvHN7QvAsmWRUnPQSH8YBdfgFrbCq3APL+BHxIAovKfUX3Sc7F+45/4XxwuIMQcgp3LRzW0zF0ZZ1RopM1uCjAdKwE4yjA4PAHyJ2OiMbcctuK0x5tXI6F8f6Ro8Bf2HSFaNy5gBgL58fuWjjdrEK0xkrsaZoVMVUdw62nqWrtuLBAIYT/Zb7/tJCVhsc6T1a4nJdzc+njsFbTySVcAwJgAcuuWR2tor9AYT6QbnWTHWjiAMEM8yCAY0AD+tgQQAfydgPE62DYQOtjfq9BX/fmPrJ3t/MVCF7YFjqujlWNv2Dytdcx94+hoxjkAgC5nWOGkPgDeMdMCKINIlSgAQogKD48HAhnxN2AOPvVKI4k0LO3NvVzH96tLgcy3tHzM1hZ9E2tSnJ+EN8UZKCwuK2GQBiMgyeM4LoJ+cLtYOaEpsMW/GBbOpcXfuH6MFYdQhcHhl+0d0kt8aqWhGSGM3EZggG4NaIFQXVvA1DgHOAKwBMbX39Kf0yAcA5bxPF1g7QCDP1xi9cd6u3NnRgDAqAA5945EZGTPpITDiKjc/oXI4CwsCGVsUBs6YIAQyCgEItQ0AgOdSmcPphAdTJ+ZsPKA3NjyZOz9SEEYMAKa5hrYr79daz2fvyoEeR08FWQpuojcjoXUJCF4EMQR0AICwh8YIM0kglGE2SUzy4oKOTQ+MOwCH79ixQkdRGw/E3vLURE8XpWliAbaB62CIN8wWQzqG4kemHafon3GFkoioLZI86p4dyBSju+Z15J4aCQgjYsCJtvb6vNKPGp1M9YP42CQC0KRDFrDRw4UBZQGsA1ICyNT3qo+iKiOKrtBg1CZIse/rQuHueY8/+GalIIwIgMNt7fcC9b/InadLWxnQlbjkcXu1RAskE4QhgIawCEod4NMng+TGoFAyTi1SNUai/nBj5wNbxhyAY1//ZV1+yqROGIyrVXuEsRoKGCu/nzRpARrhwsCGQAZCwFaBAgA+J8LHlaIHnAoha/pQtQVkBeiw/86bdj5c0UKqYgb0tnWs1sY0OyMtJdMVnp+cM8CBwDSOwMtMb5gnshjTGyAgAih1gPO+LY9TYhtUj+yHdFUMBdVTN3Ru7qqEBRUBsK9lX2Z65p090OEMT3U7KKm3HOkqjtcCKGz2oFAAw4nCNu7hPiIhKZCuI0voYQkJzARSHwwdethaQDJGnX/n79nVTSdzhXIgVATAs60di2AGG8meIPalnqdBApHynYpA+nDQUOz48IDVH2UBBkaYQepPfSIY3sNhBgkNC5KCYwNU1Ztv7Nh8ekwA+P3yzvUwucXSGc7JWCBKjHWh4db0du0P3qR8iEteNNYufzMIErKE/8jTQnun8sXrA4tPYF1KFGEOwILjN+zcvH1sAGjd1QkAXJnqzBUngTpTA7v8TaUtvobeJhYBCzL0PH7CH5XAyBI8t7me1NaeB/2myGZTIPVOoRiGhz5zffvP7qoaAIj/KdOid/cN21FAUTJOJgGG+ALJs4FAsJQn4y0A6P0MsIHEkTIFHv45b3hwL839kin+d+D1lqbdu/svBEJZDeht6bwW9ui2lkNSipKwHQsdekc2RZgBFAKQ/jK6oGrgU6uCyiIwmBKLVoROZ0o8XHZGyLQNcx/b8nJVABxo7WyKdOYe3wkbFf6/EDt4Zec3PBgUrPQSlc0MAgB5MB7qSxA8DhEGiVKk2x+8gAkhAw2rE4opQZ4k267fueVEVQA8s7zrFjBiLXfCAwx3MDA0crBIClpTKuMQqIHPbGZA1Wb74DMPxuepb6cBJYPIuLCnDCHiv/kZFdNZx2bH5371896qADjY0tUM29Wri80PoUify+RgokOCJeAYYsDMqf8BFhTSK8GygVme/tTCJF1z27dccHFUdqgQgAqH9c1ElB01/HAY7YWkVv2vb5YqFCah72kn8MKH5xi3ExUM1d9fAxd0rTs6vzoAnmnedRvI851+YjBJqDJS34vnVWSFvAWgacKjVAmYjCrEk9RgPA3+JtF3kwBnKI7ZiHAlMWLwaSi947tH51cZAnfsXWxMsj6VYksMDL1hb4IhZICLDzaKVvxgbBxnMfEBCLVgPJwnoArwjElI/mxgw/ei52Xo8myBseJk2/ePN1QnggdanoBXWcamwXBzKmUdG0vEIKULtFISGdV5cB2NhHMAIUmyqmDA+7jAjAEM/BTgAAjJ+GJ0yI7hGCHA0Kh5vWHtifnVpUEohKbXqsGe9IA+VlPR4Br5CsWVLaCkdA5IocdpowyMjE0NRBTGP5wndhVA3zEG/KLYdR2ADOVucBRXRVq9MfheS+5kU3WFEI5woHnvY+DWj9JoxRKQQmYIw5EMYDzTAjyPFAcvo9cNGAzZn+KevgML/CsRAIj4Xx4ISTa+9gT4jDqz9rnG6kthHP/p5r3rI6UXF+32WdOL12K+iLXlDC5MbGECuoBix6UQhUICDEBmoC5Q4UugSAL1eiCMoEVxGdG1YXZ87bGGsVkM/a65ZyGs/u7zzi4twsN45bBIxzAZKxpAKQ89i9kAjcVNJgiB2LLErh+pG8ceV0/SSbE+pEOEmjy47ujCF1IEHeJLucRLj+S+lMvOrftEFxTwbkOE5jZE3qZtDolTVwewugulOedbAGwI4FcURupXwCImWLBtOIRrT+PSTIll5+uOnFnVqlr9jsowSFQEAD7722Xdq2FDFLbEhqvv2Ouc5yV2+ZxrP05tribAnE+hwBrAAEA7uM5jcJgw0H5diX2k94TkmdBCs++uIzc/Uc77eL9iALqXdNdPro064JnUpqhPf+B5twpB7/o45gl7AJLQSAoBBoiMdsIn+0Jul3DINGuXWT4s4P18nM9+++7jn39rTAHAzvYv7b4XXorQtnhqG0RELvC838ELCxu/2KX7MTOAvYxCiP1afB2A/icTnPU4i4RHUVicBO8/XInxI2IANoaaYBb8hqddm0xNWOWVFCzkYbSKX4rx+tTndGEE6YLNAAwCG+hZkA4F3wbPsGjyZjIT9fu6f/K6NSdvqmhLfMQA4AP7l/Yshx9CrBRPlCyOredc3LtZh96Hi67ocfvDZE8SqD7rAWuAC6MAKBfBdhIAV9d3eheN36sxnAy+HP3M0jk/hH2rBcVUJFpTLS/rJaFqkffJML6GdQEbaY21AKQWQkFFWCKA9DQyzPz5bO/zPx3pb4gqFkFPNqX2fGXPtMnTJ2+DrOBej0uZy9ZYBQ8WMqk3eAIAxTyuHTB1irftdooTQzZQhJLAdZOxvzIw5uyU+EP3rDo6971wnpWcjwoA7Ljn1p6rMtnMQ9poqg3kHfBQ3uf71lgrHpLaWAOgzgz6YDEMp8ZriDA1Sp8A3HkIlQ1rjix6vRKDi9uMGgAC4faej2d19kcQDrO4KOE6gL1qrQ4qQh/H4DlxI63+fNXolB7rBxGYIKWyAY4t5+LB7I/XHPvCP0djvO9ptE/DcweXHKzvzw7kwDtXMz0lA1hAQu/L5C1YXOpKnk+VF25tkJqaCCeOA78dTPr0pjUnmypW/KHMrIoB0mH7koNTZ2bzPwDvN6SpKwVO0e6OFUqiOr0PC8pnAoyZlALU5V26d/pd1bf1e71fu/g/kwtQ1T23/aYximpWwCtqYINshDDRnHAFqc0ZaJXfp1SbNYq0QKvoNei7+1vPfvkU9FmSgUdD5DFhQDgwpsk5t362MdaZ5VpHs9lIe0iBJCkQfe9CQPYMuG0qRQLdYcNg378O//GFkaa5cqCMOQDhgE/e/vSCjMoui5X5tOUzsSHFDieCzBR3YCpN1F9h3bh/1aGv/qmcIaO9P64AyKS6QSjh/Dp4YzBbRZn6ODF18LvfOhDAOtQAIPPbsAQ+B6/g3oKECKKmX+1T/S+tObikKoGrBJQPBIBKJnKx2kwAcLGQv1TGnWDApeKJizWPCQZcLOQvlXEvewb8H3Q/FIx7ey30AAAAAElFTkSuQmCC"""
    myimg = img("olive-loader", src = iconb64, class = "loadicon")
    animate!(myimg, spin_forever())
    myimg
end
