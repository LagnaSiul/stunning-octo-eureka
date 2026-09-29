local mainMod = "SUPER"

local terminal    = "kitty"
local fileManager = "kitty -e ranger"
local fileExplorer = "thunar"
local menu        = "rofi -show drun"
local browser      = "helium-browser"
local editor       = "zeditor"



local home = os.getenv("HOME")
local scrPath = home .. "/.config/hyprdots/scripts"

-- Window/Session actions

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.window.close()) -- killactive
hl.bind("ALT + F4", hl.dsp.window.close()) -- killactive
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle({ window = "activewindow" }))

-- Application shortcuts
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))  -- open terminal
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(fileManager)) -- open file manager
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor)) -- open vscode
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser)) -- open browser
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("pear-desktop")) -- open pear-desktop



hl.bind("ALT + F11", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))



hl.bind(mainMod .. " + SHIFT + F", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.pin({action ="toggle", window = "activewindow"}))
    
end)





hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(scrPath .. "/keyboardswitch.sh"))


hl.bind("CONTROL + ESCAPE", hl.dsp.exec_cmd("killall waybar ||waybar"))





hl.bind("CONTROL + SHIFT + ESCAPE", hl.dsp.exec_cmd("kitty -e btop"))  -- open htop/btop if installed or default to top (system monitor)

-- Rofi is toggled on/off if you repeat the key presses
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pkill -x rofi ||" .. scrPath .. "/rofilaunch.sh d"))  -- launch desktop applications
hl.bind(mainMod .. " + tab", hl.dsp.exec_cmd("pkill -a rofi ||" .. scrPath .. "/rofilaunch.sh w"))  -- switch between desktop applications
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileExplorer))  -- browse system files
-- Audio control
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o m"))  -- toggle audio mute
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -i m"))  -- toggle microphone mute
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o d"))  -- decrease volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o i"))  -- increase volume
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {locked = true})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {locked = true})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))


-- -----------------------------------------------------
-- Screenshot/Screencapture (Grimblast + Satty)
-- -----------------------------------------------------

-- Capturar un área seleccionada y editarla con Satty
hl.bind("Print", hl.dsp.exec_cmd("grimblast save area - | satty --filename - --fullscreen"))
    
-- Capturar toda la pantalla y editarla con Satty
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grimblast save screen - | satty --filename - --fullscreen"))

-- Capturar la ventana activa y editarla con Satty
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grimblast save active - | satty --filename - --fullscreen"))

-- Exec custom scripts
hl.bind(mainMod .. " + ALT + G", hl.dsp.exec_cmd(scrPath .. "/GameMode.sh"))  -- disable hypr effects for gamemode
hl.bind(mainMod .. " + SHIFT + ALT + right", hl.dsp.exec_cmd(scrPath .. "/swwwallpaper.sh -n"))
hl.bind(mainMod .. " + SHIFT + ALT + left" , hl.dsp.exec_cmd(scrPath .. "/swwwallpaper.sh -p"))  -- previous wallpaper

-- bind = $mainMod SHIFT, T, exec, pkill -x rofi || $scrPath/themeselect.sh # theme select menu
-- bind = $mainMod SHIFT, A, exec, pkill -x rofi || $scrPath/rofiselect.sh # rofi style select menu
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/swwwallselect.py"))  -- rofi wall select menu
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/cliphist.sh c"))  -- open Pasteboard in screen center






-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"}))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right"}))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"}))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction ="down"}))




-- Switch workspaces with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Switch workspaces relative to the active workspace with mainMod + CTRL + [←→]
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- move to the first empty workspace instantly with mainMod + CTRL + [↓]
hl.bind(mainMod .. " + CTRL + down", hl.dsp.focus({ workspace = "empty" }))

-- Resize windows

hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true}), { repeating = true })
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true}), { repeating = true })
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = 10, relative = true}), { repeating = true })
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = -10, relative = true}), { repeating = true })


-- Move active window to a relative workspace with mainMod + CTRL + ALT + [←→]
hl.bind(mainMod .. " + CONTROL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CONTROL + left", hl.dsp.focus({ workspace = "e-1" }))


  -- Move active window around current workspace with mainMod + SHIFT + CTRL [←→↑↓]
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"}))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right"}))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"}))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction ="down"}))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.exec_cmd("workspace, e+1"))
hl.bind(mainMod .. " + mouse_up", hl.dsp.exec_cmd("workspace, e-1"))

-- Move/Resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- Special workspaces (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))


-- Move window silently to workspace Super + Alt + [0-9]

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false}))
end




hl.bind(mainMod .. " + SHIFT + F", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.pin({action ="toggle", window = "activewindow"}))
    
end)



-- Switch to a submap called `monitor_off`.
hl.bind("SUPER +ALT + R", hl.dsp.submap("monitor_off"))

-- Start a submap called "monitor_off".
hl.define_submap("monitor_off", function()

    hl.bind("1", function()
                     hl.timer(function()
                       hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor="DP-1" }))
                       hl.dispatch(hl.dsp.submap("reset"))
                     end, {timeout = 500, type = "oneshot"})
                   end)
    
    hl.bind("2", function()
                     hl.timer(function()
                       hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor= "HDMI-A-1" }))
                       hl.dispatch(hl.dsp.submap("reset"))
                     end, {timeout = 500, type = "oneshot"})
                   end)
    hl.bind("3", function()
                     hl.timer(function()
                         hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor="DP-1" }))
                       hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor= "HDMI-A-1" }))
                       hl.dispatch(hl.dsp.submap("reset"))
                     end, {timeout = 500, type = "oneshot"})
                   end)
    -- Use `reset` to go back to the global submap
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Keybinds further down will be global again...
