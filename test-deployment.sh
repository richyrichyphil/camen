#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="camelion"
DOMAIN="jennymartinsblog.online"   # <-- update if needed
SOCKET_PATH="/run/gunicorn-$PROJECT_NAME.sock"

echo "🚀 Testing deployment of $PROJECT_NAME..."

# Detect environment
if [ -f /vagrant/Vagrantfile ]; then
  ENVIRONMENT="vagrant"
  echo "🧪 Running inside Vagrant"
else
  ENVIRONMENT="vps"
  echo "🖥️ Running on VPS"
fi

echo "[1/7] Checking Gunicorn service..."
if systemctl is-active --quiet gunicorn-$PROJECT_NAME; then
  echo "✅ Gunicorn service is running"
else
  echo "❌ Gunicorn service is NOT running"
fi

echo "[2/7] Checking Gunicorn socket..."
if [ -S "$SOCKET_PATH" ]; then
  echo "✅ Gunicorn socket exists at $SOCKET_PATH"
else
  echo "❌ Gunicorn socket missing at $SOCKET_PATH"
fi

echo "[3/7] Checking Nginx configuration..."
if nginx -t >/dev/null 2>&1; then
  echo "✅ Nginx config is valid"
else
  echo "❌ Nginx config has errors"
fi

echo "[4/7] Checking Nginx service..."
if systemctl is-active --quiet nginx; then
  echo "✅ Nginx is running"
else
  echo "❌ Nginx is NOT running"
fi

echo "[5/7] Checking UFW rules..."
if command -v ufw >/dev/null 2>&1; then
  if [ "$ENVIRONMENT" = "vagrant" ]; then
    echo "⚠️ Skipping UFW check inside Vagrant"
  else
    STATUS=$(sudo ufw status verbose)
    echo "🔒 UFW status:"
    echo "$STATUS"
  fi
else
  echo "⚠️ UFW not installed"
fi

echo "[6/7] Checking Fail2ban..."
if systemctl is-active --quiet fail2ban; then
  echo "✅ Fail2ban is running"
  sudo fail2ban-client status || true
else
  echo "❌ Fail2ban is NOT running"
fi

echo "[7/7] Testing site with curl..."

if [ "$ENVIRONMENT" = "vagrant" ]; then
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
  if [ "$STATUS" = "200" ]; then
    echo "✅ Site returned 200 OK on http://localhost"
  else
    echo "⚠️ Site returned HTTP $STATUS on http://localhost"
  fi
else
  STATUS_HTTPS=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN || true)
  STATUS_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN || true)

  if [ "$STATUS_HTTPS" = "200" ]; then
    echo "✅ Site returned 200 OK on https://$DOMAIN"
  else
    echo "⚠️ Site returned HTTP $STATUS_HTTPS on https://$DOMAIN"
  fi

  echo "🔍 Also testing HTTP (non-SSL)..."
  echo "ℹ️ Site returned HTTP $STATUS_HTTP on http://$DOMAIN"
  
  echo "🔐 Checking SSL certificate (expiry)..."
  echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates || echo "⚠️ Could not retrieve SSL certificate"
fi

echo "🎯 Deployment test complete!"
