#!/data/data/com.termux/files/usr/bin/bash

################################################################
# Script Name : Metasploit-Termux Repair Script
# Author      : Raj Aryan (h4ck3r0)
# GitHub      : https://github.com/h4ck3r0/Metasploit-termux
# YouTube     : Youtube.com/c/H4Ck3R0
# Website     : https://h4ck3r.me
################################################################

MSF_DIR="$HOME/metasploit-framework"
PREFIX="/data/data/com.termux/files/usr"
PG_DATA="$PREFIX/var/lib/postgresql"
LOG_FILE="$HOME/repair.log"

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
    echo -e "${RED}"
    echo -e " ██▀███  ▓█████  ██▓███   ▄▄▄       ██▓ ██▀███  "
    echo -e "▓██ ▒ ██▒▓█   ▀ ▓██░  ██▒▒████▄    ▓██▒▓██ ▒ ██▒"
    echo -e "▓██ ░▄█ ▒▒███   ▓██░ ██▓▒▒██  ▀█▄  ▒██▒▓██ ░▄█ ▒"
    echo -e "▒██▀▀█▄  ▒▓█  ▄ ▒██▄█▓▒ ▒░██▄▄▄▄██ ░██░▒██▀▀█▄  "
    echo -e "░██▓ ▒██▒░▒████▒▒██▒ ░  ░ ▓█   ▓██▒░██░░██▓ ▒██▒"
    echo -e "░ ▒▓ ░▒▓░░░ ▒░ ░▒▓▒░ ░  ░ ▒▒   ▓▒█░░▓  ░ ▒▓ ░▒▓░"
    echo -e "  ░▒ ░ ▒░ ░ ░  ░░▒ ░       ▒   ▒▒ ░ ▒ ░  ░▒ ░ ▒░"
    echo -e "  ░░   ░    ░   ░░         ░   ▒    ▒ ░  ░░   ░ "
    echo -e "   ░        ░  ░               ░  ░ ░     ░   "
    echo -e "${BLUE} ####################################################${RESET}"
    echo -e "${YELLOW}  Author  : Raj Aryan (h4ck3r0)${RESET}"
    echo -e "${YELLOW}  GitHub  : github.com/h4ck3r0/Metasploit-termux${RESET}"
    echo -e "${YELLOW}  YouTube : Youtube.com/c/H4Ck3R0${RESET}"
    echo -e "${YELLOW}  Website : h4ck3r.me${RESET}"
    echo -e "${BLUE} ####################################################${RESET}"
    echo -e "${CYAN}  Repair Logs: ~/repair.log${RESET}\n"
}

run_task() {
    local task_msg=$1
    local cmd=$2
    echo -ne "${YELLOW}[...]${RESET} $task_msg"
    eval "$cmd" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\r${GREEN}[DONE]${RESET} $task_msg"
    else
        echo -e "\r${RED}[FAIL]${RESET} $task_msg (Check repair.log)"
    fi
}

repair_deps() {
    run_task "Updating system packages" "pkg update -y && pkg upgrade -y"
    run_task "Reinstalling core dependencies" "
        pkg install -y git autoconf bison clang coreutils curl findutils \
        apr apr-util postgresql openssl readline libffi libgmp libpcap \
        libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils \
        termux-tools termux-elf-cleaner pkg-config ruby libiconv binutils \
        zlib libyaml liblzma
    "
}

fix_nokogiri() {
    NOKO_VERSION="1.18.10"

    run_task "Clearing broken gem cache" "
        rm -rf ~/.gem/gems/nokogiri* &&
        rm -rf ~/.gem/extensions/* &&
        rm -rf ~/.bundle
    "

    run_task "Updating RubyGems system" "gem update --system"

    run_task "Installing mini_portile2" "gem install mini_portile2 -v 2.8.5"

    run_task "Installing Nokogiri (Gumbo disabled)" "
        gem install nokogiri -v $NOKO_VERSION -- \
          --use-system-libraries \
          --disable-gumbo \
          --with-xml2-include=$PREFIX/include/libxml2 \
          --with-xml2-lib=$PREFIX/lib &&
        rm -rf ~/.gem/gems/nokogiri-$NOKO_VERSION/ext/nokogiri/gumbo*
    "
}

fix_bundle() {
    if [ ! -d "$MSF_DIR" ]; then
        echo -e "${RED}[!] Metasploit not found at $MSF_DIR. Run a fresh install instead.${RESET}"
        exit 1
    fi

    cd "$MSF_DIR" || exit 1

    run_task "Installing Bundler" "gem install bundler"

    run_task "Configuring Bundle settings" "
        bundle config set --local force_ruby_platform true &&
        bundle config set build.nokogiri '--use-system-libraries --with-xml2-include=$PREFIX/include/libxml2 --with-xml2-lib=$PREFIX/lib' &&
        bundle config set build.pg --with-pg-config=$PREFIX/bin/pg_config
    "

    run_task "Reinstalling Framework Gems (Wait...)" \
    "bundle install -j$(nproc)"
}

fix_postgresql() {
    # Kill stale PID if present
    if [ -f "$PG_DATA/postmaster.pid" ]; then
        run_task "Cleaning stale PostgreSQL PID" "rm -f $PG_DATA/postmaster.pid"
    fi

    run_task "Initializing PostgreSQL (if needed)" "
        mkdir -p $PG_DATA &&
        [ ! -d $PG_DATA/base ] && initdb $PG_DATA || true
    "

    run_task "Starting PostgreSQL" "
        pg_ctl -D $PG_DATA -l $PG_DATA/logfile start
    "
}

fix_elf() {
    run_task "Running ELF cleaner on pg gem" "
        termux-elf-cleaner $PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
    " 2>/dev/null || true
}

# ===== RUN =====
banner
> "$LOG_FILE"

repair_deps
fix_nokogiri
fix_bundle
fix_postgresql
fix_elf

echo -e "\n${GREEN}✔ Repair complete! Try running: msfconsole${RESET}\n"
