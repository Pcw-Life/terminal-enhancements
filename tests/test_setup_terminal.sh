#! /bin/bash

# Test script for setup_terminal.sh

# Exit on any error
set -e

# Function to check if a command exists
function command_exists {
    command -v "$1" >/dev/null 2>&1
}

# Test Homebrew installation
if ! command_exists brew; then
    echo "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Test Oh My Zsh installation
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed. Please run setup_terminal.sh first."
    exit 1
else
    echo "Oh My Zsh is installed."
fi

# Test Powerlevel10k theme installation
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "Powerlevel10k theme is not installed. Please run setup_terminal.sh first."
    exit 1
else
    echo "Powerlevel10k theme is installed."
fi

# Test plugins installation
PLUGINS=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "zsh-completions"
    "history-substring-search"
    "zsh-navigation-tools"
    "wp-cli"
    "themes"
    "terraform"
    "systemd"
    "systemadmin"
    "rust"
    "please"
    "nomad"
    "n98-magerun"
    "magic-enter"
    "macos"
)
for plugin in "${PLUGINS[@]}"; do
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin" ]; then
        echo "$plugin plugin is not installed. Please run setup_terminal.sh first."
        exit 1
    else
        echo "$plugin plugin is installed."
    fi
done

# Test common tools installation
TOOLS=(thefuck z fd httpie tldr ncdu ranger lazygit bat exa fzf shellcheck)
for tool in "${TOOLS[@]}"; do
    if ! command_exists "$tool"; then
        echo "$tool is not installed. Please run setup_terminal.sh first."
        exit 1
    else
        echo "$tool is installed."
    fi
done

# Test fzf configuration
if [ ! -f "$HOME/.fzf.bash" ]; then
    echo "fzf is not configured. Please run setup_terminal.sh first."
    exit 1
else
    echo "fzf is configured."
fi

# Test .zshrc backup
if [ ! -f "$HOME/.zshrc.bak" ]; then
    echo ".zshrc backup is not created. Please run setup_terminal.sh first."
    exit 1
else
    echo ".zshrc backup is created."
fi

# Test .bashrc backup
if [ ! -f "$HOME/.bashrc.bak" ]; then
    echo ".bashrc backup is not created. Please run setup_terminal.sh first."
    exit 1
else
    echo ".bashrc backup is created."
fi

echo "All tests passed successfully!"
