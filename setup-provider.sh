#!/bin/bash

# Script to install and set up the Kaisar CLI on Linux systems
# Supported: Ubuntu 20.04, 22.04, 24.04, and compatible distributions

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo: sudo ./kaisar-provider-setup.sh"
  exit 1
fi

# Fix repository issues for Ubuntu-based systems
fix_repositories() {
  if grep -q 'id.archive.ubuntu.com' /etc/apt/sources.list; then
    echo "Fixing repository URLs..."
    sed -i 's|id.archive.ubuntu.com|archive.ubuntu.com|g' /etc/apt/sources.list
    sed -i 's|http://archive.ubuntu.com|https://archive.ubuntu.com|g' /etc/apt/sources.list
    sed -i 's|http://security.ubuntu.com|https://security.ubuntu.com|g' /etc/apt/sources.list
  fi
}

# Check and install Node.js if not present
install_nodejs() {
  if command -v node >/dev/null 2>&1; then
    echo "Node.js is already installed: $(node -v)"
  else
    echo "Installing Node.js..."
    
    # Identify distribution
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case $ID in
        ubuntu|debian)
          fix_repositories
          curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
          apt-get update
          apt-get install -y nodejs
          ;;
        centos|rhel|fedora|rocky|almalinux)
          curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -
          yum install -y nodejs
          ;;
        *)
          echo "Unsupported Linux distribution. Please install Node.js manually."
          exit 1
          ;;
      esac
    else
      echo "Unsupported Linux distribution. Please install Node.js manually."
      exit 1
    fi
    
    echo "Node.js installed: $(node -v)"
  fi
}

# Check and install npm if not present
install_npm() {
  if command -v npm >/dev/null 2>&1; then
    echo "npm is already installed: $(npm -v)"
  else
    echo "Installing npm..."
    
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case $ID in
        ubuntu|debian)
          apt-get install -y npm
          ;;
        centos|rhel|fedora|rocky|almalinux)
          yum install -y npm
          ;;
        *)
          echo "Unsupported Linux distribution. Please install npm manually."
          exit 1
          ;;
      esac
    fi
    
    echo "npm installed: $(npm -v)"
  fi
}

# Check and install pm2 if not present
install_pm2() {
  if npm list -g pm2 >/dev/null 2>&1; then
    echo "pm2 is already installed: $(pm2 --version)"
  else
    echo "Installing pm2 globally..."
    npm install -g pm2
    echo "pm2 installed: $(pm2 --version)"
  fi
}

# Check and install curl if not present
install_curl() {
  if command -v curl >/dev/null 2>&1; then
    echo "curl is already installed"
  else
    echo "Installing curl..."
    
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case $ID in
        ubuntu|debian)
          apt-get update
          apt-get install -y curl
          ;;
        centos|rhel|fedora|rocky|almalinux)
          yum install -y curl
          ;;
        *)
          echo "Unsupported Linux distribution. Please install curl manually."
          exit 1
          ;;
      esac
    fi
  fi
}

# Check and install tar if not present
install_tar() {
  if command -v tar >/dev/null 2>&1; then
    echo "tar is already installed"
  else
    echo "Installing tar..."
    
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case $ID in
        ubuntu|debian)
          apt-get install -y tar
          ;;
        centos|rhel|fedora|rocky|almalinux)
          yum install -y tar
          ;;
      esac
    fi
  fi
}

# Main installation process
install_curl
install_nodejs
install_npm
install_pm2
install_tar

# Show versions
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "pm2 version: $(pm2 --version)"

# Get latest version info from Kaisar API
echo "Checking latest Kaisar Provider CLI version..."
API_URL="https://app-api.kaisar.io/kavm/check-version/0?app=provider-cli&platform=linux"
VERSION_INFO=$(curl -fsSL "$API_URL")
DOWNLOAD_URL=$(echo "$VERSION_INFO" | grep -oP '"downloadUrl"\s*:\s*"\K[^"]+')
LATEST_VERSION=$(echo "$VERSION_INFO" | grep -oP '"latestVersion"\s*:\s*"\K[^"]+')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: Could not fetch download URL from API."
  exit 1
fi

# Prepare install directory
INSTALL_DIR="/opt/kaisar-provider-cli-$LATEST_VERSION"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Create data directory with proper permissions
DATA_DIR="/var/lib/kaisar-provider-cli"
sudo mkdir -p "$DATA_DIR"
sudo chmod 777 "$DATA_DIR"

# Download and extract the release package
echo "Downloading Kaisar Provider CLI package from $DOWNLOAD_URL..."
curl -fL "$DOWNLOAD_URL" -o kaisar-provider-cli.tar.gz || {
  echo "Error: Unable to download package."
  exit 1
}

echo "Extracting package..."
tar -xzf kaisar-provider-cli.tar.gz
rm kaisar-provider-cli.tar.gz

# Install dependencies
if [ -f package.json ]; then
  echo "Installing dependencies..."
  npm install --production
else
  echo "Error: package.json not found in extracted package."
  exit 1
fi

# Link CLI globally
echo "Linking CLI globally..."
npm link || {
  echo "Error: Unable to link CLI globally. Please check your npm permissions."
  exit 1
}

# Add environment variable to profile
echo "Setting up environment variables..."
ENV_SETUP="export KAISAR_DATA_DIR=\"$DATA_DIR\""

# Add to profile files
for profile_file in /etc/profile /etc/bash.bashrc /etc/bashrc ~/.bashrc ~/.bash_profile ~/.profile; do
  if [ -f "$profile_file" ]; then
    if ! grep -q "KAISAR_DATA_DIR" "$profile_file"; then
      echo "$ENV_SETUP" >> "$profile_file"
      echo "Added to $profile_file"
    fi
  fi
done

# Verify installation
echo "Verifying installation..."
export KAISAR_DATA_DIR="$DATA_DIR"
kaisar --version || {
  echo "Error: Installation verification failed. The 'kaisar' command might not be available until you restart your terminal."
  echo "However, the installation might have completed. Try restarting the terminal and then run: kaisar --version"
  exit 1
}

echo "--------------------------------------------------"
echo "Installation successful! You can now use the CLI with the 'kaisar' command."
echo "Example commands:"
echo "  kaisar start   # Start the Provider Application"
echo "  kaisar status  # Check the status of the Provider Application"
echo "  kaisar logs    # View application logs"
echo ""
echo "Note: You might need to restart your terminal or run:"
echo "      source ~/.bashrc"
echo "to make the 'kaisar' command available immediately"
echo "--------------------------------------------------"
