#!/data/data/com.termux/files/usr/bin/bash

################################################################
# Script Name : Metasploit-Termux Advanced Installer
# Description : Automated MSF installation with Ruby 3.4 Gumbo fix
# Author      : Raj Aryan (h4ck3r0)
# GitHub      : https://github.com/h4ck3r0/Metasploit-termux
# YouTube     : Youtube.com/c/H4Ck3R0
# Website     : https://h4ck3r.me
################################################################

MSF_DIR="$HOME/metasploit-framework"
MSF_URL="https://github.com/rapid7/metasploit-framework.git"
BLOG_URL="https://h4ck3r.me/how-to-install-metasploit-in-termux/"
PREFIX="/data/data/com.termux/files/usr"

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
    echo -e "${BLUE} ####################################################${RESET}"
    echo ""
}

msg() { echo -e "${BLUE}[*] ${RESET}$1"; }
success() { echo -e "${GREEN}[+] $1${RESET}"; }
error() { echo -e "${RED}[!] $1${RESET}"; exit 1; }

install_deps() {
    msg "Installing dependencies and build-essential tools..."
    pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confnew"
    pkg install -y git python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils termux-tools termux-elf-cleaner pkg-config ruby libiconv binutils zlib libyaml || error "Failed to install packages."
}

patch_nokogiri() {
    msg "Fixing Nokogiri 1.18.10 'nokogiri_gumbo.h' error..."
    cd $HOME
    NOKO_VERSION=$(grep -A 1 "nokogiri (" "$MSF_DIR/Gemfile.lock" | tail -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    
    gem fetch nokogiri -v "$NOKO_VERSION"
    gem unpack nokogiri-"$NOKO_VERSION".gem
    
    cd nokogiri-"$NOKO_VERSION"/ext/nokogiri
    ruby extconf.rb --use-system-libraries
    find . -name "nokogiri_gumbo.h" -exec cp {} $PREFIX/include/ \;
    find . -name "nokogiri_gumbo.c" -exec cp {} $PREFIX/include/ \;
    
    msg "Compiling native extensions..."
    make -j$(nproc) && make install
    success "Nokogiri extension patched and installed."
}

install_msf() {
    if [ ! -d "$MSF_DIR" ]; then
        msg "Cloning Metasploit Framework..."
        git clone --depth=1 "$MSF_URL" "$MSF_DIR"
    fi
    cd "$MSF_DIR"
    
    gem install bundler
    bundle config set --local force_ruby_platform true
    bundle config build.nokogiri --use-system-libraries
    bundle config build.pg --with-pg-config=$PREFIX/bin/pg_config
    
    msg "Running bundle install (Remaining Gems)..."
    bundle install -j$(nproc) || error "Bundle install failed."
}

setup_binaries() {
    msg "Setting up database and shortcuts..."
    mkdir -p "$PREFIX/var/lib/postgresql"
    [ ! -d "$PREFIX/var/lib/postgresql/base" ] && initdb "$PREFIX/var/lib/postgresql"
    pg_ctl -D "$PREFIX/var/lib/postgresql" -l "$PREFIX/var/lib/postgresql/logfile" start 2>/dev/null

    for tool in msfconsole msfvenom; do
        cat << EOF > "$PREFIX/bin/$tool"
#!/bin/bash
if ! pgrep -x "postgres" > /dev/null; then
    pg_ctl -D "$PREFIX/var/lib/postgresql" -l "$PREFIX/var/lib/postgresql/logfile" start
fi
cd "$MSF_DIR"
./$tool "\$@"
EOF
        chmod +x "$PREFIX/bin/$tool"
    done
    
    termux-elf-cleaner "$PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so" > /dev/null 2>&1
}

cleanup() {
    msg "Cleaning up temporary build source..."
    cd $HOME
    rm -rf nokogiri-"$NOKO_VERSION"
    rm -f nokogiri-"$NOKO_VERSION".gem
    rm -f $PREFIX/include/nokogiri_gumbo.h
    rm -f $PREFIX/include/nokogiri_gumbo.c
}

banner
install_deps
install_msf
patch_nokogiri
setup_binaries
cleanup

success "Installation complete by Raj Aryan (h4ck3r0)."
termux-open-url "$BLOG_URL"
echo -e "\n${YELLOW}Type ${GREEN}msfconsole${YELLOW} to launch the framework.${RESET}\n"
