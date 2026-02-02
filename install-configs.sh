#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
PINK='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/eandset/Pink-Theme"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
TEMP_DIR="/tmp/pink-theme-$(date +%s)"

# Config structure
declare -A CONFIG_PATHS=(
    ["hypr"]="$CONFIG_DIR/hypr"
    ["waybar"]="$CONFIG_DIR/waybar" 
    ["kitty"]="$CONFIG_DIR/kitty"
    ["rofi"]="$CONFIG_DIR/rofi"
    ["fastfetch"]="$CONFIG_DIR/fastfetch"
    ["yazi"]="$CONFIG_DIR/yazi"
    ["peaclock"]="$HOME/.peaclock"
    ["oh-my-zsh"]="$HOME/.oh-my-zsh/custom"
    ["zshrc"]="$HOME/.zshrc"
    ["wallpapers"]="$HOME/Pictures/wallpapers"
)

declare -A DESCRIPTIONS=(
    ["hypr"]="Hyprland window manager"
    ["waybar"]="Waybar status bar"
    ["kitty"]="Kitty terminal"
    ["rofi"]="Rofi app launcher"
    ["fastfetch"]="Fastfetch system info"
    ["yazi"]="Yazi file manager"
    ["peaclock"]="Peaclock clock"
    ["oh-my-zsh"]="Oh My Zsh theme"
    ["zshrc"]="Zsh configuration"
    ["wallpapers"]="Wallpapers"
)

# Function to print colored messages
print_message() { echo -e "${GREEN}[+]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }
print_pink() { echo -e "${PINK}🎀 $1${NC}"; }

print_section() {
    echo -e "\n${MAGENTA}════════════════════════════════════════════${NC}"
    echo -e "${CYAN}    $1${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════${NC}"
}

# Function to create backup
create_backup() {
    local config_name="$1"
    local target_path="${CONFIG_PATHS[$config_name]}"
    
    if [[ -e "$target_path" ]]; then
        local backup_path="$BACKUP_DIR/$config_name"
        print_info "Backing up $config_name..."
        mkdir -p "$(dirname "$backup_path")"
        
        if [[ -f "$target_path" ]]; then
            cp "$target_path" "$backup_path"
        elif [[ -d "$target_path" ]]; then
            cp -r "$target_path" "$backup_path"
        fi
        
        print_message "Backup created: $backup_path"
    fi
}

# Function to download from GitHub
download_config() {
    local config_name="$1"
    local repo_path="$2"
    local local_path="${CONFIG_PATHS[$config_name]}"
    
    print_info "Downloading $config_name..."
    
    # Create directory
    mkdir -p "$local_path"
    
    # Download based on file type
    if [[ "$config_name" == "zshrc" ]]; then
        # Single file
        curl -sSL "https://raw.githubusercontent.com/eandset/Pink-Theme/main/$repo_path" \
            -o "$local_path" && print_message "✓ Downloaded $config_name"
    elif [[ "$config_name" == "wallpapers" ]]; then
        # Wallpapers - download all images
        mkdir -p "$local_path"
        # Try to download common wallpaper extensions
        for ext in jpg jpeg png webp; do
            # This is a simplified approach - in reality you'd need the actual file list
            print_warning "Wallpapers need to be downloaded manually from the repository"
        done
    else
        # Directory - use git sparse checkout or download individual files
        # For simplicity, we'll clone the specific directory
        print_info "Cloning $config_name configuration..."
        
        # Create temp directory
        mkdir -p "$TEMP_DIR"
        cd "$TEMP_DIR"
        
        # Clone only the specific directory
        git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" .
        git sparse-checkout init --cone
        git sparse-checkout set "$repo_path"
        
        # Copy files
        if [[ -d "$repo_path" ]]; then
            cp -r "$repo_path"/* "$local_path"/
            print_message "✓ Installed $config_name"
        else
            print_warning "Could not find $config_name in repository"
        fi
    fi
}

# Function to install specific config
install_single_config() {
    local config_name="$1"
    local repo_path="$2"
    
    print_section "${DESCRIPTIONS[$config_name]}"
    
    # Ask for confirmation
    read -p "Install ${DESCRIPTIONS[$config_name]}? [Y/n]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Nn]$ ]] && return 0
    
    # Create backup
    create_backup "$config_name"
    
    # Download and install
    download_config "$config_name" "$repo_path"
    
    # Post-install actions
    case "$config_name" in
        "zshrc"|"oh-my-zsh")
            print_info "Run ${CYAN}exec zsh${NC} to apply changes"
            ;;
        "hypr")
            print_info "Restart Hyprland to apply changes"
            ;;
    esac
}

# Function for quick install
quick_install() {
    print_section "Quick Installation"
    print_pink "Installing all Pink Theme configurations..."
    
    # Define configs to install with their repo paths
    declare -A REPO_PATHS=(
        ["hypr"]="hypr"
        ["waybar"]="waybar"
        ["kitty"]="kitty"
        ["rofi"]="rofi"
        ["fastfetch"]="fastfetch"
        ["yazi"]="yazi"
        ["zshrc"]=".zshrc"
    )
    
    for config_name in "${!REPO_PATHS[@]}"; do
        print_info "Installing ${DESCRIPTIONS[$config_name]}..."
        create_backup "$config_name"
        download_config "$config_name" "${REPO_PATHS[$config_name]}"
    done
    
    # Install Oh My Zsh theme if available
    print_info "Checking for Oh My Zsh theme..."
    local theme_url="https://raw.githubusercontent.com/eandset/Pink-Theme/main/oh-my-zsh/pink.zsh-theme"
    if curl --output /dev/null --silent --head --fail "$theme_url"; then
        mkdir -p "$HOME/.oh-my-zsh/custom/themes"
        curl -sSL "$theme_url" -o "$HOME/.oh-my-zsh/custom/themes/pink.zsh-theme"
        print_message "✓ Installed Pink Zsh theme"
    fi
}

# Function for custom install
custom_install() {
    print_section "Custom Installation"
    
    # Menu for selecting configs
    declare -A CONFIG_MENU=(
        ["1"]="hypr:Hyprland window manager"
        ["2"]="waybar:Waybar status bar"
        ["3"]="kitty:Kitty terminal"
        ["4"]="rofi:Rofi app launcher"
        ["5"]="fastfetch:Fastfetch system info"
        ["6"]="yazi:Yazi file manager"
        ["7"]="peaclock:Peaclock clock"
        ["8"]="oh-my-zsh:Oh My Zsh theme"
        ["9"]="zshrc:Zsh configuration"
        ["0"]="wallpapers:Wallpapers"
    )
    
    declare -A REPO_PATHS=(
        ["hypr"]="hypr"
        ["waybar"]="waybar"
        ["kitty"]="kitty"
        ["rofi"]="rofi"
        ["fastfetch"]="fastfetch"
        ["yazi"]="yazi"
        ["peaclock"]=".peaclock"
        ["oh-my-zsh"]="oh-my-zsh"
        ["zshrc"]=".zshrc"
        ["wallpapers"]="wallpapers"
    )
    
    echo "Select configurations to install (multiple choices allowed):"
    for key in "${!CONFIG_MENU[@]}"; do
        IFS=':' read -r id desc <<< "${CONFIG_MENU[$key]}"
        echo "  $key) $desc"
    done
    echo "  a) All configurations"
    echo "  q) Quit"
    
    read -p "Enter your choices (e.g., '1 3 5' or 'a'): " choices
    
    if [[ "$choices" == "q" ]]; then
        print_message "Installation cancelled"
        exit 0
    fi
    
    if [[ "$choices" == "a" ]]; then
        quick_install
        return
    fi
    
    # Install selected configs
    for choice in $choices; do
        if [[ -n "${CONFIG_MENU[$choice]}" ]]; then
            IFS=':' read -r config_name desc <<< "${CONFIG_MENU[$choice]}"
            install_single_config "$config_name" "${REPO_PATHS[$config_name]}"
        fi
    done
}

# Function to check dependencies
check_dependencies() {
    print_section "Checking Dependencies"
    
    local missing=()
    
    # Check for git
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing[*]}"
        print_info "Install with: sudo pacman -S ${missing[*]}"
        exit 1
    fi
    
    print_message "All dependencies satisfied"
}

# Function to clean up
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Main function
main() {
    clear
    echo -e "${PINK}"
    echo "╔══════════════════════════════════════════╗"
    echo "║        Pink Theme Config Installer       ║"
    echo "║            by @eandset                   ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    print_pink "Installing Pink Theme configurations..."
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Check dependencies
    check_dependencies
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    print_info "Backups will be saved to: $BACKUP_DIR"
    
    # Installation mode selection
    echo -e "\n${CYAN}Select installation mode:${NC}"
    echo "1) Quick install (recommended for new setup)"
    echo "2) Custom install (choose specific components)"
    echo "3) View repository"
    echo "4) Exit"
    
    read -p "Enter choice [1-4]: " -n 1 -r
    echo
    
    case $REPLY in
        1)
            quick_install
            ;;
        2)
            custom_install
            ;;
        3)
            print_info "Opening repository in browser..."
            xdg-open "$REPO_URL" 2>/dev/null || \
            print_info "Repository: $REPO_URL"
            exit 0
            ;;
        4|*)
            print_message "Exiting..."
            exit 0
            ;;
    esac
    
    # Final summary
    print_section "Installation Complete"
    
    if [[ -d "$BACKUP_DIR" ]] && [[ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        print_info "Backups saved to: $BACKUP_DIR"
        echo "To restore: cp -r $BACKUP_DIR/* ~/.config/"
    fi
    
    echo -e "\n${PINK}💖 Pink Theme installed successfully! 💖${NC}"
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo "1. Restart Hyprland: ${CYAN}Ctrl+Alt+F2${NC} (if locked) or logout/login"
    echo "2. Apply Zsh theme: ${CYAN}exec zsh${NC}"
    echo "3. Set wallpapers in ${CYAN}~/.config/hypr/hyprpaper.conf${NC}"
    echo "4. Customize colors in config files"
    
    # Show installation path
    print_info "Configurations installed to:"
    for config in "${!CONFIG_PATHS[@]}"; do
        if [[ -e "${CONFIG_PATHS[$config]}" ]]; then
            echo "  ✓ ${DESCRIPTIONS[$config]}: ${CONFIG_PATHS[$config]}"
        fi
    done
    
    echo -e "\n${GREEN}Enjoy your beautiful Pink Theme! 🎀${NC}"
}

# Run main function
main "$@"