#!/usr/bin/env python3
import os
import subprocess
import json
from pathlib import Path

# 1. Rutas y entorno base
home = Path.home()
config_home = Path(os.environ.get("XDG_CONFIG_HOME", home / ".config"))
scr_dir = Path(__file__).resolve().parent

# Cargar globalcontrol si es necesario (o definir variables equivalentes)
# Puedes leer tu theme.ctl directamente
theme_ctl = home / ".config/hyprdots/theme.ctl"  # Ajusta si la ruta es diferente
full_path = None

if theme_ctl.exists():
    with open(theme_ctl, "r") as f:
        for line in f:
            if line.startswith("1|"):
                parts = line.strip().split("|")
                raw_path = parts[-1].replace("~", str(home))
                full_path = Path(raw_path)
                break

if not full_path:
    print("ERROR: Unable to fetch theme...")
    exit(1)

wall_path = full_path.parent
current_wall = full_path.name

# 2. Escala y resolución del monitor principal usando hyprctl + json
x_monres = 1920
monitor_scale = 1.0

try:
    monitors_json = subprocess.check_output(["hyprctl", "-j", "monitors"], text=True)
    monitors = json.loads(monitors_json)
    
    for mon in monitors:
        if mon.get("focused"):
            # En hyprctl, 'width' es entero directo. 
            # Nos aseguramos de castearlo a int de forma explícita.
            x_monres = int(mon.get("width", 1920))
            monitor_scale = float(mon.get("scale", 1.0))
            break
except Exception as e:
    print(f"Aviso: No se pudo obtener la info del monitor ({e}), usando valores por defecto.")

# Evitamos división por cero o escalas inválidas
if monitor_scale <= 0:
    monitor_scale = 1.0

hypr_border = 10 
elem_border = hypr_border * 3

# Cálculo del tamaño del icono
calculated_res = int((x_monres / 5) / monitor_scale)

# Clampeo de seguridad entre 80 y 200
calculated_res = max(80, min(calculated_res, 200))

r_override = (
    f"element{{border-radius:{elem_border}px;}}"
    f"element{{padding:0px;orientation:vertical;}}"
    f"element-icon{{size:{calculated_res}px;border-radius:0px;}}"
    f"element-text{{padding:1em;}}"
)

# 4. Buscar imágenes válidas en la carpeta de wallpapers
valid_extensions = (".gif", ".jpg", ".jpeg", ".png")
wall_files = []

if wall_path.exists():
    for file in wall_path.iterdir():
        if file.is_file() and file.suffix.lower() in valid_extensions:
            wall_files.append(file.name)

wall_files.sort()

# 5. Construir la entrada para Rofi con iconos
cache_dir = home / ".cache/hyprdots"
gtk_theme = "Vanta-Black"  # Reemplaza o adapta según tu variable

rofi_input_lines = []
for rfile in wall_files:
    icon_path = cache_dir / gtk_theme / rfile
    # Formato de Rofi con iconos incrustados: nombre\0icon\0ruta_icono
    rofi_input_lines.append(f"{rfile}\x00icon\x1f{icon_path}")

rofi_input_str = "\n".join(rofi_input_lines)

rofi_conf = config_home / "rofi/themeselect.rasi"
rofi_cmd = [
    "rofi", "-dmenu",
    "-theme-str", r_override,
    "-config", str(rofi_conf),
    "-select", current_wall
]
print(rofi_cmd)
try:
    # Copiamos las variables de entorno actuales del sistema operativo
    env = os.environ.copy()
    
    # Aseguramos los valores críticos por si se lanza desde un atajo limpio
    if "XDG_RUNTIME_DIR" not in env:
        env["XDG_RUNTIME_DIR"] = f"/run/user/{os.getuid()}"

    process = subprocess.Popen(
        rofi_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=env  # <--- Inyectamos el entorno gráfico aquí
    )
    
    stdout_data, stderr_data = process.communicate(input=rofi_input_str)
    rofi_sel = stdout_data.strip()
    
    if stderr_data:
        print(f"Rofi devolvió un aviso/error: {stderr_data}")

except Exception as e:
    print(f"Error al ejecutar Rofi: {e}")
    exit(1)

# 7. Aplicar el wallpaper si el usuario seleccionó uno
if rofi_sel:
    selected_full_path = wall_path / rofi_sel
    wallpaper_script = scr_dir / "swwwallpaper.sh"
    
    # Ejecutar el script de cambio de fondo
    if wallpaper_script.exists():
        subprocess.run([str(wallpaper_script), "-s", str(selected_full_path)])
    
    # Enviar notificación
    icon_notify = cache_dir / gtk_theme / rofi_sel
    subprocess.run([
        "notify-send", "-a", "t1",
        "-i", str(icon_notify),
        f" {rofi_sel}"
    ])


