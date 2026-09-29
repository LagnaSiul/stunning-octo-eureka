#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# for changing Hyprland Layouts (Master or Dwindle) on the fly

notif="$HOME/.config/swaync/images/bell.png"

LAYOUT=$(hyprctl -j getoption general:layout | jq '.str' | sed 's/"//g')

case $LAYOUT in
"master")
	hyprctl keyword general:layout dwindle
	hyprctl keyword unbind SUPER,N
	hyprctl keyword unbind SUPER,M
	hyprctl keyword bind SUPER,N,cyclenext
	hyprctl keyword bind SUPER,M,cyclenext,prev
	hyprctl keyword bind SUPER,W,togglesplit
  notify-send -e -u low -i "$notif" "Dwindle Layout"
	;;
"dwindle")
	hyprctl keyword general:layout master
	hyprctl keyword unbind SUPER,N
	hyprctl keyword unbind SUPER,M
	hyprctl keyword unbind SUPER,W
	hyprctl keyword bind SUPER,N,layoutmsg,cyclenext
	hyprctl keyword bind SUPER,M,layoutmsg,cycleprev
  notify-send -e -u low -i "$notif" "Master Layout"
	;;
*) ;;

esac
