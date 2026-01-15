#!/bin/bash

INSTALL_DIR="$HOME/Metasploit-termux"
OBJECT_DIR="$INSTALL_DIR/.object"

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

pkg install python python2 -y > /dev/null 2>&1

banner() {
    clear
    echo -e "${CYAN}---------------------------------------------${RESET}"
    echo -e "${GREEN}       METASPLOIT TERMUX INSTALLER          ${RESET}"
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


install_metasploit() {
    echo -e "${GREEN}[*] Starting Installation...${RESET}"
    cd "$OBJECT_DIR" || { echo -e "${RED}[!] Directory not found!${RESET}"; exit 1; }
    bash ml.sh
}

repair_tool() {
    echo -e "${GREEN}[*] Repairing Metasploit...${RESET}"
    cd "$OBJECT_DIR" || exit
    bash r.sh
    cd "$INSTALL_DIR" || exit
    bash metasploit.sh
}

backup_data() {
    echo -e "${GREEN}[*] Creating Backup...${RESET}"
    cd "$OBJECT_DIR" || exit
    bash b.sh
    cd "$INSTALL_DIR" || exit
    bash metasploit.sh
}

restore_data() {
    echo -e "${GREEN}[*] Restoring Data...${RESET}"
    cd "$OBJECT_DIR" || exit
    bash re.sh
    cd "$INSTALL_DIR" || exit
    bash metasploit.sh
  
    if [ -d "$HOME/kali-theme" ]; then
        cd "$HOME/kali-theme" && bash metasploit.sh
    fi
}

update_tool() {
    echo -e "${GREEN}[*] Updating Tool...${RESET}"
    rm -rf "$INSTALL_DIR"
    cd "$HOME" || exit
    git clone https://github.com/h4ck3r0/Metasploit-termux
    cd "$INSTALL_DIR" || exit
    bash metasploit.sh
}


menu() {
    banner
    echo -e "${RED}[${RESET}1${RED}]${GREEN} Metasploit Installation${RESET}"
    echo -e "${RED}[${RESET}2${RED}]${GREEN} Repair${RESET}"
    echo -e "${RED}[${RESET}3${RED}]${GREEN} Backup${RESET}"
    echo -e "${RED}[${RESET}4${RED}]${GREEN} Restore${RESET}"
    echo -e "${RED}[${RESET}5${RED}]${GREEN} Update${RESET}"
    echo -e "${RED}[${RESET}6${RED}]${GREEN} Exit${RESET}"
    echo ""
    echo -ne "${CYAN}Choose Option : ${RESET}"
    
    read -r option
    case $option in
        1) install_metasploit ;;
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
