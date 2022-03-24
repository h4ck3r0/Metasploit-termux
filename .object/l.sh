clear
mob=$(uname -o)
arc=$(dpkg --print-architecture)
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

if [ -d $HOME/metasploit-framework ];
then
echo -e  "\033[92mCHEKING OLD METASPLOIT"
echo -e "\e[34mREMOVING METASPLOIT.....WAIT\e[0m"
find . -type d -name "metasploit-*" -exec rm -rf "{}" \; >/dev/null 
sleep 4.0
echo -e "\e[34mREMOVED METASPLOIT SUCCESSFULLY.....[\e[92m✓\e[34m]\e[0m"
sleep 4.0
cwd=$(pwd)
else
echo
fi
if [[ $arc = "arm" ]];
then
msfvar=6.0.27
msfpath='/data/data/com.termux/files/home'

echo -e "\033[92mINSTALLING REQUIREED PACKAGES"
echo -e "\e[34mPACKAGES BEING INSTALLED WAIT....\e[0m"

apt update && apt upgrade -y

apt install -y binutils libiconv zlib autoconf bison clang coreutils curl findutils git apr apr-util libffi libgmp libpcap postgresql readline libsqlite openssl libtool libxml2 libxslt ncurses pkg-config wget make ruby libgrpc termux-tools ncurses-utils ncurses unzip zip tar termux-elf-cleaner
apt --fix-broken install
# Many phones are claiming libxml2 not found error
ln -sf $PREFIX/include/libxml2/libxml $PREFIX/include/

echo -e "\e[34mPACKAGES INSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[0m"
sleep 5.0
clear
echo -e "\033[92mINSTALLING  METASPLOIT"
echo -e "\e[34mINSTALLING METASPLOIT....\e[0m"

cd $msfpath
curl -LO https://github.com/rapid7/metasploit-framework/archive/$msfvar.tar.gz

tar -xf $msfpath/$msfvar.tar.gz
mv $msfpath/metasploit-framework-$msfvar $msfpath/metasploit-framework
cd $msfpath/metasploit-framework
echo -e "\033[92mWorking On Some Fixes .....\e[0m"
apt remove -y ruby
cp -r ~/Metasploit-termux/.object/ruby1.deb $HOME
cd $HOME
apt install -y ./ruby1.deb 
apt-mark hold ruby
wget https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt >/dev/null 2>&1
bash fix-ruby-bigdecimal.sh.txt
cd $HOME/metasploit-framework 
gem install bundler
bundle config set force_ruby_platform true
bundle install
gem install actionpack
bundle update activesupport
bundle update --bundler
bundle install -j$(nproc --all)
bundle config build.nokogiri --use-system-libraries

clear
echo -e "\033[92mCreating Postgresql Database\e[0m"
mkdir -p $PREFIX/var/lib/postgresql >/dev/null 2>&1
initdb $PREFIX/var/lib/postgresql 
pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql -l logfile start
termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
cd $HOME
rm $ver.tar.gz 
rm ruby1.deb 

echo -e "\e[34mINSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[92m"
echo -e "\e[34mTO START METASPLOIT TYPE (./msfconsole) INSIDE METASPLOIT FRAMEWORK\e[0m"
sleep 5.0
cd $HOME/metasploit-framework
clear
./msfconsole

elif [[ $arc = "aarch64" ]];
then
msfvar=6.0.27
msfpath='/data/data/com.termux/files/home'

echo -e "\033[92mINSTALLING REQUIREED PACKAGES"
echo -e "\e[34mPACKAGES BEING INSTALLED WAIT....\e[0m"

apt update && apt upgrade -y

apt install -y binutils libiconv zlib autoconf bison clang coreutils curl findutils git apr apr-util libffi libgmp libpcap postgresql readline libsqlite openssl libtool libxml2 libxslt ncurses pkg-config wget make ruby libgrpc termux-tools ncurses-utils ncurses unzip zip tar termux-elf-cleaner
apt --fix-broken install
# Many phones are claiming libxml2 not found error
ln -sf $PREFIX/include/libxml2/libxml $PREFIX/include/

echo -e "\e[34mPACKAGES INSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[0m"
sleep 5.0
clear
echo -e "\033[92mINSTALLING  METASPLOIT"
echo -e "\e[34mINSTALLING METASPLOIT....\e[0m"

cd $msfpath
curl -LO https://github.com/rapid7/metasploit-framework/archive/$msfvar.tar.gz

tar -xf $msfpath/$msfvar.tar.gz
mv $msfpath/metasploit-framework-$msfvar $msfpath/metasploit-framework
cd $msfpath/metasploit-framework
echo -e "\033[92mWorking On Some Fixes .....\e[0m"
apt remove -y ruby
cp -r ~/Metasploit-termux/.object/ruby.deb $HOME
cd $HOME
apt install -y ./ruby.deb 
apt-mark hold ruby
wget https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt >/dev/null 2>&1
bash fix-ruby-bigdecimal.sh.txt
cd $HOME/metasploit-framework 

gem install bundler
bundle config set force_ruby_platform true
bundle install
gem install actionpack
bundle update activesupport
bundle update --bundler
bundle install -j$(nproc --all)
bundle config build.nokogiri --use-system-libraries

clear
echo -e "\033[92mCreating Postgresql Database\e[0m"
mkdir -p $PREFIX/var/lib/postgresql >/dev/null 2>&1
initdb $PREFIX/var/lib/postgresql 
pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql -l logfile start
termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
cd $HOME
rm $ver.tar.gz 
rm ruby.deb 
else
echo
fi

echo -e "\e[34mINSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[92m"
echo -e "\e[34mTO START METASPLOIT TYPE (./msfconsole) INSIDE METASPLOIT FRAMEWORK\e[0m"
sleep 5.0
cd $HOME/metasploit-framework
clear
./msfconsole
