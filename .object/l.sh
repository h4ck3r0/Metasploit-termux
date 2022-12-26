
clear
center() {
  termwidth=$(stty size | cut -d" " -f2)
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

echo -e "${RED} ███████ ▓█████▄▄▄█████▓ █    ██  ██▓███  " 
echo -e "${RED}▒██    ▒ ▓█   ▀▓  ██▒ ▓▒ ██  ▓██▒▓██░  ██▒" 
echo -e "${RED}░ ▓██▄   ▒███  ▒ ▓██░ ▒░▓██  ▒██░▓██░ ██▓▒" 
echo -e "${RED}  ▒   ██▒▒▓█  ▄░ ▓██▓ ░ ▓▓█  ░██░▒██▄█▓▒ ▒" 
echo -e "${RED}▒██████▒▒░▒████▒ ▒██▒ ░ ▒▒█████▓ ▒██▒ ░  ░" 
echo -e "${RED}▒ ▒▓▒ ▒ ░░░ ▒░ ░ ▒ ░░   ░▒▓▒ ▒ ▒ ▒▓▒░ ░  ░" 
echo -e "${RED}░ ░▒  ░ ░ ░ ░  ░   ░    ░░▒░ ░ ░ ░▒ ░     " 
echo -e "${RED}░  ░  ░     ░    ░       ░░░ ░ ░ ░░       " 
echo -e "${RED}     ░     ░  ░           ░           ${ENDCOLOR}   " 
sleep 5.0

# Install gnupg required to sign repository
pkg install -y gnupg

# Sign gushmazuko repository
curl -fsSL https://raw.githubusercontent.com/gushmazuko/metasploit_in_termux/master/gushmazuko-gpg.pubkey | gpg --dearmor | tee $PREFIX/etc/apt/trusted.gpg.d/gushmazuko-repo.gpg

# Add gushmazuko repository to install ruby 2.7.2 version
echo 'deb https://github.com/gushmazuko/metasploit_in_termux/raw/master gushmazuko main'  | tee $PREFIX/etc/apt/sources.list.d/gushmazuko.list

# Set low priority for all gushmazuko repository (for security purposes)
# Set highest priority for ruby package from gushmazuko repository
echo '## Set low priority for all gushmazuko repository (for security purposes)
Package: *
Pin: release gushmazuko
Pin-Priority: 100
## Set highest priority for ruby package from gushmazuko repository
Package: ruby
Pin: release gushmazuko
Pin-Priority: 1001' | tee $PREFIX/etc/apt/preferences.d/preferences

# Purge installed ruby
apt purge ruby -y
rm -fr $PREFIX/lib/ruby/gems
clear
echo -e "\e[34m[\e[92m✓\e[34m]\033[92m INSTALLING REQUIREED PACKAGES"
sleep 5.0
pkg upgrade -y -o Dpkg::Options::="--force-confnew"
pkg install -y python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils ncurses git wget unzip zip tar termux-tools termux-elf-cleaner pkg-config git ruby -o Dpkg::Options::="--force-confnew" --allow-change-held-packages
echo -e "\e[34m"
center "PACKAGES BEING INSTALLED WAIT"
sleep 5.0
python3 -m pip install --upgrade pip
python3 -m pip install requests
clear
echo -e "\e[34m[\e[92m✓\e[34m]\e[34m PACKAGES INSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[0m"

sleep 5.0
clear
echo -e "\e[34m[\e[92m✓\e[34m]\033[92m Fixing ruby BigDecimal...\033[0m"
echo ""
source <(curl -sL https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt)

echo -e "\e[34m[\e[92m✓\e[34m]\033[92m CHEKING OLD METASPLOIT"
find . -type d -name "metasploit-*" -exec rm -rf "{}" \; >/dev/null 
sleep 4.0
echo -e "\e[34m"
center "REMOVING METASPLOIT.....WAIT"
rm -rf $HOME/metasploit-framework
echo -e "\e[34m[\e[92m✓\e[34m]\e[34m REMOVED METASPLOIT SUCCESSFULLY.....[\e[92m✓\e[34m]\e[0m"
sleep 4.0
echo
clear
echo -e "\e[34m"
center "INSTALLING METASPLOIT"
echo -e "\e[0m"
sleep 5.0
cd $HOME
msfvar=6.0.27
msfpath='/data/data/com.termux/files/home'

cd $msfpath
curl -LO https://github.com/rapid7/metasploit-framework/archive/$msfvar.tar.gz

tar -xf $msfpath/$msfvar.tar.gz
mv $msfpath/metasploit-framework-$msfvar $msfpath/metasploit-framework
cd $msfpath/metasploit-framework
clear
echo -e "\e[34m[\e[92m✓\e[34m]\033[92m Working On Some Fixes .....\e[0m"
sleep 5.0
cd $HOME/metasploit-framework

cd;cd metasploit-framework;ln -s $HOME/metasploit-framework/msfvenom /data/data/com.termux/files/usr/bin/
clear
echo -e "\e[34m[\e[92m✓\e[34m]\033[92m Creating Postgresql Database\e[0m"
sleep 5.0
mkdir -p $PREFIX/var/lib/postgresql >/dev/null 2>&1
initdb $PREFIX/var/lib/postgresql 
pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql -l logfile start
termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
echo -e "\e[34mINSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[92m"
sleep 5.0
echo -e "\e[0m"
clear
cd ~/metasploit-framework && ./msfconsole
