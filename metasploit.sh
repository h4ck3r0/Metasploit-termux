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
    echo -e "${GREEN}[*] Updating Tool...${RESET}"
    echo -e "${YELLOW}[!] This will re-clone the installer. Your MSF installation is NOT affected.${RESET}"
    sleep 2
    rm -rf "$INSTALL_DIR"
    cd "$HOME" || exit
    git clone https://github.com/h4ck3r0/Metasploit-termux
    cd "$INSTALL_DIR" || exit
    bash metasploit.sh
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
