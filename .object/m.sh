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
export GEM_HOME="$HOME/.gem"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
CYAN="\e[36m"
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
    echo -e "${YELLOW}  Website : h4ck3r.me${RESET}"
    echo -e "${BLUE} ####################################################${RESET}"
    echo -e "${CYAN}  Logs: ~/install.log${RESET}\n"
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
    run_task "Updating system packages" "pkg update -y && pkg upgrade -y"
    run_task "Installing dependencies" "
        pkg install -y git python autoconf bison clang coreutils curl findutils \
        apr apr-util postgresql openssl readline libffi libgmp libpcap \
        libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils \
        termux-tools termux-elf-cleaner pkg-config ruby libiconv binutils \
        zlib libyaml liblzma
    "
}

# 🔥 FIXED Nokogiri (no Gumbo compilation)
manual_nokogiri_fix() {
    cd $HOME

    NOKO_VERSION="1.18.10"

    run_task "Fixing Nokogiri (Gumbo removed)" "
        rm -rf ~/.gem/gems/nokogiri* &&
        rm -rf ~/.gem/extensions/* &&
        rm -rf ~/.bundle &&

        gem update --system &&
        gem install mini_portile2 -v 2.8.5 &&

        gem install nokogiri -v $NOKO_VERSION -- \
          --use-system-libraries \
          --disable-gumbo \
          --with-xml2-include=$PREFIX/include/libxml2 \
          --with-xml2-lib=$PREFIX/lib

        rm -rf ~/.gem/gems/nokogiri-$NOKO_VERSION/ext/nokogiri/gumbo*
    "
}

install_msf() {
    if [ ! -d "$MSF_DIR" ]; then
        run_task "Cloning Metasploit Framework" \
        "git clone --depth=1 $MSF_URL $MSF_DIR"
    fi

    cd "$MSF_DIR"

    run_task "Installing Bundler" "gem install bundler"

    manual_nokogiri_fix

    run_task "Configuring Bundle settings" "
        bundle config set --local force_ruby_platform true &&
        bundle config set build.nokogiri '--use-system-libraries --with-xml2-include=$PREFIX/include/libxml2 --with-xml2-lib=$PREFIX/lib' &&
        bundle config set build.pg --with-pg-config=$PREFIX/bin/pg_config
    "

    run_task "Installing Framework Gems (Wait...)" \
    "bundle install -j\$(nproc)"
}

setup_binaries() {
    run_task "Setting up PostgreSQL & shortcuts" "
        mkdir -p $PG_DATA &&
        [ ! -d $PG_DATA/base ] && initdb $PG_DATA;

        printf '#!/bin/bash\n
if [ -f \"$PG_DATA/postmaster.pid\" ]; then
 pg_ctl -D \"$PG_DATA\" status > /dev/null 2>&1 || rm \"$PG_DATA/postmaster.pid\"
fi
pg_ctl -D \"$PG_DATA\" -l \"$PG_DATA/logfile\" start > /dev/null 2>&1
cd \"$MSF_DIR\"
./msfconsole \"\$@\"
' > $PREFIX/bin/msfconsole &&

        printf '#!/bin/bash\n
cd \"$MSF_DIR\"
./msfvenom \"\$@\"
' > $PREFIX/bin/msfvenom &&

        chmod +x $PREFIX/bin/msfconsole $PREFIX/bin/msfvenom &&
        termux-elf-cleaner $PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so > /dev/null 2>&1
    "
}

cleanup() {
    run_task "Final Cleanup" "
        rm -rf ~/.gem/gems/nokogiri* &&
        rm -rf ~/.gem/extensions/* &&
        rm -rf ~/.bundle
    "
}

# ===== RUN =====
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
