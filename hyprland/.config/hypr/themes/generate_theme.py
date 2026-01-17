import json
import os
import sys
from jinja2 import Template

# Chemins des fichiers
CONFIG_DIR = os.path.expanduser("~/.config")
THEME_FILE = os.path.join(CONFIG_DIR, "hypr/themes/themes.json")
TEMPLATES_DIR = os.path.join(CONFIG_DIR, "hypr/themes/templates")

# Définition des fichiers à générer (Template -> Destination)
MAPPING = {
    "waybar.css": "waybar/style.css",
    "fuzzel.ini": "fuzzel/fuzzel.ini",

    "kitty_color.conf": "kitty/color.conf",
    "nmtui.conf": "kitty/nmtui.conf",
    "bluetuith.conf": "kitty/bluetuith.conf",
    "yazi.conf": "kitty/yazi.conf",
    

    "hyprland_theme.conf": "hypr/config/theme.conf",
    "hyprpaper.conf": "hypr/hyprpaper.conf",
    "hyprlock.conf": "hypr/hyprlock.conf",

    "gtk3_settings.ini": "gtk-3.0/settings.ini",
    "gtk4_settings.ini": "gtk-4.0/settings.ini"
}

def apply_theme(mode):
    # Charger les couleurs
    with open(THEME_FILE, 'r') as f:
        all_themes = json.load(f)
    
    # On accède à la clé 'themes' puis au mode choisi
    colors = all_themes[mode]["colors"]
    wallpaper = all_themes[mode]["wallpaper"]

    for temp_name, dest_path in MAPPING.items():
        temp_path = os.path.join(TEMPLATES_DIR, temp_name)
        final_path = os.path.join(CONFIG_DIR, dest_path)

        with open(temp_path, 'r') as f:
            template = Template(f.read())
        
        # Rendu du template avec les couleurs
        rendered = template.render(colors=colors, wallpaper=wallpaper, mode=mode)

        with open(final_path, 'w') as f:
            f.write(rendered)
    

if __name__ == "__main__":
    if len(sys.argv) > 1:
        apply_theme(sys.argv[1])
    else:
        print("Usage: python generate_theme.py [light|dark]")