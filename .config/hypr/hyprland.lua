-- Hyprland Configuration Table



-- Autostart (Exec-once)
local scrPath = "~/.config/hyprdots/scripts"


hl.on("hyprland.start", function()
    -- 1. El motor y portales
    hl.exec_cmd(scrPath .. "/resetxdgportal.sh")
    hl.exec_cmd("awww-daemon --format xrgb")
    -- 2. El sistema
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- 3. Autenticación
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    -- 4. Fondo y colores
    hl.exec_cmd(scrPath .. "/swwwallpaper.sh -n")
    hl.exec_cmd("wal -R")
    -- 5. Interfaz y utilidad
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)



hl.env("GRIMBLAST_EDITOR", "satty")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland")
-- QT_STYLE_OVERRIDE = "kvantum-dark",
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", 1)
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", 1)
hl.env("MOZ_ENABLE_WAYLAND", 1)


-- Input Configuration
hl.config({
    input = {
        kb_layout = "us, es",
        follow_mouse = 1,
        kb_options = "grp:alt_shift_f",
        sensitivity = 0,
        force_no_accel = 1,
    },
    misc = {
        vrr = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = -1,
    },
    -- Per-device Config

    -- Layouts
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
})
-- Misc\

hl.device({
    name = "epic mouse V1",
    sensitivity = -0.5,
})
-- External Sources
--



require("animations")
require("keybindings")
require("windowrules")
require("themes/theme")
--require("monitors")
require("workspaces")
require("userprefs")
