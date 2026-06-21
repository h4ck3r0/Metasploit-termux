#!/bin/bash

INSTALL_DIR="$HOME/Metasploit-termux"
OBJECT_DIR="$INSTALL_DIR/.object"

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

banner() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${GREEN}      METASPLOIT TERMUX INSTALLER          ${CYAN}║${RESET}"
    echo -e "${CYAN}╠═══════════════════════════════════════════╣${RESET}"
    echo -e "${CYAN}║${YELLOW}  Author  : Raj Aryan (h4ck3r0)            ${CYAN}║${RESET}"
    echo -e "${CYAN}║${YELLOW}  GitHub  : github.com/h4ck3r0             ${CYAN}║${RESET}"
    echo -e "${CYAN}║${YELLOW}  YouTube : youtube.com/c/H4Ck3R0          ${CYAN}║${RESET}"
    echo -e "${CYAN}║${YELLOW}  Website : h4ck3r.me                      ${CYAN}║${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════╝${RESET}"
    echo ""
}

invalid_input() {
    echo -e "\n${RED}[!] Invalid Input! Please try again.${RESET}"
    sleep 1.5
    menu
}

# ── Installation sub-menu ──────────────────────
install_menu() {
    banner
    echo -e "${CYAN}  Choose Installation Method:${RESET}\n"
    echo -e "  ${RED}[${RESET}1${RED}]${GREEN} Legacy Install       ${YELLOW}(Android 4.4 – 6.0)${RESET}"
    echo -e "  ${RED}[${RESET}2${RED}]${GREEN} Modern Direct Install ${YELLOW}(Android 7.0+)${RESET}"
    echo -e "  ${RED}[${RESET}3${RED}]${GREEN} Proot-Distro / Debian ${YELLOW}(Android 7.0+) ${BLUE}[RECOMMENDED]${RESET}"
    echo -e "  ${RED}[${RESET}4${RED}]${GREEN} Back to Main Menu${RESET}"
    echo ""
    echo -ne "${CYAN}Choose Option : ${RESET}"

    read -r install_option
    case $install_option in
        1)
            echo -e "${GREEN}[*] Starting Legacy Installation (Android 4.4-6.0)...${RESET}"
            cd "$OBJECT_DIR" || { echo -e "${RED}[!] Object directory not found!${RESET}"; exit 1; }
            bash l.sh
            ;;
        2)
            echo -e "${GREEN}[*] Starting Modern Installation (Android 7.0+)...${RESET}"
            cd "$OBJECT_DIR" || { echo -e "${RED}[!] Object directory not found!${RESET}"; exit 1; }
            bash m.sh
            ;;
        3)
            echo -e "${GREEN}[*] Starting Proot-Distro Installation (Debian)...${RESET}"
            cd "$OBJECT_DIR" || { echo -e "${RED}[!] Object directory not found!${RESET}"; exit 1; }
            bash proot.sh
            ;;
        4)
            menu
            ;;
        *)
            echo -e "\n${RED}[!] Invalid Input! Please try again.${RESET}"
            sleep 1.5
            install_menu
            ;;
    esac
}

repair_tool() {
    echo -e "${GREEN}[*] Repairing Metasploit...${RESET}"
    cd "$OBJECT_DIR" || exit
    bash r.sh
}

backup_data() {
    echo -e "${GREEN}[*] Creating Backup...${RESET}"
    cd "$OBJECT_DIR" || exit
    bash b.sh
}

restore_data() {
    echo -e "${GREEN}[*] Restoring Data...${RESET}"
    cd "$OBJECT_DIR" || exit
    bash re.sh
}

update_tool() {
    banner
    echo -e "${BOLD}${CYAN}[UPDATE]${RESET} Checking for updates...\n"

    # ── 1. Update Termux installer scripts ──────────────────────────
    if [ -d "$INSTALL_DIR/.git" ]; then
        # It's a git repo — try fast pull first
        local OLD_COMMIT
        OLD_COMMIT=$(git -C "$INSTALL_DIR" rev-parse --short HEAD 2>/dev/null)

        echo -ne "${YELLOW}[...]${RESET} Pulling latest installer from GitHub"
        git -C "$INSTALL_DIR" pull --ff-only origin main > /dev/null 2>&1
        local PULL_STATUS=$?

        local NEW_COMMIT
        NEW_COMMIT=$(git -C "$INSTALL_DIR" rev-parse --short HEAD 2>/dev/null)

        if [ $PULL_STATUS -eq 0 ]; then
            if [ "$OLD_COMMIT" = "$NEW_COMMIT" ]; then
                echo -e "\r${GREEN}[DONE]${RESET} Installer already up to date (${CYAN}${OLD_COMMIT}${RESET})"
            else
                echo -e "\r${GREEN}[DONE]${RESET} Installer updated: ${YELLOW}${OLD_COMMIT}${RESET} → ${GREEN}${NEW_COMMIT}${RESET}"
            fi
        else
            # Pull failed (diverged or conflict) — re-clone as fallback
            echo -e "\r${YELLOW}[WARN]${RESET} Git pull failed — re-cloning installer (your MSF is NOT affected)"
            rm -rf "$INSTALL_DIR"
            git clone --depth=1 https://github.com/h4ck3r0/Metasploit-termux "$INSTALL_DIR" \
                && echo -e "${GREEN}[DONE]${RESET} Installer re-cloned successfully" \
                || { echo -e "${RED}[FAIL]${RESET} Clone failed. Check internet connection."; exit 1; }
        fi
    else
        # Not a git repo — do a clean clone
        echo -e "${YELLOW}[!] No git history found — doing fresh clone${RESET}"
        rm -rf "$INSTALL_DIR"
        git clone --depth=1 https://github.com/h4ck3r0/Metasploit-termux "$INSTALL_DIR" \
            && echo -e "${GREEN}[DONE]${RESET} Installer cloned successfully" \
            || { echo -e "${RED}[FAIL]${RESET} Clone failed. Check internet connection."; exit 1; }
    fi

    # ── 2. Update Termux packages ────────────────────────────────────
    echo -ne "${YELLOW}[...]${RESET} Updating Termux packages"
    pkg update -y > /dev/null 2>&1 && pkg upgrade -y > /dev/null 2>&1
    echo -e "\r${GREEN}[DONE]${RESET} Termux packages updated"

    # ── 3. Update proot-distro (if installed) ───────────────────────
    if command -v proot-distro > /dev/null 2>&1; then
        echo -ne "${YELLOW}[...]${RESET} Updating proot-distro"
        pkg install -y proot-distro > /dev/null 2>&1
        echo -e "\r${GREEN}[DONE]${RESET} proot-distro updated"
    fi

    # ── 4. Offer MSF update inside Debian (proot method) ────────────
    local ROOTFS_NEW="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
    local ROOTFS_OLD="$HOME/proot-distro/installed-rootfs/debian"
    if [ -f "$ROOTFS_NEW/etc/debian_version" ] || [ -f "$ROOTFS_OLD/etc/debian_version" ] || \
       proot-distro login debian -- true 2>/dev/null; then
        echo ""
        echo -ne "${CYAN}[?]${RESET} Update Metasploit inside Debian proot? (y/N): "
        read -r msf_update
        if [[ "$msf_update" =~ ^[yY]$ ]]; then
            echo -e "${GREEN}[*] Updating Metasploit Framework inside Debian...${RESET}"
            proot-distro login debian -- bash -c "apt-get update -y && apt-get upgrade -y metasploit-framework" \
                && echo -e "${GREEN}[DONE]${RESET} Metasploit updated inside Debian" \
                || echo -e "${YELLOW}[SKIP]${RESET} MSF update had issues — try: msf-shell → apt upgrade"
        fi
    fi

    echo -e "\n${GREEN}✔ Update complete!${RESET}\n"
    sleep 1
    cd "$INSTALL_DIR" && bash metasploit.sh
}

menu() {
    banner
    echo -e "  ${RED}[${RESET}1${RED}]${GREEN} Install Metasploit${RESET}"
    echo -e "  ${RED}[${RESET}2${RED}]${GREEN} Repair${RESET}"
    echo -e "  ${RED}[${RESET}3${RED}]${GREEN} Backup${RESET}"
    echo -e "  ${RED}[${RESET}4${RED}]${GREEN} Restore${RESET}"
    echo -e "  ${RED}[${RESET}5${RED}]${GREEN} Update Installer${RESET}"
    echo -e "  ${RED}[${RESET}6${RED}]${GREEN} Exit${RESET}"
    echo ""
    echo -ne "${CYAN}Choose Option : ${RESET}"

    read -r option
    case $option in
        1) install_menu ;;
        2) repair_tool ;;
        3) backup_data ;;
        4) restore_data ;;
        5) update_tool ;;
        6) echo -e "${GREEN}Exiting...${RESET}"; exit 0 ;;
        *) invalid_input ;;
    esac
}

# Start the script
menu
