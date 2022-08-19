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
    projectlabel = h("projectname", 4, text = "HelloOlive.jl")
    style!(projectlabel, "display" => "inline-block", "margin-bottom" => "5px")
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
    fileicon = oliveicon("fileico", "list")
    editicon = oliveicon("editico", "notes")
    settingicon = oliveicon("settingicon", "settings")
    styleicon = oliveicon("styleico", "display_settings")
    darkicon = oliveicon("darkico", "dark_mode")
    sendicon = oliveicon("sendico", "send")
    on(c, darkicon, "click") do cm::ComponentModifier
        if cm["olivestyle"]["dark"] == "false"
            set_text!(cm, darkicon, "light_mode")
            set_children!(cm, "olivestyle", olivesheetdark()[:children])
            cm["olivestyle"] = "dark" => "true"
        else
            set_text!(cm, darkicon, "dark_mode")
            set_children!(cm, "olivestyle", olivesheet()[:children])
            cm["olivestyle"] = "dark" => "false"
        end
    end
    push!(leftmenu, explorericon, fileicon, editicon)
    push!(rightmenu, styleicon, darkicon, settingicon, sendicon)
    push!(topbar, leftmenu, projectlabel, rightmenu)
    topbar
end

function oliveicon(name::String, icon::String)
    ico = span(name, class = "material-symbols-outlined", text = icon,
     margin = "15px")
     style!(ico, "font-size" => "35pt", "transition" => "1s")
     ico
end
