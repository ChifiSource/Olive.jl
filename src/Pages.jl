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
    token = Component("olive-token", "token")
    style!(token, "display" => "none")
    token[:text] = key
    write!(c, token)

    # main
    olivebody = body("olivebody")
    main = divider("olivemain", cell = "1", ex = "0",
    fname = first(session.open)[1])
    style!(main, "transition" => ".8s")
    push!(main, topbar(c))
    cont = div("testcontainer")
    on_keydown(c, "ArrowRight") do cm::ComponentModifier
        cellc = parse(Int64, cm[main]["cell"])
        activefile = cm["olivemain"]["fname"]
        println(c[:OliveCore].sessions)
        newcell = session.open[activefile][2][cellc]
        evaluate(c, newcell, cm)
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



fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
