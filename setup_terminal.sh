#!/bin/bash

# Error handler: Prints an error message and a suggested fix
function handle_error {
    echo "ERROR: $1"          # Error message
    echo "SUGGESTION: $2"     # Suggested fix
    echo "Exiting with errors. Please review the suggestions and try again."
    exit 1
}

# Logging function
function log_info {
    echo "INFO: $1"
}

# Variables
# Define the custom directory for Oh My Zsh plugins and themes
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Function: Ensure a Zsh plugin is installed
# Parameters: Plugin name
function ensure_plugin_installed {
    local plugin_name=$1
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
        log_info "Installing $plugin_name plugin..."
        # Clone the plugin repository
        if ! git clone https://github.com/zsh-users/$plugin_name ${ZSH_CUSTOM}/plugins/$plugin_name; then
            # Handle cloning errors
            handle_error "Failed to clone $plugin_name plugin." \
                         "Ensure Git is installed and you have internet access."
        fi
    else
        log_info "$plugin_name plugin is already installed."
    fi
}

# Function: Ensure a tool is installed via Homebrew
# Parameters: Tool name
function ensure_tool_installed {
    local tool_name=$1
    if ! command -v "$tool_name" >/dev/null 2>&1; then
        log_info "Installing $tool_name..."
        # Install the tool using Homebrew
        if ! brew install $tool_name; then
            handle_error "Failed to install $tool_name." \
                         "Ensure Homebrew is installed and functional."
        fi
    else
        log_info "$tool_name is already installed."
    fi
}

# Step 1: Install Oh My Zsh
log_info "Checking for Oh My Zsh installation..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Oh My Zsh not found. Installing..."
    if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        handle_error "Oh My Zsh installation failed." \
                     "Check your internet connection and retry."
    fi
else
    log_info "Oh My Zsh is already installed."
fi

# Backup the existing .zshrc file if it exists
log_info "Checking for existing .zshrc file..."
if [ -f "$HOME/.zshrc" ]; then
    log_info "Backing up existing .zshrc..."
    if ! cp ~/.zshrc ~/.zshrc.bak; then
        handle_error "Failed to back up .zshrc." \
                     "Check file permissions and available disk space."
    fi
fi

# Step 2: Install Powerlevel10k theme
log_info "Checking for Powerlevel10k theme installation..."
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    log_info "Installing Powerlevel10k theme..."
    if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k; then
        handle_error "Failed to clone Powerlevel10k theme." \
                     "Ensure Git is installed and you have internet access."
    fi
else
    log_info "Powerlevel10k theme is already installed."
fi

# Set Powerlevel10k as the Zsh theme
log_info "Setting Powerlevel10k as the default Zsh theme..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc; then
        handle_error "Failed to set Powerlevel10k as the theme." \
                     "Check your ~/.zshrc file permissions."
    fi
else
    if ! sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc; then
        handle_error "Failed to set Powerlevel10k as the theme." \
                     "Check your ~/.zshrc file permissions."
    fi
fi

# Step 3: Install Zsh plugins
PLUGINS=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "zsh-completions"
    "history-substring-search"
)
log_info "Installing Zsh plugins..."
for plugin in "${PLUGINS[@]}"; do
    ensure_plugin_installed "$plugin"
done

# Update the plugins in the .zshrc file
log_info "Updating plugins in .zshrc..."
if ! sed -i.bak 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions history-substring-search)/' ~/.zshrc; then
    handle_error "Failed to update plugins in .zshrc." \
                 "Check your ~/.zshrc file permissions."
fi

# Step 4: Install common tools using Homebrew
TOOLS=(thefuck fd httpie tldr ncdu ranger lazygit bat exa fzf shellcheck)
log_info "Installing common tools..."
for tool in "${TOOLS[@]}"; do
    ensure_tool_installed "$tool"
done

# Configure fzf (fuzzy finder tool)
log_info "Configuring fzf..."
function configure_fzf {
    if ! $(brew --prefix)/opt/fzf/install --all; then
        handle_error "Failed to configure fzf." \
                     "Check if fzf is installed and retry."
    fi
}
configure_fzf

# Step 5: Install Wrangler and configure PATH
log_info "Installing Wrangler..."
if ! npm install -g wrangler@latest; then
    handle_error "Failed to install Wrangler." \
                 "Ensure Node.js and npm are installed and functional."
fi

log_info "Ensuring Wrangler is on the PATH..."
WRANGLER_PATH=$(npm root -g)/wrangler
if ! grep -q "$WRANGLER_PATH" <<< "$PATH"; then
    log_info "Adding Wrangler to PATH..."
    export PATH="$PATH:$WRANGLER_PATH"
    if ! grep -q "$WRANGLER_PATH" ~/.zshrc; then
        echo "export PATH=\"\$PATH:$WRANGLER_PATH\"" >> ~/.zshrc
        log_info "Wrangler path added to .zshrc."
    fi
else
    log_info "Wrangler is already on the PATH."
fi

# Step 6: Final Configuration
log_info "Finalizing configuration..."
log_info "Sourcing updated configuration files..."
source ~/.zshrc

# Print a success message
log_info "Setup complete! Open a new terminal or restart your shell to apply changes."
