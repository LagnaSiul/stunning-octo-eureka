#!/usr/bin/env bash

# ==============================================================================
# Configuración
# ==============================================================================
WALL_DIR="${HOME}/Pictures/.Wallpapers"  # Carpeta de fondos
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/current_wallpaper"

# Directorios de soporte (Wallbash / Cache)
SWWW_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/swww"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpapers"
SCR_DIR="$(dirname "$(realpath "$0")")"

# Symlinks globales
WALL_SET="${SWWW_DIR}/wall.set"
WALL_THM="${SWWW_DIR}/wall.thmb"
WALL_BLR="${SWWW_DIR}/wall.blur"
WALL_RFI="${SWWW_DIR}/wall.rofi"
WALL_DCL="${SWWW_DIR}/wall.dcol"

# Extensiones soportadas
IMG_EXTS="*.jpg *.jpeg *.png"
VID_EXTS="*.mp4 *.webm *.mkv *.avi *.wepb *.gif"

# ==============================================================================
# Funciones
# ==============================================================================

# Detener mpvpaper si está activo
stop_mpvpaper() {
    if pgrep -x "mpvpaper" > /dev/null; then
        pkill -x "mpvpaper"
        sleep 0.1
    fi
}

# Asegurar que hyprpaper esté corriendo
ensure_hyprpaper() {
    if ! pgrep -x "hyprpaper" > /dev/null; then
        hyprpaper &
        sleep 0.3
    fi
}

# Generar cache (.thmb, .blur, .rofi, .dcol) y crear symlinks wall.*
# Generar cache (.thmb, .blur, .rofi, .dcol) y crear symlinks wall.*
generate_wallbash_and_symlinks() {
    local target="$1"
    local cache_img
    cache_img=$(basename "$target")

    mkdir -p "$SWWW_DIR" "$CACHE_DIR"

    # Prevenir error de carpeta faltante para wallbash
    mkdir -p "$HOME/.config/hyprdots/wallbash"

    # Si es video, extraer el primer fotograma para generar miniaturas y colores
    local sample_img="$target"
    if is_video "$target"; then
        sample_img="${CACHE_DIR}/${cache_img}_frame.png"
        if [ ! -f "$sample_img" ]; then
            ffmpeg -y -i "$target" -vframes 1 -f image2 "$sample_img" > /dev/null 2>&1
        fi
    fi

    # 1. Generar la paleta de colores usando wallbash.sh si existe
    if [ -f "${SCR_DIR}/swwwallbash.sh" ]; then
        "${SCR_DIR}/swwwallbash.sh" "$sample_img" &
    elif [ -f "${SCR_DIR}/wallbash.sh" ]; then
        "${SCR_DIR}/wallbash.sh" "$sample_img" &
    fi

    # 2. Generar miniatura (.thmb) - Entrada $sample_img PRIMERO
    if [ ! -f "${CACHE_DIR}/${cache_img}.thmb" ]; then
        magick "${sample_img}[0]" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "${CACHE_DIR}/${cache_img}.thmb" &
    fi

    # 3. Generar versión para Rofi (.rofi)
    if [ ! -f "${CACHE_DIR}/${cache_img}.rofi" ]; then
        magick "${sample_img}[0]" -strip -resize 2000 -gravity center -extent 2000 -quality 90 "${CACHE_DIR}/${cache_img}.rofi" &
    fi

    # 4. Generar versión desenfocada (.blur)
    if [ ! -f "${CACHE_DIR}/${cache_img}.blur" ]; then
        magick "${sample_img}[0]" -strip -scale 10% -blur 0x3 -resize 100% "${CACHE_DIR}/${cache_img}.blur" &
    fi

    wait # Esperar a que Magick y ffmpeg terminen en segundo plano

    # 5. Crear / Actualizar enlaces simbólicos fijos
    ln -fs "$target" "$WALL_SET"
    ln -fs "${CACHE_DIR}/${cache_img}.thmb" "$WALL_THM"
    ln -fs "${CACHE_DIR}/${cache_img}.blur" "$WALL_BLR"
    ln -fs "${CACHE_DIR}/${cache_img}.rofi" "$WALL_RFI"

    # Enlazar .dcol extraído
    local dcol_gen
    dcol_gen=$(find "${XDG_CACHE_HOME:-$HOME/.cache}" -type f -name "${cache_img}.dcol" 2>/dev/null | head -n 1)
    if [ -n "$dcol_gen" ] && [ -f "$dcol_gen" ]; then
        ln -fs "$dcol_gen" "$WALL_DCL"
    fi
}
# Obtener lista de imágenes y videos ordenados
get_wallpapers() {
    local find_args=()
    
    # Construir patrones para el find
    for ext in $IMG_EXTS $VID_EXTS; do
        find_args+=(-iname "$ext" -o)
    done
    unset 'find_args[${#find_args[@]}-1]' # Remover el último -o

    mapfile -d '' WALLPAPERS < <(find -L "$WALL_DIR" -type f \( "${find_args[@]}" \) -print0 | sort -z)
    
    if [ ${#WALLPAPERS[@]} -eq 0 ]; then
        echo "Error: No se encontraron imágenes o videos en '$WALL_DIR'" >&2
        exit 1
    fi
}

# Comprobar si el archivo es un video
is_video() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    case "$ext" in
        mp4|webm|mkv|avi) return 0 ;;
        *) return 1 ;;
    esac
}

# Aplicar el wallpaper (Imagen con hyprpaper o Video con mpvpaper)
set_wallpaper() {
    local target="$1"

    if [ ! -f "$target" ]; then
        echo "Error: El archivo '$target' no existe." >&2
        exit 1
    fi

    target="$(realpath "$target")"

    if is_video "$target"; then
        # --- ES UN VIDEO ---
        stop_mpvpaper
        mpvpaper -o "no-audio --loop-playlist=inf --hwdec=auto" '*' "$target" &
    else
        # --- ES UNA IMAGEN ESTÁTICA ---
        stop_mpvpaper
        ensure_hyprpaper

        hyprctl hyprpaper preload "$target" > /dev/null
        hyprctl hyprpaper wallpaper ",$target" > /dev/null
        hyprctl hyprpaper unload all > /dev/null
    fi

    # Guardar estado actual
    echo "$target" > "$STATE_FILE"

    # Generar miniaturas, desenfoque, paleta de colores y enlaces simbólicos wall.*
    generate_wallbash_and_symlinks "$target"
}

get_current_index() {
    local current_wall
    [ -f "$STATE_FILE" ] && current_wall="$(cat "$STATE_FILE")"

    for i in "${!WALLPAPERS[@]}"; do
        if [[ "${WALLPAPERS[$i]}" == "$current_wall" ]]; then
            echo "$i"
            return
        fi
    done

    echo 0
}

change_wallpaper() {
    local direction="$1"
    local total=${#WALLPAPERS[@]}
    local current_idx
    current_idx=$(get_current_index)

    if [ "$direction" == "next" ]; then
        next_idx=$(( (current_idx + 1) % total ))
    elif [ "$direction" == "prev" ]; then
        next_idx=$(( (current_idx - 1 + total) % total ))
    fi

    set_wallpaper "${WALLPAPERS[$next_idx]}"
}

random_wallpaper() {
    local total=${#WALLPAPERS[@]}
    local rand_idx=$(( RANDOM % total ))
    set_wallpaper "${WALLPAPERS[$rand_idx]}"
}

show_help() {
    echo "Uso: $(basename "$0") [OPCIÓN]"
    echo "  -n, --next              Siguiente elemento"
    echo "  -p, --prev              Anterior elemento"
    echo "  -r, --random            Elemento aleatorio"
    echo "  -s, --set <ruta>        Establecer imagen o video"
    echo "  -d, --dir <carpeta>     Usar carpeta personalizada"
}

# ==============================================================================
# Parseo de Opciones
# ==============================================================================
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            WALL_DIR="$2"
            shift 2
            ;;
        -n|--next)
            get_wallpapers
            change_wallpaper "next"
            exit 0
            ;;
        -p|--prev)
            get_wallpapers
            change_wallpaper "prev"
            exit 0
            ;;
        -r|--random)
            get_wallpapers
            random_wallpaper
            exit 0
            ;;
        -s|--set)
            set_wallpaper "$2"
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Opción no válida: $1" >&2
            show_help
            exit 1
            ;;
    esac
done