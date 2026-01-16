#!/data/data/com.termux/files/usr/bin/bash

MSF_DIR="$HOME/metasploit-framework"
MSF_URL="https://github.com/rapid7/metasploit-framework.git"

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RESET="\e[0m"

banner() {
    clear
    echo -e "${RED} ███████ ▓█████▄▄▄█████▓ █    ██  ██▓███  " 
    echo -e "${RED}▒██   ▒ ▓█   ▀▓  ██▒ ▓▒ ██  ▓██▒▓██░  ██▒" 
    echo -e "${RED}░ ▓██▄   ▒███  ▒ ▓██░ ▒░▓██  ▒██░▓██░ ██▓▒" 
    echo -e "${RED}  ▒   ██▒▒▓█  ▄░ ▓██▓ ░ ▓▓█  ░██░▒██▄█▓▒ ▒" 
    echo -e "${RED}▒██████▒▒░▒████▒ ▒██▒ ░ ▒▒█████▓ ▒██▒ ░  ░" 
    echo -e "${RED}▒ ▒▓▒ ▒ ░░░ ▒░ ░ ▒ ░░   ░▒▓▒ ▒ ▒ ▒▓▒░ ░  ░" 
    echo -e "${RED}░ ░▒  ░ ░ ░ ░  ░    ░     ░░▒░ ░ ░ ░▒ ░     " 
    echo -e "${RESET}"
    echo -e "${BLUE}   >> Metasploit Auto-Fix Installer <<    ${RESET}"
    echo -e "${BLUE}   ===================================    ${RESET}"
    echo ""
}

msg() { echo -e "${BLUE}[*] ${RESET}$1"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
error() { echo -e "${RED}[!] $1${RESET}"; exit 1; }

check_internet() {
    msg "Checking internet connection..."
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        success "Online"
    else
        error "No internet. Please connect and try again."
    fi
}

banner
check_internet

msg "Installing build tools & libraries..."
pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confnew"

PACKAGES="git python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils termux-tools termux-elf-cleaner pkg-config ruby libiconv binutils zlib libyaml"

pkg install -y $PACKAGES -o Dpkg::Options::="--force-confnew" || error "Failed to install dependencies"
success "Dependencies installed"

if [ -d "$MSF_DIR" ]; then
    rm -rf "$MSF_DIR"
fi

msg "Downloading Metasploit Framework..."
git clone --depth=1 "$MSF_URL" "$MSF_DIR" || error "Download failed"
success "Download complete"

cd "$MSF_DIR" || error "Could not enter directory"

export PREFIX="/data/data/com.termux/files/usr"
export CC="clang"
export CXX="clang++"
export CFLAGS="-I$PREFIX/include -I$PREFIX/include/libxml2"
export CXXFLAGS="-I$PREFIX/include -I$PREFIX/include/libxml2"
export LDFLAGS="-L$PREFIX/lib"
export MAKE="make"

gem install bundler

bundle config build.nokogiri --use-system-libraries \
  --with-xml2-include=$PREFIX/include/libxml2 \
  --with-xslt-include=$PREFIX/include/libxslt \
  --with-xml2-lib=$PREFIX/lib \
  --with-xslt-lib=$PREFIX/lib

bundle config build.pg --with-pg-config=$PREFIX/bin/pg_config
bundle config build.grpc --with-ldflags="-L$PREFIX/lib" --with-cflags="-I$PREFIX/include"

msg "Running 'bundle install'..."
bundle config set --local force_ruby_platform true
bundle install -j$(nproc) || error "Bundle install failed."
success "Gems installed successfully"

termux-fix-shebang "$MSF_DIR/msfconsole"
termux-fix-shebang "$MSF_DIR/msfvenom"
chmod +x "$MSF_DIR/msfconsole"
chmod +x "$MSF_DIR/msfvenom"

mkdir -p "$PREFIX/var/lib/postgresql"

if ! pg_ctl -D "$PREFIX/var/lib/postgresql" status > /dev/null 2>&1; then
    if [ ! -d "$PREFIX/var/lib/postgresql/base" ]; then
        initdb "$PREFIX/var/lib/postgresql" > /dev/null 2>&1
    fi
    pg_ctl -D "$PREFIX/var/lib/postgresql" -l "$PREFIX/var/lib/postgresql/logfile" start > /dev/null 2>&1
fi

if ! createuser -l msf > /dev/null 2>&1; then
    createdb msf_database -O msf > /dev/null 2>&1
fi

cat << EOF > "$PREFIX/bin/msfconsole"
#!/bin/bash
if ! pgrep -x "postgres" > /dev/null; then
    pg_ctl -D "\$PREFIX/var/lib/postgresql" -l "\$PREFIX/var/lib/postgresql/logfile" start
fi
cd "$MSF_DIR"
./msfconsole "\$@"
EOF

cat << EOF > "$PREFIX/bin/msfvenom"
#!/bin/bash
cd "$MSF_DIR"
./msfvenom "\$@"
EOF

chmod +x "$PREFIX/bin/msfconsole"
chmod +x "$PREFIX/bin/msfvenom"

termux-elf-cleaner "$PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so" > /dev/null 2>&1

banner
echo -e "${GREEN}Installation & Fixes Complete!${RESET}"
echo -e "${YELLOW}Usage:${RESET}"
echo -e "  Type ${GREEN}msfconsole${RESET} to start."
echo -e "  Type ${GREEN}msfvenom${RESET} to create payloads."
echo ""

