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
echo "Waiting for Ollama server to become available..."
for i in {1..30}; do
    if curl -s http://127.0.0.1:11434 > /dev/null; then
        echo "Ollama server is up."
        break
    else
        echo "Waiting..."
        sleep 1
    fi
done
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

