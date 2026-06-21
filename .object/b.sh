#!/data/data/com.termux/files/usr/bin/bash

################################################################
# Script Name : Metasploit Backup
# Author      : Raj Aryan (h4ck3r0)
# GitHub      : https://github.com/h4ck3r0/Metasploit-termux
################################################################

MSF_DIR="$HOME/metasploit-framework"
BACKUP_NAME="msf_backup_$(date +%Y%m%d_%H%M%S)"

# termux-setup-storage creates ~/storage/shared → /sdcard
if [ -d "$HOME/storage/shared" ]; then
    SDCARD="$HOME/storage/shared"
else
    SDCARD="/sdcard"
fi

BACKUP_DEST="$SDCARD/MSF/backups"
INSTALLER_DIR="$HOME/Metasploit-termux"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

banner() {
    clear
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo -e "${GREEN}         METASPLOIT DATA BACKUP             ${RESET}"
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo -e "${YELLOW}   Author  : Raj Aryan (H4ck3r)            ${RESET}"
    echo -e "${YELLOW}   YouTube : Youtube.com/c/H4Ck3R0         ${RESET}"
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo ""
}

banner

# ── Check Metasploit is installed ────────────
if [ ! -d "$MSF_DIR" ]; then
    echo -e "${RED}[!] Metasploit is not installed.${RESET}"
    echo -e "${YELLOW}    Please install it first.${RESET}"
    sleep 2
    cd "$INSTALLER_DIR" && bash metasploit.sh
    exit 1
fi

# ── Setup storage (only if not accessible) ───
if [ ! -d "$SDCARD" ]; then
    echo -e "${YELLOW}[*] Requesting storage permission...${RESET}"
    termux-setup-storage
    sleep 3
    # Re-detect after setup
    if [ -d "$HOME/storage/shared" ]; then
        SDCARD="$HOME/storage/shared"
        BACKUP_DEST="$SDCARD/MSF/backups"
    fi
fi

# ── Create backup destination ─────────────────
mkdir -p "$BACKUP_DEST"

echo -e "${YELLOW}[*] Backing up Metasploit to: ${CYAN}$BACKUP_DEST/$BACKUP_NAME${RESET}"
echo -e "${YELLOW}    This may take up to 2 minutes. Please wait...${RESET}\n"

# ── Copy MSF directory ────────────────────────
cp -r "$MSF_DIR" "$BACKUP_DEST/$BACKUP_NAME"

if [ $? -eq 0 ]; then
    # Also backup gem data if it exists
    if [ -d "$HOME/.gem" ]; then
        echo -e "${YELLOW}[*] Backing up gem data...${RESET}"
        cp -r "$HOME/.gem" "$BACKUP_DEST/${BACKUP_NAME}_gems" 2>/dev/null || true
    fi

    echo -e "\n${GREEN}[✓] Backup complete!${RESET}"
    echo -e "${CYAN}    Location : ${GREEN}$BACKUP_DEST/$BACKUP_NAME${RESET}"
    echo -e "${CYAN}    Access   : Android File Manager → Internal Storage → MSF → backups/${RESET}"
    echo -e "${YELLOW}    Restore  : Use Option 4 from the main menu${RESET}\n"
else
    echo -e "${RED}[!] Backup failed. Check storage permissions.${RESET}"
    exit 1
fi

sleep 2
cd "$INSTALLER_DIR" && bash metasploit.sh
