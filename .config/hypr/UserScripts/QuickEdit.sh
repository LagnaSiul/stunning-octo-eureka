#!/bin/bash
# Rofi menu for Quick Edit / View of Settings (SUPER E)

UserConfigs="$HOME/.config/hypr"
WayConfigs="$HOME/.config/waybar"
menu(){
  printf "1. view Animations\n"
  printf "2. view Hyprland.conf\n"
  printf "3. view Hyprlock\n"
  printf "4. view Keybinds\n"
  printf "5. view Monitors\n"
  printf "6. view waybar style\n"
  printf "7. view User-Settings\n"
  printf "8. view WindowRules\n"
  printf "9. view Waybar Config\n"

}

main() {	
    choice=$(menu | rofi -dmenu| cut -d. -f1)
    case $choice in
        1)
            kitty -e nvim "$UserConfigs/animations.conf"
            ;;
        2)
            kitty -e nvim "$UserConfigs/hyprland.conf"
            ;;
        3)
            kitty -e nvim "$UserConfigs/hyprlock.conf"
            ;;
        4)
            kitty -e nvim "$UserConfigs/keybindings.conf"
            ;;
        5)
            kitty -e nvim "$UserConfigs/Monitors.conf"
            ;;
        6)
            kitty -e nvim "$WayConfigs/style.css"
            ;;
        7)
            kitty -e nvim "$UserConfigs/UserSettings.conf"
            ;;
        8)
            kitty -e nvim "$Userconfigs/windowrules.conf"
            ;;
        9)
            kitty -e nvim "$WayConfigs/config.jsonc"
            ;;
    	0)
	
	   ;;
	    
    	*)
            ;;
    esac
}

main
