#!/bin/bash
# ==================================================================
# Proxmox Subscription Popup Remover Installer
# ==================================================================
set -e

echo "🧱 Creating directory..."
mkdir -p /usr/local/share/pve-nag-fix

echo "📦 Copying no-popup.js..."
cp "$(dirname "$0")/../scripts/no-popup.js" /usr/local/share/pve-nag-fix/no-popup.js

echo "🔧 Setting permissions..."
chmod 644 /usr/local/share/pve-nag-fix/no-popup.js
chown www-data:www-data /usr/local/share/pve-nag-fix/no-popup.js

echo "🔗 Linking file..."
ln -sf /usr/local/share/pve-nag-fix/no-popup.js /usr/share/pve-manager/js/no-popup.js

echo "⚙️ Adding to web UI template..."
grep -q "no-popup.js" /usr/share/pve-manager/index.html.tpl || \
echo '<script src="/pve2/js/no-popup.js"></script>' >> /usr/share/pve-manager/index.html.tpl

echo "🧰 Restarting pveproxy..."
systemctl restart pveproxy

echo "🕓 Setting persistence..."
echo "@reboot root ln -sf /usr/local/share/pve-nag-fix/no-popup.js /usr/share/pve-manager/js/no-popup.js && systemctl restart pveproxy" > /etc/cron.d/proxmox-nag-fix

echo "✅ All done! Open your Proxmox UI and verify the popup is gone."

chmod +x install/popup-fix.sh
