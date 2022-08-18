"""
main(c::Connection) -> _
--------------------
This function is temporarily being used to test Olive.

"""
main::Route = route("/") do c::Connection
    
    olivebody = body("olivebody")
    style!(olivebody, "transition" => ".8s")
    main = divider("olivemain", d = "0", cell = "1", s = "0", ex = "0")
    style!(main, "transition" => ".8s")
    push!(samplemdcell, samplemd)
    push!(main, topbar(c), sampleusingcell, samplemdcell)
    samplecell = inputcell("myinput")
    write!(c, current_settings)
    on_keydown(c, "Enter") do cm::ComponentModifier
        alert!(cm, "you pressed enter, yo!")
    end
    push!(olivebody, projectexplorer(), main)
    write!(c, olivebody)
end

fourofour::Route = route("404") do c::Connection
    write!(c, p("404message", text = "404, not found!"))
end
