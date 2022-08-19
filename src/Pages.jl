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
    on_keydown(c, "Enter") do cm::ComponentModifier
        alert!(cm, "you pressed enter, yo!")
    end
    push!(olivebody, projectexplorer(), main)
    write!(c, olivebody)
end

fourofour = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
