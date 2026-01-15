#!/bin/bash

INSTALL_DIR="$HOME/Metasploit-termux"
OBJECT_DIR="$INSTALL_DIR/.object"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'


banner() {
    clear
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo -e "${GREEN}       METASPLOIT VERSION SELECTOR          ${RESET}"
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo -e "${YELLOW}   Author  : Raj Aryan (H4ck3r)            ${RESET}"
    echo -e "${YELLOW}   YouTube : Youtube.com/c/H4Ck3R0         ${RESET}"
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo ""
}

invalid_input() {
    echo -e "\n${RED}[!] Invalid Input! Please try again.${RESET}"
    sleep 1.5
    menu
}


install_legacy() {
    # For Android 4.4 - 6.0
    echo -e "${GREEN}[*] Initializing Legacy Installation (Android 4.4 - 6.0)...${RESET}"
    cd "$OBJECT_DIR" || { echo -e "${RED}[!] Directory not found!${RESET}"; exit 1; }
    bash l.sh
}

install_modern() {
    # For Android 7.0+
    echo -e "${GREEN}[*] Initializing Modern Installation (Android 7.0+)...${RESET}"
    cd "$OBJECT_DIR" || { echo -e "${RED}[!] Directory not found!${RESET}"; exit 1; }
    bash m.sh
}



menu() {
    banner
    echo -e "${RED}[${RESET}1${RED}]${GREEN} Metasploit for Android 4.4 - 6.0${RESET}"
    echo -e "${RED}[${RESET}2${RED}]${GREEN} Metasploit for Android 7.0 +${RESET}"
    echo -e "${RED}[${RESET}3${RED}]${GREEN} Exit${RESET}"
    echo ""
    echo -ne "${CYAN}Choose Option : ${RESET}"
    
    read -r option
    case $option in
        1) install_legacy ;;
        2) install_modern ;;
        3) echo -e "${GREEN}Exiting...${RESET}"; exit 0 ;;
        *) invalid_input ;;
    esac
}

# Start the script
menu
