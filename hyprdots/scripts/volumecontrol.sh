#!/usr/bin/env sh

ScrDir=`dirname "$(realpath "$0")"`
source $ScrDir/globalcontrol.sh


# define functions

print_error ()
{
cat << "EOF"
    ./volumecontrol.sh -[device] <actions>
    ...valid device are...
        i   -- input decive
        o   -- output device
        p   -- player application
    ...valid actions are...
        i   -- increase volume [+5]
        d   -- decrease volume [-5]
        m   -- mute [x]
EOF
exit 1
}

notify_vol ()
{
    # Determinamos el icono del sistema según el nivel de volumen
    local ico="audio-volume-high"
    if [ "$vol" -eq 0 ]; then
        ico="audio-volume-muted"
    elif [ "$vol" -lt 30 ]; then
        ico="audio-volume-low"
    elif [ "$vol" -lt 70 ]; then
        ico="audio-volume-medium"
    fi

    # Generación de la barra visual de texto
    local bar=$(seq -s "." $(($vol / 15)) | sed 's/[0-9]//g')
    
    # Notificación limpia enviada a Mako
    notify-send -a "t2" \
                -h string:x-canonical-private-synchronous:volume_notif \
                -t 800 \
                -i "$ico" \
                "${vol}% ${bar}" \
                "${nsink}"
}

notify_mute ()
{
    mute=$(pamixer "${srce}" --get-mute | cat)
    [ "${srce}" == "--default-source" ] && dvce="mic" || dvce="speaker"
    if [ "${mute}" == "true" ] ; then
        notify-send -a "t2" -r 91190 -t 800 -i "${icodir}/muted-${dvce}.svg" "muted" "${nsink}"
    else
        notify-send -a "t2" -r 91190 -t 800 -i "${icodir}/unmuted-${dvce}.svg" "unmuted" "${nsink}"
    fi
}

action_pamixer ()
{
    pamixer "${srce}" -"${1}" "${step}"
    vol=$(pamixer "${srce}" --get-volume | cat)
}

action_playerctl ()
{
    [ "${1}" == "i" ] && pvl="+" || pvl="-"
    playerctl --player="${srce}" volume 0.0"${step}""${pvl}"
    vol=$(playerctl --player="${srce}" volume | awk '{ printf "%.0f\n", $0 * 100 }')
}
switch_sink ()
{
    # 1. Obtiene la lista de nombres de todas las salidas disponibles
    sinks=($(pactl list short sinks | awk '{print $2}'))
    
    # 2. Obtiene el nombre de la salida predeterminada actual
    current_sink=$(pactl get-default-sink)
    
    # 3. Busca la posición del dispositivo actual y calcula el siguiente
    next_sink="${sinks[0]}" # Por defecto, si algo falla, vuelve al primero
    for i in "${!sinks[@]}"; do
        if [ "${sinks[$i]}" = "${current_sink}" ]; then
            next_index=$(( (i + 1) % ${#sinks[@]} ))
            next_sink="${sinks[$next_index]}"
            break
        fi
    done

    # 4. Cambia el dispositivo predeterminado en el sistema
    pactl set-default-sink "${next_sink}"
    
    # 5. Obtiene el nombre estético (descripción) para la notificación usando pamixer
    nsink=$(pamixer --list-sinks | grep "${next_sink}" | awk -F '"' '{print $(NF - 1)}')
    [ -z "${nsink}" ] && nsink="${next_sink}" # Si pamixer no lo encuentra, usa el nombre corto
    
    notify-send -a "t2" -r 91190 -t 1500 -i "${icodir}/vol-100.svg" "Salida Cambiada a:" "${nsink}"
}

# eval device option

while getopts iop: DeviceOpt
do
    case "${DeviceOpt}" in
    i) nsink=$(pamixer --list-sources | awk -F '"' 'END {print $(NF - 1)}')
        [ -z "${nsink}" ] && echo "ERROR: Input device not found..." && exit 0
        ctrl="pamixer"
        srce="--default-source" ;;
    o) nsink=$(pamixer --get-default-sink | awk -F '"' 'END{print $(NF - 1)}')
        [ -z "${nsink}" ] && echo "ERROR: Output device not found..." && exit 0
        ctrl="pamixer"
        srce="" ;;
    p) nsink=$(playerctl --list-all | grep -w "${OPTARG}")
        [ -z "${nsink}" ] && echo "ERROR: Player ${OPTARG} not active..." && exit 0
        ctrl="playerctl"
        srce="${nsink}" ;;
    *) print_error ;;
    esac
done


# set default variables

icodir=""
shift $((OPTIND -1))
step="${2:-5}"


# execute action

case "${1}" in
    i) action_${ctrl} i ;;
    d) action_${ctrl} d ;;
    m) "${ctrl}" "${srce}" -t && notify_mute && exit 0 ;;
    s) [ "${ctrl}" == "pamixer" ] && switch_sink && exit 0 ;; # <- NUEVA LÍNEA
    *) print_error ;;
esac

notify_vol
