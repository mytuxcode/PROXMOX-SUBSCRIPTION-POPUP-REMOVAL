# 🧩 Proxmox VE — Remove “No Valid Subscription” Popup

This repository provides a **clean, update-safe method** to permanently remove the  
**“No valid subscription”** popup in **Proxmox VE 8.x and 9.x**,  
without modifying core JavaScript files or breaking the Web UI.

---

## ⚙️ Overview

**Key Features:**
- Safe for both **Proxmox VE 8.x** and **9.x**
- Survives **reboots** and **package upgrades**
- No system file overwrites
- Uses a persistent cron job for reliability
- Quick, script-based installation

---

## 📂 Repository Structure

```
PROXMOX-SUBSCRIPTION-POPUP-REMOVAL/
│
├── install/
│   └── popup-fix.sh          # Automated installer script
│
├── scripts/
│   └── no-popup.js           # JavaScript override
│
├── LICENSE                   # Open-source license
└── README.md                 # Documentation (this file)
```

---

## 🚀 Installation Instructions

> **⚠️ Run as root (or with sudo)**  
> Required because the script modifies files in `/usr/share` and `/usr/local/share`.

### 1️⃣ Clone the Repository

```bash
git clone git@github.com:mytuxcode/PROXMOX-SUBSCRIPTION-POPUP-REMOVAL.git
cd PROXMOX-SUBSCRIPTION-POPUP-REMOVAL
```

### 2️⃣ Make the Installer Executable

```bash
chmod +x install/popup-fix.sh
```

### 3️⃣ Run the Installer

```bash
sudo ./install/popup-fix.sh
```

---

## 🧱 What the Script Does

| Step | Action | Purpose |
|------|---------|----------|
| 1 | Create `/usr/local/share/pve-nag-fix` | Stores the JavaScript override |
| 2 | Copy `no-popup.js` | Places the popup-blocker script safely outside system paths |
| 3 | Set permissions | Ensures access for the `www-data` process |
| 4 | Symlink to web directory | Makes the script available to the Web UI |
| 5 | Patch `index.html.tpl` | Automatically loads the script on every dashboard page |
| 6 | Restart `pveproxy` | Reloads the web interface |
| 7 | Add cron job | Ensures persistence after reboot or upgrades |

---

## 🔍 Example Output

When run successfully, you’ll see:

```
🧱 Creating directory...
📦 Copying no-popup.js...
🔧 Setting permissions...
🔗 Linking file...
⚙️ Adding to web UI template...
🧰 Restarting pveproxy...
🕓 Setting persistence...
✅ All done! Open your Proxmox UI and verify the popup is gone.
```

---

## 💻 Browser Verification

After running the installer:

1. Open your Proxmox web dashboard:
   ```
   https://<your-proxmox-ip>:8006
   ```
2. Press **F12 → Console**
3. Confirm you see:
   ```
   ✅ Subscription popup disabled (ExtJS hook)
   ```
4. No “No valid subscription” dialog should appear again.

---

## 🧠 Manual Installation (if not using script)

If you prefer to perform the steps manually, follow the guide below:

1. **Create Directory and Script**
   ```bash
   mkdir -p /usr/local/share/pve-nag-fix
   nano /usr/local/share/pve-nag-fix/no-popup.js
   ```

2. **Paste the script contents from**  
   [`scripts/no-popup.js`](scripts/no-popup.js)

3. **Set permissions, link, and restart**
   ```bash
   chmod 644 /usr/local/share/pve-nag-fix/no-popup.js
   chown www-data:www-data /usr/local/share/pve-nag-fix/no-popup.js
   ln -s /usr/local/share/pve-nag-fix/no-popup.js /usr/share/pve-manager/js/no-popup.js
   systemctl restart pveproxy
   ```

4. **Make persistent**
   ```bash
   echo "@reboot root ln -sf /usr/local/share/pve-nag-fix/no-popup.js /usr/share/pve-manager/js/no-popup.js && systemctl restart pveproxy" > /etc/cron.d/proxmox-nag-fix
   ```

---

## 🧩 Tested On

| Proxmox VE Version | Status |
|--------------------|--------|
| 8.2.4 | ✅ Working |
| 9.0.11 | ✅ Working |


---

## 🧰 License

Released under the **MIT License**.  
Feel free to reuse, modify, or redistribute with attribution.

---

## 🐧 Author

**Maintainer:** [@mytuxcode](https://github.com/mytuxcode)  
If this project helps you, consider starring ⭐ the repository!

---

## ✅ Summary

| Step | Description |
|------|--------------|
| Clone the repo | `git clone git@github.com:mytuxcode/PROXMOX-SUBSCRIPTION-POPUP-REMOVAL.git` |
| Make executable | `chmod +x install/popup-fix.sh` |
| Run the script | `sudo ./install/popup-fix.sh` |
| Verify in browser | Popup gone + “✅ Subscription popup disabled” in console |
| Persistent fix | Cron job ensures survival through updates |

---

> 💬 *This solution was designed to be safe, reversible, and update-resilient — a professional-grade way to silence the Proxmox subscription reminder permanently.*
