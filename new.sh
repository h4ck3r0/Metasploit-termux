#!/data/data/com.termux/files/usr/bin/bash

################################################################
# Script Name : Metasploit-Termux Advanced Installer
# Author      : Raj Aryan (h4ck3r0)
# GitHub      : https://github.com/h4ck3r0/Metasploit-termux
# YouTube     : Youtube.com/c/H4Ck3R0
# Website     : https://h4ck3r.me
################################################################

MSF_DIR="$HOME/metasploit-framework"
MSF_URL="https://github.com/rapid7/metasploit-framework.git"
BLOG_URL="https://h4ck3r.me/how-to-install-metasploit-in-termux/"
YT_URL="https://www.youtube.com/c/H4Ck3R0"
PREFIX="/data/data/com.termux/files/usr"
PG_DATA="$PREFIX/var/lib/postgresql"
LOG_FILE="$HOME/install.log"

export CPATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RESET="\e[0m"

banner() {
    clear
    echo -e "${RED} ███████ ▓█████▄▄▄█████▓ █    ██  ██▓███  " 
    echo -e " ██      ▓█   ▀▓  ██▒ ▓▒ ██  ▓██▒▓██░  ██▒" 
    echo -e " ░ ▓██▄   ▒███  ▒ ▓██░ ▒░▓██  ▒██░▓██░ ██▓▒" 
    echo -e "   ▒   ██▒▒▓█  ▄░ ▓██▓ ░ ▓▓█  ░██░▒██▄█▓▒ ▒" 
    echo -e " ▒██████▒▒░▒████▒ ▒██▒ ░ ▒▒█████▓ ▒██▒ ░  ░" 
    echo -e " ▒ ▒▓▒ ▒ ░░░ ▒░ ░ ▒ ░░   ░▒▓▒ ▒ ▒ ▒▓▒░ ░  ░" 
    echo -e " ░ ░▒  ░ ░ ░ ░  ░    ░     ░░▒░ ░ ░ ░▒ ░     " 
    echo -e "${BLUE} ####################################################${RESET}"
    echo -e "${YELLOW}  Author  : Raj Aryan (h4ck3r0)${RESET}"
    echo -e "${YELLOW}  GitHub  : github.com/h4ck3r0/Metasploit-termux${RESET}"
    echo -e "${YELLOW}  YouTube : Youtube.com/c/H4Ck3R0${RESET}"
    echo -e "${YELLOW}  Website : h4ck3r.me${RESET}
    echo -e "${BLUE} ####################################################${RESET}"
    echo -e "${CYAN}  Note: Installation logs are saved in ~/install.log${RESET}"
    echo ""
}

run_task() {
    local task_msg=$1
    local cmd=$2
    echo -ne "${YELLOW}[...]${RESET} $task_msg"
    eval "$cmd" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\r${GREEN}[DONE]${RESET} $task_msg"
    else
        echo -e "\r${RED}[FAIL]${RESET} $task_msg (Check install.log)"
        exit 1
    fi
}

install_deps() {
    run_task "Updating system packages" "pkg update -y && pkg upgrade -y -o Dpkg::Options::='--force-confnew'"
    run_task "Installing core dependencies" "pkg install -y git python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils termux-tools termux-elf-cleaner pkg-config ruby libiconv binutils zlib libyaml"
}

manual_nokogiri_fix() {
    cd $HOME
    NOKO_VERSION=$(grep -E "^\s+nokogiri \(" "$MSF_DIR/Gemfile.lock" | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    [ -z "$NOKO_VERSION" ] || [[ "$NOKO_VERSION" == "1.8.5" ]] && NOKO_VERSION="1.18.10"

    run_task "Patching Nokogiri Gumbo (v$NOKO_VERSION)" "
        rm -rf nokogiri-$NOKO_VERSION nokogiri-$NOKO_VERSION.gem &&
        gem fetch nokogiri -v $NOKO_VERSION &&
        gem unpack nokogiri-$NOKO_VERSION.gem &&
        cd nokogiri-$NOKO_VERSION/ext/nokogiri &&
        ruby extconf.rb --use-system-libraries &&
        find . -name 'nokogiri_gumbo.h' -exec cp {} $PREFIX/include/ \; &&
        make -j\$(nproc) && make install
    "
}

install_msf() {
    if [ ! -d "$MSF_DIR" ]; then
        run_task "Cloning Metasploit Framework" "git clone --depth=1 $MSF_URL $MSF_DIR"
    fi
    cd "$MSF_DIR"
    run_task "Installing Bundler" "gem install bundler"
    
    manual_nokogiri_fix
    
    cd "$MSF_DIR"
    run_task "Configuring Bundle settings" "
        bundle config set --local force_ruby_platform true &&
        bundle config build.nokogiri --use-system-libraries &&
        bundle config build.pg --with-pg-config=$PREFIX/bin/pg_config
    "
    run_task "Installing Framework Gems (Wait...)" "bundle install -j\$(nproc)"
}

setup_binaries() {
    run_task "Initializing Database and Shortcuts" "
        mkdir -p $PG_DATA &&
        [ ! -d $PG_DATA/base ] && initdb $PG_DATA;
        
        printf '#!/bin/bash\nif [ -f \"$PG_DATA/postmaster.pid\" ]; then\n pg_ctl -D \"$PG_DATA\" status > /dev/null 2>&1 || rm \"$PG_DATA/postmaster.pid\"\nfi\npg_ctl -D \"$PG_DATA\" -l \"$PG_DATA/logfile\" start > /dev/null 2>&1\ncd \"$MSF_DIR\"\n./msfconsole \"\$@\"' > $PREFIX/bin/msfconsole &&
        
        printf '#!/bin/bash\ncd \"$MSF_DIR\"\n./msfvenom \"\$@\"' > $PREFIX/bin/msfvenom &&
        
        chmod +x $PREFIX/bin/msfconsole $PREFIX/bin/msfvenom &&
        termux-elf-cleaner $PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so > /dev/null 2>&1
    "
}

cleanup() {
    run_task "Performing Final Cleanup" "cd $HOME && rm -rf nokogiri-$NOKO_VERSION nokogiri-$NOKO_VERSION.gem $PREFIX/include/nokogiri_gumbo.h"
}


banner
> "$LOG_FILE" 
install_deps
install_msf
setup_binaries
cleanup

echo -e "\n${GREEN}✔ Installation accomplished by Raj Aryan (h4ck3r0).${RESET}"
termux-open-url "$YT_URL"
termux-open-url "$BLOG_URL"
echo -e "${YELLOW}Usage: ${GREEN}msfconsole${RESET}\n"
