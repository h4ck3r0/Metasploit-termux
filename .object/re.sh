#!/bin/bash


HOME_DIR="$HOME"
MSF_DIR="$HOME_DIR/metasploit-framework"
BACKUP_SOURCE="/sdcard/backup"
TEMP_BACKUP_DIR="$HOME_DIR/backup"
INSTALLER_DIR="$HOME_DIR/Metasploit-termux"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'



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

start_restore() {
    banner
    
    if [ -d "$MSF_DIR" ]; then
        echo -e "${YELLOW}[!] Metasploit is already present in Termux.${RESET}"
        echo -e "${RED}    Please remove the existing installation before restoring.${RESET}"
        echo ""
        exit 1
    fi

    echo -e "${GREEN}[*] Requesting storage access...${RESET}"
    termux-setup-storage
    sleep 1

    if [ ! -d "$BACKUP_SOURCE" ]; then
        echo -e "${RED}[!] No backup found at ${BACKUP_SOURCE}${RESET}"
        echo -e "${YELLOW}    Please ensure 'backup' folder exists on your internal storage.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}[*] Restoring data from storage...${RESET}"
    echo -e "${CYAN}    This may take some time. Please wait.${RESET}"

    rm -rf "$TEMP_BACKUP_DIR"

    cp -r "$BACKUP_SOURCE" "$HOME_DIR/" || {
        echo -e "${RED}[!] Failed to copy backup files.${RESET}"
        exit 1
    }

    if [ -d "$TEMP_BACKUP_DIR/metasploit-framework" ]; then
        mv "$TEMP_BACKUP_DIR/metasploit-framework" "$HOME_DIR/"
        rm -rf "$TEMP_BACKUP_DIR" # Clean up temp folder
        echo -e "${GREEN}[✓] Restore successful!${RESET}"
        
        # Return to main menu
        if [ -d "$INSTALLER_DIR" ]; then
            cd "$INSTALLER_DIR"
            bash metasploit.sh
        fi
    else
        echo -e "${RED}[!] Restore failed: Invalid backup structure.${RESET}"
        echo -e "${YELLOW}    Ensure the backup folder contains 'metasploit-framework'.${RESET}"
        exit 1
    fi
}

start_restore
