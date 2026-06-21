
# Metasploit-Framework Installer for Termux

<p align="center">
  <img src="https://user-images.githubusercontent.com/46929618/154997514-8bd1d6c6-6b3d-4251-a6ce-6b8bceb22b06.png" width="100%" alt="Banner">
</p>

<p align="center">
<img title="Version" src="https://img.shields.io/badge/Version-3.0.0-green.svg?style=flat-square">
<img title="Maintained" src="https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=flat-square">
<img title="Proot" src="https://img.shields.io/badge/Method-Proot--Distro-blue.svg?style=flat-square">
<img title="Ruby" src="https://img.shields.io/badge/Ruby-3.4.x%20Compatible-red.svg?style=flat-square">
<img title="License" src="https://img.shields.io/badge/License-GNU-blue.svg?style=flat-square">
</p>

<p align="center">
<a href="https://github.com/h4ck3r0"><img title="Github" src="https://img.shields.io/badge/H4CK3R-RAJ-brightgreen?style=for-the-badge&logo=github"></a>
<a href="https://youtube.com/c/H4Ck3R0"><img title="YouTube" src="https://img.shields.io/badge/YouTube-H4CK3R-red?style=for-the-badge&logo=Youtube"></a>
<a href="https://h4ck3r.me"><img title="Website" src="https://img.shields.io/badge/Website-h4ck3r.me-yellow?style=for-the-badge&logo=blogger"></a>
</p>

---

## 🛡️ About

Since Metasploit was removed from the official Termux repositories, installing it became difficult due to **Ruby gem compilation errors** (Nokogiri/Gumbo, bundler conflicts, Ruby version mismatches). This script provides **three installation methods** — including the new recommended **proot-distro approach** which completely bypasses all gem errors using Rapid7's official pre-built package.

---

## 📊 Installation Methods

| Method | Android | Stability | Disk | Recommended |
|--------|---------|-----------|------|:-----------:|
| 🏆 **Proot-Distro (Debian)** | 7.0+ | ⭐⭐⭐⭐⭐ | ~300MB | ✅ **YES** |
| ⚙️ Direct Install (Modern) | 7.0+ | ⭐⭐⭐ | ~150MB | ⚠️ May have gem errors |
| 🕹️ Legacy Install | 4.4–6.0 | ⭐⭐ | ~150MB | For old devices only |

> **Why Proot?** Debian proot uses Rapid7's official omnibus package — a pre-compiled binary with its own embedded Ruby. No gem compilation, no Nokogiri errors, no bundler issues. Ever.

---

## 🛠️ Requirements

- **Termux** latest version from [F-Droid](https://f-droid.org/packages/com.termux/) *(NOT Play Store)*
- Minimum **2GB** free internal storage (3GB+ recommended for proot)
- Stable internet connection
- Android **7.0+** for proot method / Android **4.4+** for legacy

---

## 📥 Installation

```bash
# 1. Update Termux
apt update && apt upgrade -y

# 2. Install git
apt install git -y

# 3. Clone this repository
git clone https://github.com/h4ck3r0/Metasploit-termux

# 4. Enter directory
cd Metasploit-termux

# 5. Grant permissions
chmod +x *

# 6. Run installer
bash metasploit.sh
```

### Menu Options

```
[1] Metasploit Installation
    ├── [1] Legacy (Android 4.4 - 6.0)
    ├── [2] Modern Direct (Android 7.0+)
    └── [3] Proot-Distro / Debian  ← RECOMMENDED
[2] Repair
[3] Backup
[4] Restore
[5] Update
[6] Exit
```

> 💡 **Select Option 1 → then Option 3** for the most stable installation.

---

## 🎮 Usage Guide

### Launching Metasploit Console

```bash
msfconsole
```

This automatically:
- Starts PostgreSQL database
- Enters the Debian environment (proot method)
- Launches `msfconsole`

---


## 📁 Storage & File Access Guide

> **All paths below work inside the Debian proot environment.**

| Inside Debian | Maps to | Access from Android |
|---------------|---------|---------------------|
| `/sdcard/` | Phone internal storage | File Manager root |
| `/sdcard/MSF/payloads/` | Payload output folder | Internal Storage → MSF → payloads |
| `/sdcard/MSF/loot/` | Loot/captured data | Internal Storage → MSF → loot |
| `/sdcard/MSF/backups/` | Backup storage | Internal Storage → MSF → backups |
| `/root/msf-output/` | Alias for `/sdcard/MSF/` | Same as above |

### Entering the Debian shell

```bash
# Drop into a full Debian shell
msf-shell

# Inside Debian — build a tool, then copy to phone:
gcc exploit.c -o exploit
cp exploit /sdcard/MSF/exploit

# Exit back to Termux
exit
```

### Copy files between Debian and phone

```bash
# From inside Debian (msf-shell):
cp /root/myfile.apk /sdcard/MSF/myfile.apk

# From Termux (outside proot):
cp ~/proot-distro/installed-rootfs/debian/root/myfile /sdcard/MSF/
```

---

## 🔧 Repair

If Metasploit breaks after a Termux update:

```bash
bash metasploit.sh
# Choose Option 2 → Repair
```

The repair script will:
- Reinstall all dependencies
- Fix Nokogiri gem (Gumbo disabled)
- Reinstall bundle gems
- Fix PostgreSQL PID issues

---

## 💾 Backup & Restore

### Creating a Backup

```bash
bash metasploit.sh
# Choose Option 3 → Backup
```

Backup is saved to: **Internal Storage → MSF → backups/**  
You can view it from any Android file manager.

### Restoring a Backup

```bash
bash metasploit.sh
# Choose Option 4 → Restore
# Select backup from the numbered list
```

---

## 🔄 Update

```bash
bash metasploit.sh
# Choose Option 5 → Update
```

Or manually update MSF inside Debian (proot method):

```bash
msf-shell
apt update && apt upgrade metasploit-framework -y
exit
```

---

## ⚡ Android 12+ Fix (Phantom Process Killer)

Android 12+ aggressively kills background processes. To disable this:

```bash
# Requires ADB from a PC:
adb shell device_config set_sync_disabled_for_tests persistent
adb shell device_config put activity_manager max_phantom_processes 2147483647
```

Also: Go to **Android Settings → Apps → Termux → Battery → Unrestricted**

---

## ❓ Troubleshooting

| Problem | Fix |
|---------|-----|
| `msfconsole: command not found` | Re-run installer or check `ls $PREFIX/bin/msfconsole` |
| `Could not start server` (PostgreSQL) | `rm ~/proot-distro/installed-rootfs/debian/var/run/postgresql/.s.*` then retry |
| `Gem::LoadError` on startup | Run Repair from main menu |
| `bundle install` fails | Use proot method — bypasses all gem issues |
| Process killed by Android | Disable battery optimization for Termux |
| `/sdcard` not accessible | Run `termux-setup-storage` in Termux |
| `proot-distro: command not found` | `pkg install proot-distro` |

---

## 📢 Legal Disclaimer

> This tool is for **educational and authorized penetration testing purposes only**.  
> Unauthorized access to systems is **illegal**. The author is not responsible for misuse.  
> Always get **written permission** before testing any system you do not own.

---

## 🌐 Connect

<p align="left">
  <a href="https://www.h4ck3r.me">
    <img src="https://img.shields.io/badge/Website-h4ck3r.me-yellow?style=for-the-badge&logo=blogger" alt="Website">
  </a>
  <a href="https://t.me/h4ck3r_group">
    <img src="https://img.shields.io/badge/Telegram-Channel-blue?style=for-the-badge&logo=telegram" alt="Telegram">
  </a>
  <a href="https://www.instagram.com/h4ck3r0_official">
    <img src="https://img.shields.io/badge/Instagram-Follow-red?style=for-the-badge&logo=instagram" alt="Instagram">
  </a>
</p>

<a href="https://www.buymeacoffee.com/h4ck3r" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 50px !important;width: 180px !important;">
</a>

---

**Developed by Raj Aryan (h4ck3r0)** — *Give a ⭐ if this helped you!*
