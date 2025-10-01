#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="camelion"
PROJECT_USER="camelionuser"
PROJECT_DIR="/srv/$PROJECT_NAME"
DOMAIN="yourdomain.com"  # Change if needed

echo "🚨 Rolling back VPS deployment of $PROJECT_NAME..."

# Stop and disable gunicorn
sudo systemctl stop gunicorn-$PROJECT_NAME || true
sudo systemctl disable gunicorn-$PROJECT_NAME || true

# Remove gunicorn service and reload systemd
sudo rm -f /etc/systemd/system/gunicorn-$PROJECT_NAME.service
sudo systemctl daemon-reload

# Remove environment file
sudo rm -rf /etc/$PROJECT_NAME

# Remove project files
sudo rm -rf "$PROJECT_DIR"

# Remove Gunicorn socket if lingering
sudo rm -f /run/gunicorn-$PROJECT_NAME.sock || true

# Remove nginx config
sudo rm -f /etc/nginx/sites-available/$PROJECT_NAME
sudo rm -f /etc/nginx/sites-enabled/$PROJECT_NAME

# Reload nginx
sudo nginx -t || true
sudo systemctl restart nginx

# Optional: Delete SSL cert (only if you're not going to use it again)
# sudo certbot delete --cert-name $DOMAIN || true

# Optional: Delete user (comment out if you plan to reuse)
sudo deluser --remove-home $PROJECT_USER || true

echo "✅ VPS rollback complete!"
