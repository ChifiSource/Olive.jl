"""
main(c::Connection) -> _
--------------------
This function is temporarily being used to test Olive.

"""
main = route("/session") do c::Connection
    # styles
    styles = olivesheet()
    write!(c, julia_style())
    write!(c, styles)
    # args
    args = getargs(c)
    key = args[:key]
    session = c[:OliveCore].sessions[key]
    # main
    olivebody = body("olivebody")
    main = divider("olivemain", cell = "1", ex = "0")
    style!(main, "transition" => ".8s")
    push!(main, topbar(c))
    cont = div("testcontainer")
    on_keydown(c, "ArrowRight") do cm::ComponentModifier
        cellc = parse(Int64, cm[main]["cell"])
        evaluate(c, examplecells[cellc], cm)
    end
    current_file = first(session.open)
    println(current_file)
    cells::Vector{Servable} = [build(c, cell) for cell in current_file[2][2]]
    cont[:children] = cells
    push!(main, cont)
    pe = projectexplorer()
    push!(pe, build(c, Cell(1000, "ipynb", "example.ipynb")))
    push!(olivebody, pe, main)
    write!(c, olivebody)
end

explorer = route("/") do c::Connection
     styles = olivesheet()
     write!(c, julia_style())
     write!(c, styles)
     olivebody = body("olivebody")
     main = divider("olivemain", cell = "1", ex = "0")
     cells::Vector{Cell} = directory_cells(c)
     on_keydown(c, "ArrowRight") do cm::ComponentModifier
         cellc = parse(Int64, cm[main]["cell"])
         evaluate(c, cells[cellc], cm)
     end
     style!(main, "overflow-x" => "hidden")
     style!(main, "transition" => ".8s")
     cont = div("testcontainer", align = "center")
     cellcont::Vector{Servable} = [build(c, cell) for cell in cells]
     cont[:children] = cellcont
     push!(main, cont)
     push!(olivebody,  main)
     write!(c, olivebody)
end

function directory_cells(c::Connection, dir::String = pwd())
    routes = Toolips.route_from_dir(dir)
    notdirs = [routes[r] for r in findall(x -> ~(isdir(x)), routes)]
    [begin
    splitdir::Vector{SubString} = split(path, "/")
    fname::String = string(splitdir[length(splitdir)])
    fending::String = string(split(fname, ".")[2])
    Cell(e, fending, fname, path)
    end for (e, path) in enumerate(notdirs)]::Vector{Cell}
end

fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
