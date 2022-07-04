function usingcell(name::String)
    divider(name, class = "usingcell")
end

function mdcell(name::String)
    divider(name, class = "cell")
end

function inputcell(name::String)
    outside = mdcell(name)
    inside = divider(name * "in", class = "input_cell", text = "hi")
    output = divider(name * "out", class = "output_cell", text = "hi")
    push!(outside, inside, output)
    outside
end

function cellcontainer(name::String)
    divider(name)
end

function projectexplorer()
    pexplore = divider("projectexplorer")
    examplefile = ul("hello", text = "wow")
    style!(pexplore, "background-color" => "gray", "position" => "fixed",
    "z-index" => "1", "top" => "0", "overflow-x" => "hidden",
     "padding-top" => "30px", "width" => "0", "height" => "100%", "left" => "0",
     "transition" => "0.8s")
    push!(pexplore, examplefile)
    pexplore
end

function topbar(c::Connection)
    topbar = divider("menubar")
    leftmenu = span("leftmenu", align = "left")
    style!(leftmenu, "display" => "inline-block")
    rightmenu = span("rightmenu", align = "right")
    style!(rightmenu, "display" => "inline-block", "float" => "right")
    style!(topbar, "border-style" => "solid", "border-color" => "black",
    "border-radius" => "5px")
    explorericon = oliveicon("explorerico", "drive_file_move_rtl")
    on(c, explorericon, "click") do cm::ComponentModifier
        style!(cm, "projectexplorer", "width" => "20%")
    end
    fileicon = oliveicon("fileico", "list")
    editicon = oliveicon("editico", "notes")
    settingicon = oliveicon("settingicon", "settings")
    styleicon = oliveicon("styleico", "display_settings")
    darkicon = oliveicon("darkico", "dark_mode")
    on(c, darkicon, "click") do cm::ComponentModifier
        if cm["olivemain"]["d"] == "0"
            style!(cm, "olivebody", "background-color" => "black")
            cm["olivemain"] = "d" => "1"
        else
            style!(cm, "olivebody", "background-color" => "white")
            cm["olivemain"] = "d" => "0"
        end
    end
    sendicon = oliveicon("sendico", "send")
    push!(leftmenu, explorericon, fileicon, editicon)
    push!(rightmenu, styleicon, darkicon, sendicon)
    push!(topbar, leftmenu, rightmenu)
    topbar
end

function oliveicon(name::String, icon::String)
    ico = span(name, class = "material-symbols-outlined", text = icon,
     margin = "15px")
     style!(ico, "font-size" => "35pt")
     ico
end
