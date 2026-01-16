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
PG_DATA="$PREFIX/var/lib/postgresql"

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
    msg "Syncing repositories and installing core dependencies..."
    pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confnew"
    pkg install -y git python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils termux-tools termux-elf-cleaner pkg-config ruby libiconv binutils zlib libyaml || error "Dependency installation failed."
}

manual_nokogiri_fix() {
    msg "Applying manual Nokogiri-Gumbo header injection..."
    cd $HOME
    NOKO_VERSION=$(grep -E "^\s+nokogiri \(" "$MSF_DIR/Gemfile.lock" | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    [ -z "$NOKO_VERSION" ] && NOKO_VERSION="1.18.10"

    rm -rf "nokogiri-$NOKO_VERSION" "nokogiri-$NOKO_VERSION.gem"
    rm -f "$PREFIX/include/nokogiri_gumbo.h"

    gem fetch nokogiri -v "$NOKO_VERSION"
    gem unpack nokogiri-"$NOKO_VERSION".gem
    cd nokogiri-"$NOKO_VERSION"/ext/nokogiri || error "Nokogiri directory not found."

    ruby extconf.rb --use-system-libraries
    find . -name "nokogiri_gumbo.h" -exec cp {} $PREFIX/include/ \;
    
    msg "Compiling Nokogiri extension (this may take a moment)..."
    make -j$(nproc)
    make install
    success "Nokogiri manually compiled and installed."
}

install_msf() {
    if [ ! -d "$MSF_DIR" ]; then
        msg "Cloning Metasploit Framework repository..."
        git clone --depth=1 "$MSF_URL" "$MSF_DIR"
    fi
    cd "$MSF_DIR"
    gem install bundler
    
    manual_nokogiri_fix
    
    cd "$MSF_DIR"
    bundle config set --local force_ruby_platform true
    bundle config build.nokogiri --use-system-libraries
    bundle config build.pg --with-pg-config=$PREFIX/bin/pg_config
    
    msg "Installing remaining gems via Bundler..."
    bundle install -j$(nproc) || error "Bundle install failed."
}

setup_binaries() {
    msg "Creating command wrappers and fixing database logic..."
    mkdir -p "$PG_DATA"
    [ ! -d "$PG_DATA/base" ] && initdb "$PG_DATA"

    cat << EOF > "$PREFIX/bin/msfconsole"
#!/bin/bash
# Check for stale pid files that cause pg_ctl to fail
if [ -f "$PG_DATA/postmaster.pid" ]; then
    if ! pgrep -x "postgres" > /dev/null; then
        rm "$PG_DATA/postmaster.pid"
    fi
fi

# Start database if not running
if ! pgrep -x "postgres" > /dev/null; then
    pg_ctl -D "$PG_DATA" -l "$PG_DATA/logfile" start > /dev/null 2>&1
fi

cd "$MSF_DIR"
./msfconsole "\$@"
EOF

    cat << EOF > "$PREFIX/bin/msfvenom"
#!/bin/bash
cd "$MSF_DIR"
./msfvenom "\$@"
EOF

    chmod +x "$PREFIX/bin/msfconsole" "$PREFIX/bin/msfvenom"
    termux-elf-cleaner "$PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so" > /dev/null 2>&1
}

cleanup() {
    msg "Cleaning up temporary compilation files..."
    cd $HOME
    rm -rf nokogiri-"$NOKO_VERSION"
    rm -f nokogiri-"$NOKO_VERSION".gem
    rm -f "$PREFIX/include/nokogiri_gumbo.h"
}

# --- Main Execution ---
banner
install_deps
install_msf
setup_binaries
cleanup

success "Installation complete by Raj Aryan (h4ck3r0)."
termux-open-url "$BLOG_URL"
echo -e "\n${YELLOW}To start Metasploit, type: ${GREEN}msfconsole${RESET}\n"
