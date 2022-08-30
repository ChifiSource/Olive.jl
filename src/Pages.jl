"""
main(c::Connection) -> _
--------------------
This function is temporarily being used to test Olive.

"""
main = route("/session") do c::Connection
    styles = olivesheet()
    write!(c, julia_style())
    write!(c, styles)
    olivebody = body("olivebody")
    main = divider("olivemain", cell = "2", ex = "0")
    style!(main, "transition" => ".8s")
    push!(main, topbar(c))
    examplecells = [Cell(1, "md", """# hello
    This is a test of the build method, which should have this cell showing
    as markdown.""", ""), Cell(2, "code",
    """function hi()
            println("hello!")
        end
    """, "")]
    cont = div("testcontainer")
    modstr = """module Examp
    function evalin(ex::Any)
            eval(ex)
    end
end"""
    c[:OliveCore].sessions[getip(c)] = examplecells => modstr => eval(Meta.parse(modstr))
    on_keydown(c, "ArrowRight") do cm::ComponentModifier
        println("hah")
        cellc = parse(Int64, cm[main]["cell"])
        evaluate(c, examplecells[cellc], cm)
    end
    for cell in examplecells
        push!(cont, build(c, cell))
    end
    push!(main, cont)
    pe = projectexplorer()
    push!(pe, build(c, Cell(1, "ipynb", "example.ipynb")))
    push!(olivebody, pe, main)
    write!(c, olivebody)
end

explorer = route("/") do c::Connection
     styles = olivesheet()
     write!(c, julia_style())
     write!(c, styles)
     olivebody = body("olivebody")
     main = divider("olivemain", cell = "1", ex = "0")
     style!(main, "overflow-x" => "hidden")
     style!(main, "transition" => ".8s")
     examplecells = [Cell(1, "ipynb", "hello.ipynb")]
     cont = div("testcontainer", align = "center")
     for cell in examplecells
         push!(cont, build(c, cell))
     end
     push!(main, cont)
     push!(olivebody,  main)
     write!(c, olivebody)
end


fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
