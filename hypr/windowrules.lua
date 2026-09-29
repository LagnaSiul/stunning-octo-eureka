--------------------------------------------------------------------------------
-- LAYER RULES (Namespaces y UI)
--------------------------------------------------------------------------------

-- Rofi, Notificaciones y Menús de salida
hl.layer_rule({
    match = { namespace = "^(rofi|notifications|swaync-notification-window|swaync-control-center|logout_dialog)$" },
    blur = true,
    ignore_alpha = true
})

-- Barra de estado (Waybar)
hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true
})

-- Selección de área (sin animación)
hl.layer_rule({
    match = { namespace = "selection" },
    no_anim = true
})


--------------------------------------------------------------------------------
-- WINDOW RULES (Aplicaciones y Opacidad)
--------------------------------------------------------------------------------

-- Navegadores y Clapper (Opacidad 0.90)
hl.window_rule({
    match = { class = "^(firefox|Brave-browser|com.github.rafostar.Clapper)$" },
    opacity =  "0.90 0.90" 
})

-- Apps Estándar y Herramientas (Opacidad 0.80)
hl.window_rule({
    match = { class = "^(Steam|steam|steamwebhelper|Spotify|Code|code-url-handler|kitty|org.kde.dolphin|org.kde.ark|nwg-look|qt5ct|qt6ct|kvantummanager|com.github.tchx84.Flatseal|hu.kramo.Cartridges|com.obsproject.Studio|gnome-boxes|discord|WebCord|ArmCord|app.drey.Warp|net.davidotek.pupgui2|yad|Signal|io.github.alainm23.planify|io.gitlab.theevilskeleton.Upscaler|com.github.unrud.VideoDownloader|org.freedesktop.impl.portal.desktop.gtk|org.freedesktop.impl.portal.desktop.hyprland)$" },
    opacity =  "0.80 0.80" 
})

-- Control de Sistema (Opacidad Variable: activa / inactiva)
hl.window_rule({
    match = { class = "^(pavucontrol|blueman-manager|nm-applet|nm-connection-editor|org.kde.polkit-kde-authentication-agent-1)$" },
    opacity ="0.80 0.70"
})


--------------------------------------------------------------------------------
-- REGLAS PARA VENTANAS FLOTANTES Y OTROS EFECTOS
--------------------------------------------------------------------------------

-- Ventanas que Flotan (Agrupadas por clase)
hl.window_rule({
    match = { class = "^(vlc|kvantummanager|qt5ct|qt6ct|nwg-look|org.kde.ark|Signal|com.github.rafostar.Clapper|app.drey.Warp|net.davidotek.pupgui2|yad|eog|io.github.alainm23.planify|io.gitlab.theevilskeleton.Upscaler|com.github.unrud.VideoDownloader|pavucontrol|blueman-manager|nm-applet|nm-connection-editor|org.kde.polkit-kde-authentication-agent-1)$" },
    float = true
})

-- Gwenview flotante
hl.window_rule({
    match = { class = "^(gwenview)$" },
    float = true
})

-- Steam flotante (regla individual)
hl.window_rule({
    match = { class = "^(steam)$" },
    float = true
})

-- Reglas de Título Específicas
hl.window_rule({
    match = { class = "^(org.kde.dolphin)$", title = "^(Copying — Dolphin)$" },
    float = true
})

hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true
})

hl.window_rule({
    match = { class = "^(firefox)$", title = "^(Library)$" },
    float = true
})

-- Regla de autenticación Polkit
hl.window_rule({
    match = { class = "^(hyprpolkitagent|polkit-gnome-authentication-agent-1|org.freedesktop.policykit.AuthenticationAgent|input-remapper-gtk)$" },
    float = true,
    stay_focused = true
})

-- Forzar workspace actual / Pin
hl.window_rule({
    match = { class = "^(pavucontrol|hyprpolkitagent|polkit-gnome-authentication-agent-1|org.freedesktop.policykit.AuthenticationAgent)$" },
    pin = true
})