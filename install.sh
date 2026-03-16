#!/bin/bash
## Oh My Zsh Installation Script for Arch, Alpine, Debian, and Fedora based systems

## one line install:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeevdukeman/omz/main/install.sh)"

REPO_RAW_URL="https://raw.githubusercontent.com/zeevdukeman/omz/main"

# if $ZSH exist, ask user if they want to unset it first
if [ -n "$ZSH" ]; then
    read -p "ZSH environment variable is set to '$ZSH'. Do you want to unset it? (y/n) " yn
    case $yn in
        [Yy]* ) unset ZSH; echo "ZSH variable unset.";;
        [Nn]* ) echo "Continuing with existing ZSH variable.";;
        * ) echo "Please answer yes or no."; exit 1;;
    esac
fi

THEME=""
PLUGINS=()

set_defaults() {
    THEME="ohmyz"
    PLUGINS=("git" "z" "sudo" "extract" "history" "colored-man-pages" "zsh-autosuggestions" "zsh-syntax-highlighting")
}

set_defaults

set_config() {
    echo ""
    echo "Choose a theme:"
    echo "  1) ohmyz (default) - compact prompt with timestamp"
    echo "  2) ohmyz-classic   - colorful multi-word prompt"
    echo ""
    read -p "Enter choice [1]: " theme_choice
    case "$theme_choice" in
        2) THEME="ohmyz-classic" ;;
        *) THEME="ohmyz" ;;
    esac

    echo ""
    echo "Enter plugins to install (space-separated) [default: ${PLUGINS[*]}]: "
    read -a input_plugins
    if [ ${#input_plugins[@]} -ne 0 ]; then
        PLUGINS=("${input_plugins[@]}")
    fi
}

detect_pkg_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v apk &> /dev/null; then
        echo "apk"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    else
        echo ""
    fi
}

install_dependencies() {
    local dependencies=(zsh curl git)
    local missing_deps=()
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -eq 0 ]; then
        return
    fi

    echo "Missing dependencies: ${missing_deps[*]}"

    local pkg_manager
    pkg_manager=$(detect_pkg_manager)
    if [ -z "$pkg_manager" ]; then
        echo "No supported package manager found (apk, apt, pacman, dnf). Please install manually: ${missing_deps[*]}"
        exit 1
    fi

    echo "Installing ${missing_deps[*]} using $pkg_manager..."
    case "$pkg_manager" in
        apk)    sudo apk update && sudo apk add --no-cache "${missing_deps[@]}" ;;
        apt)    sudo apt update && sudo apt install -y "${missing_deps[@]}" ;;
        pacman) sudo pacman -Sy --noconfirm "${missing_deps[@]}" ;;
        dnf)    sudo dnf install -y "${missing_deps[@]}" ;;
    esac

    if [ $? -ne 0 ]; then
        echo "Failed to install dependencies. Exiting."
        exit 1
    fi
}

install_ohmyzsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        if [ $? -ne 0 ]; then
            echo "Failed to install Oh My Zsh. Exiting."
            exit 1
        fi
    fi
}

change_default_shell() {
    if ! command -v zsh &> /dev/null; then
        echo "zsh could not be found, cannot change default shell."
        return
    fi

    if [ "$SHELL" != "$(command -v zsh)" ]; then
        chsh -s "$(command -v zsh)"
    fi
}

# Check if .zshrc contains a setting already and if not, add it
contain() {
    local setting="$1"
    local value="$2"
    local target="$3"
    local should_export=${4:-true}
    if ! grep -q "^export ${setting}=\"" "$target" && ! grep -q "^${setting}=\"" "$target"; then
        if [ "$should_export" = true ]; then
            echo "export $setting=\"$value\"" >> "$target"
        else
            echo "$setting=\"$value\"" >> "$target"
        fi
    fi
}

configure_ohmyzsh() {
    ZSHRC="$HOME/.zshrc"
    ZSH_DIR="$HOME/.oh-my-zsh"
    ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

    contain "ZSH" "$ZSH_DIR" "$ZSHRC"
    contain "ZSH_THEME" "$THEME" "$ZSHRC"

    # Update theme and plugins in case they already exist
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"$THEME\"/" "$ZSHRC"
    sed -i "s/^export ZSH_THEME=.*/export ZSH_THEME=\"$THEME\"/" "$ZSHRC"

    local plugins_line="plugins=(${PLUGINS[*]})"
    sed -i "s/^plugins=.*/$plugins_line/" "$ZSHRC"

    # Install additional plugins
    if [[ " ${PLUGINS[*]} " =~ " zsh-autosuggestions " ]]; then
        if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" || echo "Warning: failed to clone zsh-autosuggestions"
        fi
    fi
    if [[ " ${PLUGINS[*]} " =~ " zsh-syntax-highlighting " ]]; then
        if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" || echo "Warning: failed to clone zsh-syntax-highlighting"
        fi
    fi
}

post_installation() {
    local theme_file="${THEME}.zsh-theme"
    curl -fsSL "$REPO_RAW_URL/$theme_file" -o ~/.oh-my-zsh/themes/"$theme_file" || {
        echo "Failed to download $theme_file. Exiting."
        exit 1
    }
    configure_ohmyzsh

    echo "Oh My Zsh has been configured with theme '$THEME' and plugins: ${PLUGINS[*]}"
    echo "To apply changes, please restart your terminal or run 'source ~/.zshrc'."
}

run_installation() {
    echo "Starting installation..."
    install_dependencies
    change_default_shell
    install_ohmyzsh
    post_installation
    echo "Installation complete! Please restart your terminal."
    read -n 1 -s -r -p "Press any key to exit..."
    exit 0
}

set_config
run_installation
