"""
main(c::Connection) -> _
--------------------
This function is temporarily being used to test Olive.

"""
main = route("/") do c::Connection
    styles = olivesheet()
    write!(c, styles)
    olivebody = body("olivebody")
    main = divider("olivemain", cell = "1", ex = "0")
    style!(main, "transition" => ".8s")
    push!(main, topbar(c))
    examplecells = [Cell(1, "md", """# hello
    This is a test of the `build` method, which should have this cell showing
    as markdown.""", ""), Cell(2, "code",
    """function hi()
            println("hello!")
        end
    """, "")]
    cont = div("testcontainer")
    for cell in examplecells
        push!(cont, build(c, cell))
    end
    push!(main, cont)
    push!(olivebody, projectexplorer(), main)
    write!(c, olivebody)
end

fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
