
-- ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
-- █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█


-- Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

-- Curvas Bezier
hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })

-- Configuración de Animaciones
hl.animation({ leaf = "windows", enabled = true, speed = 6, curve = "wind", style = "slide", bezier = "wind" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, curve = "winIn", style = "popin", bezier = "winIn" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, curve = "winOut", style = "slide", bezier = "winOut" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, curve = "wind", style = "slide", bezier = "wind" })

-- Comentadas (igual que en tu config original)
-- hl.animation({ leaf = "border", enabled = true, speed = 1, curve = "liner" })
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 30, curve = "liner", style = "loop" })

hl.animation({ leaf = "fade", enabled = true, speed = 10, curve = "default", bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, curve = "wind", bezier = "wind" })



