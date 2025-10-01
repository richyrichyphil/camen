#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="camelion"
PROJECT_USER="camelionuser"
PROJECT_DIR="/srv/$PROJECT_NAME"
REPO_URL="https://github.com/richyrichyphil/camen.git"
DOMAIN="jennymartinsblog.online"   # <-- change this to your real domain

echo "[1/8] Updating system..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "[2/8] Installing base packages..."
sudo apt-get install -y python3-venv python3-dev build-essential \
    nginx git curl ufw fail2ban certbot python3-certbot-nginx

echo "[3/8] Creating project user and directories..."
sudo adduser --system --group --home "$PROJECT_DIR" "$PROJECT_USER" || true
sudo mkdir -p "$PROJECT_DIR"
sudo chown -R "$PROJECT_USER":"$PROJECT_USER" "$PROJECT_DIR"

echo "[4/8] Cloning repo and installing dependencies..."
sudo -u "$PROJECT_USER" -H bash <<EOF
cd "$PROJECT_DIR"
if [ ! -d "app" ]; then
  git clone "$REPO_URL" app
fi
cd app
python3 -m venv ../venv
source ../venv/bin/activate
pip install --upgrade pip
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
else
  pip install django gunicorn
fi
EOF

echo "[4.5/8] Setting up static and media directories and collecting static files..."
sudo -u "$PROJECT_USER" -H bash <<EOF
cd "$PROJECT_DIR/app"
mkdir -p ../media ./staticfiles
source ../venv/bin/activate
python manage.py collectstatic --noinput
EOF

sudo chown -R $PROJECT_USER:www-data $PROJECT_DIR/app/staticfiles $PROJECT_DIR/media
sudo chmod -R 755 $PROJECT_DIR/app/staticfiles $PROJECT_DIR/media


echo "[5/8] Creating env file..."
sudo mkdir -p /etc/$PROJECT_NAME
cat <<EOT | sudo tee /etc/$PROJECT_NAME/$PROJECT_NAME.env > /dev/null
DJANGO_SETTINGS_MODULE=base.settings
SECRET_KEY=$(openssl rand -hex 32)
DEBUG=False
ALLOWED_HOSTS=$DOMAIN,www.$DOMAIN,127.0.0.1,localhost
EOT

echo "[6/8] Creating systemd service for Gunicorn..."
cat <<EOT | sudo tee /etc/systemd/system/gunicorn-$PROJECT_NAME.service > /dev/null
[Unit]
Description=gunicorn for $PROJECT_NAME
After=network.target

[Service]
User=$PROJECT_USER
Group=www-data
WorkingDirectory=$PROJECT_DIR/app
EnvironmentFile=/etc/$PROJECT_NAME/$PROJECT_NAME.env
ExecStart=$PROJECT_DIR/venv/bin/gunicorn \\
    --access-logfile - \\
    --workers 3 \\
    --bind unix:/run/gunicorn-$PROJECT_NAME.sock \\
    base.wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
EOT

sudo mkdir -p /run
sudo chown $PROJECT_USER:www-data /run

echo "[7/8] Configuring Nginx..."
sudo tee /etc/nginx/sites-available/$PROJECT_NAME > /dev/null <<EOT
server {
    listen 80;
    server_name $DOMAIN;

    location /static/ {
        alias /srv/camelion/app/staticfiles/;
        expires 30d;
        access_log off;
        add_header Cache-Control "public";
    }

    location /media/ {
        alias /srv/camelion/media/;
        expires 30d;
        access_log off;
        add_header Cache-Control "public";
    }

    location / {
        proxy_pass http://unix:/run/gunicorn-$PROJECT_NAME.sock;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOT

sudo ln -sf /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl daemon-reload
sudo systemctl enable --now gunicorn-$PROJECT_NAME
sudo systemctl restart nginx

echo "[Securing VPS: UFW firewall rules]"
sudo ufw allow OpenSSH
sudo ufw allow "Nginx Full"
sudo ufw --force enable

echo "[Enabling HTTPS with Certbot]"
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN || true
sudo systemctl reload nginx

echo "[8/8] Configuring Fail2ban..."
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.backup

cat <<EOF | sudo tee /etc/fail2ban/jail.local
[DEFAULT]
bantime  = 10m
findtime  = 10m
maxretry = 5
banaction = ufw

[sshd]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5

[nginx-http-auth]
enabled  = true
filter   = nginx-http-auth
port     = http,https
logpath  = /var/log/nginx/error.log
maxretry = 3

[nginx-badbots]
enabled  = true
filter   = nginx-badbots
port     = http,https
logpath  = /var/log/nginx/access.log
maxretry = 2

[nginx-noscript]
enabled  = true
filter   = nginx-noscript
port     = http,https
logpath  = /var/log/nginx/access.log
maxretry = 2

[nginx-django-admin]
enabled  = true

filter   = nginx-django-admin
port     = http,https
logpath  = /var/log/nginx/access.log

maxretry = 3
EOF

cat <<EOF | sudo tee /etc/fail2ban/filter.d/nginx-django-admin.conf
[Definition]

failregex = ^<HOST> -.*"(GET|POST).*\\/admin\\/.*" 401
ignoreregex =
EOF

sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

echo "✅ VPS Deployment finished!"
echo "Visit: https://$DOMAIN"
