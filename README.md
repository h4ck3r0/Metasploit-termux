
# Metasploit-Framework Installer for Termux



<p align="center">
  <img src="https://user-images.githubusercontent.com/46929618/154997514-8bd1d6c6-6b3d-4251-a6ce-6b8bceb22b06.png" width="100%" alt="Banner">
</p>
<p align="center">
<img title="Version" src="https://img.shields.io/badge/Version-2.5.0-green.svg?style=flat-square">
<img title="Maintainence" src="https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=flat-square">
<img title="Ruby" src="https://img.shields.io/badge/Ruby-3.4.0%20Compatible-red.svg?style=flat-square">
<img title="License" src="https://img.shields.io/badge/License-GNU-blue.svg?style=flat-square">
</p>
<p align="center">
<a href="https://github.com/h4ck3r0"><img title="Github" src="https://img.shields.io/badge/H4CK3R-RAJ-brightgreen?style=for-the-badge&logo=github"></a>
<a href="https://youtube.com/c/H4Ck3R0"><img title="YouTube" src="https://img.shields.io/badge/YouTube-H4CK3R-red?style=for-the-badge&logo=Youtube"></a>
</p>

---

### 🛡️ ABOUT THE TOOL
Since Metasploit was removed from the official Termux repositories, installing it has become difficult. This advanced script automates the installation of the latest **Metasploit-Framework** and specifically fixes the common **Nokogiri/Gumbo** compilation errors found in newer Ruby versions.

### 🚀 FEATURES
* **[+]** Automatic Ruby 3.4.0 Gumbo Header Patch.
* **[+]** Optimized for ARM/ARM64 architectures.
* **[+]** Silent installation mode (logs errors to `install.log`).
* **[+]** Auto-initialization of PostgreSQL Database.
* **[+]** Stale PID cleanup (Fixes "Could not start server" errors).

### 🛠️ REQUIREMENTS
* Termux (Latest version from F-Droid)
* Minimum 2GB Internal Storage
* Stable Internet Connection

### 📥 INSTALLATION

```bash
# Update and upgrade system
apt update && apt upgrade -y

# Install git
apt install git -y

# Clone the repository
git clone [https://github.com/h4ck3r0/Metasploit-termux](https://github.com/h4ck3r0/Metasploit-termux)

# Enter directory
cd Metasploit-termux

# Grant execution permission
chmod +x *

# Run the installer
bash metasploit.sh
```


### 🎮 USAGE

After successful installation, simply type:

```bash
msfconsole

```

For payload generation:

```bash
msfvenom

```

---

### 📢 IMPORTANT NOTICE

Metasploit is resource-intensive. If the process is killed by Android, ensure you have disabled "Battery Optimization" for Termux.

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
