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
    cont = cellcontainer("main")
    mymd = mdcell("mymd")
    push!(mymd, tmd"""# welcome to olive
    here is a look at the UI elements of the olive interface
    composed together! This is a markdown cell, in the future, you
    will be able to double click to edit the raw text of this cell!
    ## input cells:""")
    myinp = inputcell("myinp")
    push!(cont, mymd, myinp)
    push!(main, cont)
    push!(olivebody, projectexplorer(), main)
    write!(c, olivebody)
end

fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
