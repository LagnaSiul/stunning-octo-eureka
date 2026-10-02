#!/usr/bin/env python3
import os
import json
import subprocess
from pathlib import Path

# ==============================================================================
# 1. Configuración de Rutas
# ==============================================================================
home = Path.home()
config_home = Path(os.environ.get("XDG_CONFIG_HOME", home / ".config"))
cache_home = Path(os.environ.get("XDG_CACHE_HOME", home / ".cache"))
scr_dir = Path(__file__).resolve().parent

state_file = cache_home / "current_wallpaper"
thumb_cache_dir = cache_home / "hyprwall_thumbs"
thumb_cache_dir.mkdir(parents=True, exist_ok=True)

wall_path = home / "Pictures/.Wallpapers"
current_wall = ""

if state_file.exists():
    try:
        saved_path = Path(state_file.read_text().strip())
        if saved_path.exists():
            wall_path = saved_path.parent
            current_wall = saved_path.name
    except Exception:
        pass

if not wall_path.exists():
    wall_path.mkdir(parents=True, exist_ok=True)

# ==============================================================================
# 2. Monitor e Interfaz para Rofi
# ==============================================================================
x_monres = 1920
monitor_scale = 1.0

try:
    monitors_json = subprocess.check_output(["hyprctl", "-j", "monitors"], text=True)
    monitors = json.loads(monitors_json)
    for mon in monitors:
        if mon.get("focused"):
            x_monres = int(mon.get("width", 1920))
            monitor_scale = float(mon.get("scale", 1.0))
            break
except Exception:
    pass

if monitor_scale <= 0:
    monitor_scale = 1.0

calculated_res = max(80, min(int((x_monres / 5) / monitor_scale), 200))
elem_border = 30

r_override = (
    f"element{{border-radius:{elem_border}px;}}"
    f"element{{padding:0px;orientation:vertical;}}"
    f"element-icon{{size:{calculated_res}px;border-radius:0px;}}"
    f"element-text{{padding:1em;}}"
)

# ==============================================================================
# 3. Buscar Imágenes y Videos
# ==============================================================================
img_exts = {".jpg", ".jpeg", ".png", ".webp"}
vid_exts = {".mp4", ".webm", ".mkv", ".avi"}
valid_extensions = img_exts | vid_exts

wall_files = []
if wall_path.exists():
    for file in wall_path.iterdir():
        if file.is_file() and file.suffix.lower() in valid_extensions:
            wall_files.append(file.name)

wall_files.sort()

if not wall_files:
    print(f"No se encontraron fondos en: {wall_path}")
    exit(1)

# Función para generar o recuperar la miniatura de un video
def get_icon_path(filename):
    file_path = wall_path / filename
    ext = file_path.suffix.lower()

    if ext in img_exts:
        return file_path

    # Si es un video, creamos una miniatura jpg en cache
    thumb_path = thumb_cache_dir / f"{filename}.jpg"
    if not thumb_path.exists():
        try:
            # Intenta extraer un fotograma del segundo 1 con ffmpeg
            subprocess.run([
                "ffmpeg", "-y", "-ss", "00:00:01", "-i", str(file_path),
                "-vframes", "1", "-q:v", "2", str(thumb_path)
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

    return thumb_path if thumb_path.exists() else file_path

# ==============================================================================
# 4. Construir Entrada para Rofi
# ==============================================================================
rofi_input_lines = []
for rfile in wall_files:
    icon_path = get_icon_path(rfile)
    rofi_input_lines.append(f"{rfile}\x00icon\x1f{icon_path}")

rofi_input_str = "\n".join(rofi_input_lines)

rofi_conf = config_home / "rofi/themeselect.rasi"
rofi_cmd = ["rofi", "-dmenu", "-theme-str", r_override]

if rofi_conf.exists():
    rofi_cmd.extend(["-config", str(rofi_conf)])

if current_wall in wall_files:
    rofi_cmd.extend(["-select", current_wall])

# ==============================================================================
# 5. Ejecutar Rofi y Aplicar Selección
# ==============================================================================
try:
    env = os.environ.copy()
    if "XDG_RUNTIME_DIR" not in env:
        env["XDG_RUNTIME_DIR"] = f"/run/user/{os.getuid()}"

    process = subprocess.Popen(
        rofi_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=env
    )
    
    stdout_data, _ = process.communicate(input=rofi_input_str)
    rofi_sel = stdout_data.strip()

except Exception as e:
    print(f"Error al ejecutar Rofi: {e}")
    exit(1)

if rofi_sel:
    selected_full_path = wall_path / rofi_sel
    wallpaper_script = scr_dir / "swwwallpaper.sh"
    
    # Ejecutar el script que decide si usa hyprpaper o mpvpaper
    if wallpaper_script.exists():
        subprocess.run([str(wallpaper_script), "-s", str(selected_full_path)])
    else:
        subprocess.run(["swwwallpaper.sh", "-s", str(selected_full_path)])

    # Notificación con el icono cargado
    icon_notify = get_icon_path(rofi_sel)
    subprocess.run([
        "notify-send",
        "-a", "Wallpapers",
        "-i", str(icon_notify),
        "Fondo Cambiado",
        f"{rofi_sel}"
    ])