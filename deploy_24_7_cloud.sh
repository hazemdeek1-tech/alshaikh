#!/usr/bin/env bash
# ==============================================================================
# Sheikh WhatsApp Bot v8.0 Pro - 24/7 Always-On Cloud Installer (Ubuntu/Debian)
# Works on Oracle Cloud Always Free (ARM/AMD), Hetzner, DigitalOcean, or any VPS
# Uses rclone FUSE mount to stream the 41 GB Google Drive library with 0 disk bloat
# Uses PM2 Process Manager for 24/7 auto-restart & survive-reboot persistence
# ==============================================================================
set -euo pipefail

APP_DIR="$HOME/sheikh_bot_v8"
DRIVE_MOUNT="$HOME/gdrive"
ARCHIVE_DIR="$DRIVE_MOUNT/Telegram_PDF_Archive"
BOT_DRIVE_DIR="$ARCHIVE_DIR/Sheikh_WhatsApp_Bot"

echo "============================================================"
echo "  SHEIKH BOT v8.0 PRO - 24/7 ALWAYS-ON CLOUD INSTALLER"
echo "============================================================"

# 1. Install system packages (Node.js 22, poppler-utils, fuse3, rclone, PM2)
sudo apt-get update -qq
sudo apt-get install -y -qq curl unzip fuse3 poppler-utils ca-certificates

if ! command -v node >/dev/null 2>&1 || [[ "$(node -v)" != v22* ]]; then
  echo "[1/5] Installing Node.js v22 LTS..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y -qq nodejs
fi

if ! command -v pm2 >/dev/null 2>&1; then
  echo "[2/5] Installing PM2 24/7 Watchdog..."
  sudo npm install -g pm2 --silent
fi

if ! command -v rclone >/dev/null 2>&1; then
  echo "[3/5] Installing rclone (for live Google Drive library mount)..."
  curl -fsSL https://rclone.org/install.sh | sudo bash
fi

# 2. Configure rclone remote 'gdrive' if not configured yet
if ! rclone listremotes | grep -q "^gdrive:$"; then
  echo ""
  echo ">>> ACTION NEEDED: Connect your Google Drive to rclone <<<"
  echo "Run: rclone config -> n (new remote) -> name: gdrive -> choose Google Drive"
  echo "Follow the link to authorize your Google account, then re-run this script."
  exit 1
fi

# 3. Create systemd service to mount Google Drive 24/7 automatically on boot
mkdir -p "$DRIVE_MOUNT" "$APP_DIR"
sudo tee /etc/systemd/system/rclone-gdrive.service >/dev/null <<EOF
[Unit]
Description=Rclone Google Drive Mount for Sheikh Bot v8 Pro
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=$USER
ExecStart=/usr/bin/rclone mount gdrive: $DRIVE_MOUNT --vfs-cache-mode minimal --vfs-cache-max-size 1G --dir-cache-time 5m --allow-non-empty
ExecStop=/bin/fusermount -uz $DRIVE_MOUNT
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now rclone-gdrive.service
sleep 4

# 4. Copy latest v8 Pro bot files from Google Drive and install npm deps
echo "[4/5] Syncing Sheikh Bot v8.0 Pro from Google Drive..."
cp "$BOT_DRIVE_DIR/sheikh_whatsapp_bot_v8.js" "$APP_DIR/sheikh_whatsapp_bot_v8.js"
cp "$BOT_DRIVE_DIR/package_v8.json" "$APP_DIR/package.json"
cp "$BOT_DRIVE_DIR/ecosystem.config.js" "$APP_DIR/ecosystem.config.js"

cd "$APP_DIR"
npm install --silent --no-audit --no-fund

# 5. Prompt for .env secrets once if not present
if [ ! -f "$APP_DIR/.env" ]; then
  read -rp "Enter GEMINI_API_KEY: " INPUT_KEY
  read -rp "Enter PAIRING_PHONE_NUMBER (e.g. 970597198032): " INPUT_PHONE
  read -rp "Enter OWNER_NUMBERS (comma-separated, e.g. 970597198032): " INPUT_OWNERS
  cat > "$APP_DIR/.env" <<EOF
GEMINI_API_KEY=$INPUT_KEY
GEMINI_MODEL=gemini-2.5-flash
PAIRING_PHONE_NUMBER=$INPUT_PHONE
OWNER_NUMBERS=$INPUT_OWNERS
ALLOW_PRIVATE_DM=true
ENABLE_MODERATION=true
ENABLE_ANTI_LINK=true
ENABLE_ANTI_SPAM=true
ENABLE_PASSIVE_ASSIST=true
ENABLE_AUTO_WELCOME=true
CHAT_COOLDOWN_MINUTES=10
UNIQUE_PDFS_DIR=$ARCHIVE_DIR/Unique_PDFs
INDEX_CSV_PATH=$ARCHIVE_DIR/Logs_and_State/whatsapp_bot_index.csv
AUTH_DIR=$ARCHIVE_DIR/Logs_and_State/sheikh_whatsapp_auth
STATE_DIR=$ARCHIVE_DIR/Logs_and_State
PORT=3000
EOF
  chmod 600 "$APP_DIR/.env"
fi

# 6. Start with PM2 and persist across server reboots
echo "[5/5] Launching Sheikh Bot v8.0 Pro in 24/7 mode..."
set -a; source "$APP_DIR/.env"; set +a
pm2 delete sheikh-bot-v8 >/dev/null 2>&1 || true
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u "$USER" --hp "$HOME" | tail -n 1 | bash || true

echo "============================================================"
echo "  SUCCESS! Sheikh Bot v8.0 Pro is running 24/7!"
echo "  View live logs: pm2 logs sheikh-bot-v8"
echo "  Restart bot:    pm2 restart sheikh-bot-v8"
echo "============================================================"
