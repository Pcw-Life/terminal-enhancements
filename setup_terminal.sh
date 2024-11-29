#!/bin/bash

# Exit on any error
set -e

# Ensure Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not installed. Please install Homebrew first."
  exit 1
fi

# Variables
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Functions
function handle_error {
  echo "ERROR: $1"
  echo "SUGGESTION: $2"
  exit 1
}

function ensure_plugin_installed {
  local plugin_name=$1
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
    echo "Installing $plugin_name plugin..."
    if [ "$plugin_name" = "zsh-history-substring-search" ]; then
      git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/$plugin_name ||
        handle_error "Failed to install $plugin_name plugin." "Check Git installation and internet connectivity."
    else
      git clone https://github.com/zsh-users/$plugin_name ${ZSH_CUSTOM}/plugins/$plugin_name ||
        handle_error "Failed to install $plugin_name plugin." "Check Git installation and internet connectivity."
    fi
  else
    echo "$plugin_name plugin is already installed."
  fi
}

function ensure_tool_installed {
  local tool_name=$1
  if ! command -v "$tool_name" >/dev/null 2>&1; then
    # Handle deprecated tools
    if [ "$tool_name" = "exa" ]; then
      echo "WARNING: $tool_name is deprecated. Replacing with lsd..."
      tool_name="lsd"
    fi
    echo "Installing $tool_name..."
    brew install $tool_name || handle_error "Failed to install $tool_name." "Ensure Homebrew is functional."
  else
    echo "$tool_name is already installed."
  fi
}

# Step 1: Install Oh My Zsh
echo "Checking for Oh My Zsh installation..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ||
    handle_error "Oh My Zsh installation failed." "Check internet connectivity."
else
  echo "Oh My Zsh is already installed."
fi

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
  echo "Backing up existing .zshrc..."
  cp ~/.zshrc ~/.zshrc.bak || handle_error "Failed to back up .zshrc." "Check file permissions and available disk space."
fi

# Step 2: Install Powerlevel10k
echo "Checking for Powerlevel10k theme installation..."
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k ||
    handle_error "Failed to install Powerlevel10k theme." "Check Git installation and internet connectivity."
fi

# Set Powerlevel10k as the theme
echo "Setting Powerlevel10k as the default theme..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc ||
    handle_error "Failed to set Powerlevel10k as the theme." "Check ~/.zshrc file permissions."
else
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc ||
    handle_error "Failed to set Powerlevel10k as the theme." "Check ~/.zshrc file permissions."
fi

# Step 3: Install Oh My Zsh Plugins
PLUGINS=(
  "zsh-autosuggestions"
  "zsh-syntax-highlighting"
  "zsh-completions"
  "zsh-history-substring-search"
)
echo "Installing Zsh plugins..."
for plugin in "${PLUGINS[@]}"; do
  ensure_plugin_installed "$plugin"
done

# Update plugins in .zshrc
echo "Updating plugins in .zshrc..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i.bak 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search)/' ~/.zshrc ||
    handle_error "Failed to update plugins in .zshrc." "Check ~/.zshrc file permissions."
else
  sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search)/' ~/.zshrc ||
    handle_error "Failed to update plugins in .zshrc." "Check ~/.zshrc file permissions."
fi

# Step 4: Install Common Tools
TOOLS=(thefuck z fd httpie tldr ncdu ranger lazygit bat lsd fzf shellcheck)
echo "Installing common tools..."
for tool in "${TOOLS[@]}"; do
  ensure_tool_installed "$tool"
done

# Configure fzf
echo "Configuring fzf..."
if ! $(brew --prefix)/opt/fzf/install --all; then
  handle_error "Failed to configure fzf." "Check fzf installation and retry."
fi

# Step 5: Configure Bash
if [ -f "$HOME/.bashrc" ]; then
  echo "Backing up existing .bashrc..."
  cp ~/.bashrc ~/.bashrc.bak || handle_error "Failed to back up .bashrc." "Check file permissions and available disk space."
fi

cat <<EOF >>~/.bashrc

# Common Tools for Bash
export PATH="\$PATH:/usr/local/bin"
EOF

# Final Configuration
echo "Finalizing configuration..."
source ~/.zshrc || handle_error "Failed to source .zshrc." "Ensure the file exists and has no syntax errors."
source ~/.bashrc || handle_error "Failed to source .bashrc." "Ensure the file exists and has no syntax errors."

echo "Setup complete! Open VS Code and the terminal to test your new configuration."
