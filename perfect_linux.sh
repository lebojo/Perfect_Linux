#!/bin/bash

# Liste des identifiants des extensions à installer
extensions=(
    "blur-my-shell@aunetxi"
    "dash-to-dock@micxgx.gmail.com"
    "just-perfection-desktop@just-perfection"
    "user-theme@gnome-shell-extensions.gcampax.github.com"
    "Vitals@CoreCoding.com"
    "background-logo@fedorahosted.org"
    "hanabi-extension@jeffshee.github.io"
	"mediacontrols@cliffniff.github.com"
)

# Fonction pour obtenir l'URL de téléchargement de l'extension
get_download_url() {
    local uuid=$1
    local shell_version="40"  # Changez cette valeur selon votre version de GNOME Shell
    local api_url="https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${shell_version}"
    local download_url=$(curl -s "$api_url" | grep -oP '(?<="download_url": ")[^"]*')
    echo "https://extensions.gnome.org${download_url}"
}

# Créer un dossier temporaire pour télécharger les extensions
temp_dir=$(mktemp -d)

# Installer une extension
install_extension() {
    local uuid=$1
    local download_url=$(get_download_url "$uuid")
    local extension_zip="$temp_dir/$(basename "$download_url")"

    # Télécharger l'extension
    echo "Téléchargement de $uuid..."
    curl -s -L -o "$extension_zip" "$download_url"

    # Extraire l'extension
    echo "Extraction de $uuid..."
    unzip -q "$extension_zip" -d "$temp_dir"

    # Déplacer l'extension extraite vers le dossier des extensions
    local extension_dir=$(unzip -qql "$extension_zip" | head -n1 | tr -s ' ' | cut -d' ' -f5-)
    mv "$temp_dir/$extension_dir" ~/.local/share/gnome-shell/extensions/

    # Activer l'extension
    echo "Activation de $uuid..."
    gnome-extensions enable "$uuid"

    echo "$uuid installé et activé avec succès."
}

# Installer chaque extension de la liste
for extension in "${extensions[@]}"; do
    install_extension "$extension"
done

# Nettoyer le dossier temporaire
rm -rf "$temp_dir"

echo "Toutes les extensions ont été téléchargées, installées et activées."
