local GTK_THEME = "Vanta-Black"
local ICON_THEME = "Tela-circle-black"
local COLOR_SCHEME = "prefer-dark"
local CURSOR_THEME = "Bibata-Original-Ice"
local CURSOR_SIZE = 20
local CODE_THEME = "Pure Black"





hl.on("hyprland.start", function()
    -- 1. El motor y portales
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme " .. COLOR_SCHEME)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme " .. GTK_THEME)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme " .. ICON_THEME)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. CURSOR_THEME)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. CURSOR_SIZE)
    
end)






hl.env("GTK_THEME", GTK_THEME)
hl.env("XCURSOR_THEME", CURSOR_THEME)
hl.env("XCURSOR_SIZE", CURSOR_SIZE)


hl.config({
general ={
    gaps_in = 2,
    gaps_out = 2,
    border_size = 3,
    col ={
    active_border = {colors = {"rgba(ffffffee)", "rgba(bfbfbfb0)", "rgba(bfbfbfb0)", "rgba(ffffffee)"}, angle = 45},
    inactive_border = {colors = {"rgba(2a2a2ab0)", "rgba(3c3c3cb0)", "rgba(3c3c3cb0)", "rgba(2a2a2ab0)"}, angle = 45},
    },resize_on_border = true,
},

decoration ={
    rounding = 0,
    active_opacity = 0.95,
    inactive_opacity = 0.95,

    blur = {
        enabled = yes,
        size = 2,
        passes = 4,
        ignore_opacity = true,
        new_optimizations = true,
        xray = false,
        noise = 0.0,
        popups = true,
    },

    dim_inactive = false,
    dim_strength = 0.05,

    shadow = {
        enabled = false,
        range = 30,
        scale = 2,
        render_power = 5,
        color = "rgba(0f0f0fff)",
        color_inactive = "rgba(050505ff)",
    }
},

group = {
    col = {
        border_inactive = {colors = {"rgba(1a1a1ab0)"}, angle = 0},
        border_active = {colors = {"rgba(ffffffee)", "rgba(bfbfbfb0)", "rgba(bfbfbfb0)", "rgba(ffffffee)"}, angle = 45},
    },
    groupbar = {
        col = {
            active = "rgba(bfbfbfcc)",
            inactive = "rgba(82828299)",
        },
        font_family = "JetBrainsMono NFM",
        font_size = 10,
        text_color = "rgba(ffffffff)",
    },
},

})


hl.layer_rule({match = {namespace = "waybar"}, blur = false})