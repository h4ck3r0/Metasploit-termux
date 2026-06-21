#!/data/data/com.termux/files/usr/bin/bash

################################################################
# Script Name : Metasploit Restore
# Author      : Raj Aryan (h4ck3r0)
# GitHub      : https://github.com/h4ck3r0/Metasploit-termux
################################################################

MSF_DIR="$HOME/metasploit-framework"

# termux-setup-storage creates ~/storage/shared → /sdcard
if [ -d "$HOME/storage/shared" ]; then
    SDCARD="$HOME/storage/shared"
else
    SDCARD="/sdcard"
fi

BACKUP_DIR="$SDCARD/MSF/backups"
INSTALLER_DIR="$HOME/Metasploit-termux"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

banner() {
    clear
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo -e "${GREEN}          METASPLOIT DATA RESTORE           ${RESET}"
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo -e "${YELLOW}   Author  : Raj Aryan (H4ck3r)            ${RESET}"
    echo -e "${YELLOW}   YouTube : Youtube.com/c/H4Ck3R0         ${RESET}"
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo ""
}

banner

# ── Check storage access ────────────────
if [ ! -d "$SDCARD" ]; then
    echo -e "${YELLOW}[*] Requesting storage permission...${RESET}"
    termux-setup-storage
    sleep 3
    # Re-detect after setup
    if [ -d "$HOME/storage/shared" ]; then
        SDCARD="$HOME/storage/shared"
        BACKUP_DIR="$SDCARD/MSF/backups"
    fi
fi

# ── Check backup folder exists ────────────────
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}[!] No backup folder found at: ${BACKUP_DIR}${RESET}"
    echo -e "${YELLOW}    Please create a backup first using Option 3.${RESET}"
    exit 1
fi

# ── List available backups ────────────────────
mapfile -t BACKUPS < <(ls -1 "$BACKUP_DIR" | grep -v "_gems$" | sort -r)

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}[!] No backups found in ${BACKUP_DIR}${RESET}"
    exit 1
fi

echo -e "${CYAN}Available backups (newest first):${RESET}\n"
for i in "${!BACKUPS[@]}"; do
    echo -e "  ${RED}[$((i+1))]${GREEN} ${BACKUPS[$i]}${RESET}"
done

echo ""
echo -ne "${CYAN}Choose backup to restore (or 0 to cancel): ${RESET}"
read -r choice

if [ "$choice" = "0" ] || [ -z "$choice" ]; then
    echo -e "${YELLOW}[!] Cancelled.${RESET}"
    exit 0
fi

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#BACKUPS[@]}" ]; then
    echo -e "${RED}[!] Invalid selection.${RESET}"
    exit 1
fi

SELECTED="${BACKUPS[$((choice-1))]}"
BACKUP_SOURCE="$BACKUP_DIR/$SELECTED"

echo -e "\n${YELLOW}[*] Selected: ${CYAN}$SELECTED${RESET}"

# ── Warn if MSF already installed ────────────
if [ -d "$MSF_DIR" ]; then
    echo -e "${YELLOW}[!] Existing Metasploit installation found.${RESET}"
    echo -ne "${RED}    Overwrite it? (y/N): ${RESET}"
    read -r confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${YELLOW}[!] Restore cancelled.${RESET}"
        exit 0
    fi
    rm -rf "$MSF_DIR"
fi

# ── Restore ───────────────────────────────────
echo -e "${GREEN}[*] Restoring from backup... (this may take a while)${RESET}"

cp -r "$BACKUP_SOURCE" "$MSF_DIR"

if [ $? -eq 0 ]; then
    # Restore gems if gem backup exists
    GEMS_BACKUP="$BACKUP_DIR/${SELECTED}_gems"
    if [ -d "$GEMS_BACKUP" ] && [ ! -d "$HOME/.gem" ]; then
        echo -e "${GREEN}[*] Restoring gem data...${RESET}"
        cp -r "$GEMS_BACKUP" "$HOME/.gem" 2>/dev/null || true
    fi

    echo -e "\n${GREEN}[✓] Restore successful!${RESET}"
    echo -e "${CYAN}    Run: ${GREEN}msfconsole${CYAN} to start Metasploit${RESET}\n"
else
    echo -e "${RED}[!] Restore failed. Could not copy files.${RESET}"
    exit 1
fi

sleep 2
cd "$INSTALLER_DIR" && bash metasploit.sh
