#! /bin/bash

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
function ensure_plugin_installed {
  local plugin_name=$1
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
    echo "Installing $plugin_name plugin..."
    git clone https://github.com/zsh-users/$plugin_name ${ZSH_CUSTOM}/plugins/$plugin_name
  else
    echo "$plugin_name plugin is already installed."
  fi
}

function ensure_tool_installed {
  local tool_name=$1
  if ! command -v "$tool_name" >/dev/null 2>&1; then
    echo "Installing $tool_name..."
    brew install $tool_name
  else
    echo "$tool_name is already installed."
  fi
}

# Step 1: Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed."
fi

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc..."
    cp ~/.zshrc ~/.zshrc.bak
fi

# Step 2: Install Powerlevel10k
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
fi

# Set Powerlevel10k as the theme
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
else
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi

# Step 3: Install Oh My Zsh Plugins
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
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i.bak 's/^plugins=.*/plugins=(git ${PLUGINS[@]})/' ~/.zshrc
else
    sed -i 's/^plugins=.*/plugins=(git ${PLUGINS[@]})/' ~/.zshrc
fi
done

# Update plugins in .zshrc
sed -i.bak 's/^plugins=.*/plugins=(git ${PLUGINS[@]})/' ~/.zshrc

# Step 4: Install Common Tools
TOOLS=(thefuck z fd httpie tldr ncdu ranger lazygit bat exa fzf shellcheck)
for tool in "${TOOLS[@]}"; do
    ensure_tool_installed "$tool"
done

# Configure fzf
function configure_fzf {
  $(brew --prefix)/opt/fzf/install --all
}
configure_fzf

# Step 5: Configure Bash
if [ -f "$HOME/.bashrc" ]; then
    echo "Backing up existing .bashrc..."
    cp ~/.bashrc ~/.bashrc.bak
fi

cat <<EOF >> ~/.bashrc

# Common Tools for Bash
if [ -d "$HOME/Library/Application Support/Code/User" ]; then
  echo "Configuring VS Code terminal settings..."
  cat <<EOF >> "$HOME/Library/Application Support/Code/User/settings.json"
{
    "terminal.integrated.fontFamily": "MesloLGS NF",
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.fontSize": 14,
    "terminal.integrated.cursorStyle": "block",
    "terminal.integrated.cursorBlinking": true
}
EOF
fi
    "terminal.integrated.fontSize": 14,
    "terminal.integrated.cursorStyle": "block",
    "terminal.integrated.cursorBlinking": true
}
EOF
fi

# Final Configuration
source ~/.zshrc
source ~/.bashrc

echo "Setup complete! Open VS Code and the terminal to test your new configuration."
