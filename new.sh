n#!/data/data/com.termux/files/usr/bin/bash

set -e

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
NC="\033[0m"

center() {
  termwidth=$(stty size | cut -d" " -f2)
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

clear
echo -e "${BLUE}"
center "METASPLOIT INSTALLER FOR TERMUX"
echo -e "${NC}"
sleep 1

echo -e "${GREEN}[*] Updating Termux...${NC}"
pkg update -y && pkg upgrade -y

echo -e "${GREEN}[*] Installing required packages...${NC}"
pkg install -y git ruby clang make openssl libxml2 libxslt postgresql readline ncurses autoconf bison curl wget libffi zlib pkg-config libgmp libgrpc libsqlite unzip zip termux-tools

echo -e "${GREEN}[*] Installing bundler...${NC}"
gem install bundler --no-document

echo -e "${GREEN}[*] Cloning Metasploit Framework...${NC}"
cd ~
rm -rf metasploit-framework
git clone https://github.com/rapid7/metasploit-framework.git --depth=1
cd metasploit-framework

echo -e "${GREEN}[*] Configuring bundle for nokogiri system libraries...${NC}"
bundle config build.nokogiri "--use-system-libraries --with-xml2-include=$PREFIX/include/libxml2"

echo -e "${GREEN}[*] Installing Gems... (This might take 5-15 minutes)${NC}"
if ! bundle install -j$(nproc --all); then
  echo -e "${RED}[!] Bundle install failed, attempting fix...${NC}"
  gem install nokogiri --platform=ruby -- --use-system-libraries
  bundle install -j1 || { echo -e "${RED}[X] Failed to install bundle dependencies. Exiting.${NC}"; exit 1; }
fi

echo -e "${GREEN}[*] Fixing shebangs...${NC}"
find . -type f -executable -exec termux-fix-shebang {} \;

echo -e "${GREEN}[*] Linking binaries...${NC}"
ln -sf ~/metasploit-framework/msfconsole $PREFIX/bin/
ln -sf ~/metasploit-framework/msfvenom $PREFIX/bin/

echo -e "${GREEN}[*] Setting up PostgreSQL...${NC}"
mkdir -p $PREFIX/var/lib/postgresql
initdb $PREFIX/var/lib/postgresql
pg_ctl -D $PREFIX/var/lib/postgresql -l $PREFIX/var/lib/postgresql/logfile start

echo -e "${BLUE}"
center "METASPLOIT INSTALLED SUCCESSFULLY"
echo -e "${GREEN}You can now launch with: msfconsole${NC}"
