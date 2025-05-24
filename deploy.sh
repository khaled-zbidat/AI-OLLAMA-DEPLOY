#!/bin/bash
set -e

PROJECT_DIR="$1"
cd "$PROJECT_DIR"

echo "Starting deployment..."

# Install Ollama if not already installed
if ! command -v ollama &> /dev/null; then
  echo "Ollama not found. Installing..."
  curl -fsSL https://ollama.com/install.sh | sh
fi
echo "pull phi"
ollama pull phi

# Update the systemd service to listen on all interfaces
echo "Updating ollama.service to listen on 0.0.0.0..."

sudo cp ollama.service /etc/systemd/system

# Reload systemd and restart the Ollama service
echo "  Installing systemd service..."
sudo systemctl daemon-reload
sudo systemctl restart ollama
sudo systemctl enable ollama
echo " Service reloaded and restarted."
if ! systemctl is-active --quiet ollama.service; then
  echo "❌ ollama.service is not running Yet."
  sudo systemctl status ollama.service --no-pager
  exit 1
fi
echo "✅ Deployment completed successfully."

