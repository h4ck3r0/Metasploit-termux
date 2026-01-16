#!/data/data/com.termux/files/usr/bin/bash

MSF_DIR="$HOME/metasploit-framework"
MSF_URL="https://github.com/rapid7/metasploit-framework.git"
PREFIX="/data/data/com.termux/files/usr"

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
    echo -e "${RED}░ ░▒  ░ ░ ░ ░  ░    ░     ░░▒░ ░ ░ ░▒ ░     ${RESET}"
    echo -e "${BLUE}   >> Metasploit Final Fix (Ruby 3.4) <<    ${RESET}"
}

banner
pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confnew"
pkg install -y git python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils termux-tools termux-elf-cleaner pkg-config ruby libiconv binutils zlib libyaml

if [ ! -d "$MSF_DIR" ]; then
    git clone --depth=1 "$MSF_URL" "$MSF_DIR"
fi

export CC="clang"
export CXX="clang++"
export CFLAGS="-I$PREFIX/include -I$PREFIX/include/libxml2"
export LDFLAGS="-L$PREFIX/lib"
gem install bundler

cd $HOME
NOKO_VERSION=$(grep -A 1 "nokogiri (" "$MSF_DIR/Gemfile.lock" | tail -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
gem fetch nokogiri -v "$NOKO_VERSION"
gem unpack nokogiri-"$NOKO_VERSION".gem
cd nokogiri-"$NOKO_VERSION"/ext/nokogiri

curl -Lo "$PREFIX/include/nokogiri_gumbo.h" https://raw.githubusercontent.com/sparklemotion/nokogiri/main/ext/nokogiri/nokogiri_gumbo.h

ruby extconf.rb --use-system-libraries --with-cflags="-Wno-implicit-function-declaration -I$PREFIX/include"
make -j$(nproc)
make install

cd "$MSF_DIR"
bundle config set --local force_ruby_platform true
bundle config build.nokogiri --use-system-libraries
bundle config build.pg --with-pg-config=$PREFIX/bin/pg_config
bundle install -j$(nproc)

mkdir -p "$PREFIX/var/lib/postgresql"
if [ ! -d "$PREFIX/var/lib/postgresql/base" ]; then
    initdb "$PREFIX/var/lib/postgresql"
fi
pg_ctl -D "$PREFIX/var/lib/postgresql" -l "$PREFIX/var/lib/postgresql/logfile" start 2>/dev/null

cat << EOF > "$PREFIX/bin/msfconsole"
#!/bin/bash
if ! pgrep -x "postgres" > /dev/null; then
    pg_ctl -D "$PREFIX/var/lib/postgresql" -l "$PREFIX/var/lib/postgresql/logfile" start
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

cd $HOME
rm -rf nokogiri-"$NOKO_VERSION"
rm -f nokogiri-"$NOKO_VERSION".gem
rm -f "$PREFIX/include/nokogiri_gumbo.h"

banner
echo -e "${GREEN}[✓] Metasploit Installed & Cleaned!${RESET}"
echo -e "${YELLOW}Start with: ${GREEN}msfconsole${RESET}"
