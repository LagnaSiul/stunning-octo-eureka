
--█░█ █▀ █▀▀ █▀█   █▀█ █▀█ █▀▀ █▀▀ █▀
--█▄█ ▄█ ██▄ █▀▄   █▀▀ █▀▄ ██▄ █▀░ ▄█


-- Set your personal hyprland configuration here
-- for sample file, please refer https://github.com/prasanthrangan/hyprdots/blob/main/Configs/.config/hypr/userprefs.t2


hl.on("hyprland.start", function()
    hl.exec_cmd("kitty -e btop")
    hl.exec_cmd("pear-desktop")
    hl.exec_cmd("kitty -e ranger /home/lagn/Documentos/Cosas/")
    hl.exec_cmd("equibop -m")
    
end)

