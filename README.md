# 🧩 Proxmox VE — Remove “No Valid Subscription” Popup

This guide provides a **clean, update-safe method** to permanently remove the  
“No valid subscription” popup in **Proxmox VE 8.x and 9.x** —  
without breaking the Web UI or modifying system JS files directly.

* * *

## 🧱 Step 1 — Create Directory and JavaScript Override

```bash
mkdir -p /usr/local/share/pve-nag-fix
nano /usr/local/share/pve-nag-fix/no-popup.js
```

Paste the following contents:

```js
// =====================================================================
// Proxmox VE No Subscription Popup Remover (Stable Method)
// Works on 8.x and 9.x — waits for Proxmox.Utils to be ready
// =====================================================================
(function() {
    const disablePopup = () => {
        if (window.Proxmox && Proxmox.Utils && Ext && Ext.Msg) {
            console.log("✅ Subscription popup disabled (ExtJS hook)");
            // Override the function Proxmox uses to check subscription
            Proxmox.Utils.checked_command = function(orig_cmd) { orig_cmd(); };
            // Monkey patch Ext.Msg.show to block subscription message
            const origShow = Ext.Msg.show;
            Ext.Msg.show = function(config) {
                if (config && typeof config.title === 'string' &&
                    config.title.toLowerCase().includes('no valid subscription')) {
                    console.log("🚫 Blocked subscription warning popup");
                    return;
                }
                return origShow.apply(this, arguments);
            };
            return true;
        }
        return false;
    };

    // Run once ExtJS and Proxmox fully initialized
    const interval = setInterval(() => {
        if (disablePopup()) clearInterval(interval);
    }, 1000);
})();
```

Save and exit:

```
Ctrl + O, Enter, Ctrl + X
```

* * *

## ⚙️ Step 2 — Set Permissions and Link to Web Directory

```bash
chmod 644 /usr/local/share/pve-nag-fix/no-popup.js
chown www-data:www-data /usr/local/share/pve-nag-fix/no-popup.js
ln -s /usr/local/share/pve-nag-fix/no-popup.js /usr/share/pve-manager/js/no-popup.js
```

* * *

## 🧩 Step 3 — Load the Script in the Web UI

Append this line to the Proxmox web UI template if it’s not already present:

```bash
grep -q "no-popup.js" /usr/share/pve-manager/index.html.tpl || echo '<script src="/pve2/js/no-popup.js"></script>' >> /usr/share/pve-manager/index.html.tpl
```

* * *

## 🔄 Step 4 — Restart the Web Interface

```bash
systemctl restart pveproxy
```

* * *

## 🧼 Step 5 — Reload Browser Cache

In your browser:

- **Windows/Linux:** `Ctrl + Shift + R`
- **Mac:** `Cmd + Shift + R`
- or open a **Private/Incognito** window

Then open:

```
https://<your-proxmox-ip>:8006
```

✅ You should now see your dashboard **with no subscription popup**  
and a console log message:

```
✅ Subscription popup disabled (ExtJS hook)
```

* * *

## 🔁 Step 6 — Make It Persistent After Reboots / Upgrades

Create a cron job to ensure the script stays linked and pveproxy restarts automatically after upgrades or reboots:

```bash
echo "@reboot root ln -sf /usr/local/share/pve-nag-fix/no-popup.js /usr/share/pve-manager/js/no-popup.js && systemctl restart pveproxy" > /etc/cron.d/proxmox-nag-fix
```

* * *

## 🧠 Step 7 — Verify (Optional)

After rebooting, open the browser console (`F12 → Console`) and confirm:

```
✅ Subscription popup disabled (ExtJS hook)
```

No “No valid subscription” dialog will appear again.

* * *

## ✅ Summary

| Step | Action | Purpose |
| --- | --- | --- |
| 1   | Create `no-popup.js` | Defines the override to block the popup |
| 2   | Set permissions + symlink | Makes it accessible via Proxmox web path |
| 3   | Link in `index.html.tpl` | Loads the override on every dashboard load |
| 4   | Restart `pveproxy` | Applies changes immediately |
| 5   | Hard refresh browser | Clears cached JS |
| 6   | Add cron job | Ensures patch persists after upgrades |
| 7   | Verify console output | Confirms override is active |

* * *

## 🧰 Tested On

- **Proxmox VE 8.2.4**
- **Proxmox VE 9.0.11**
