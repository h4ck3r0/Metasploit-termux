clear

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

echo -e "${RED}"
echo -e "${RED} ██▀███  ▓█████  ██▓███   ▄▄▄       ██▓ ██▀███  "
echo -e "${RED}▓██ ▒ ██▒▓█   ▀ ▓██░  ██▒▒████▄    ▓██▒▓██ ▒ ██▒"
echo -e "${RED}▓██ ░▄█ ▒▒███   ▓██░ ██▓▒▒██  ▀█▄  ▒██▒▓██ ░▄█ ▒"
echo -e "${RED}▒██▀▀█▄  ▒▓█  ▄ ▒██▄█▓▒ ▒░██▄▄▄▄██ ░██░▒██▀▀█▄  "
echo -e "${RED}░██▓ ▒██▒░▒████▒▒██▒ ░  ░ ▓█   ▓██▒░██░░██▓ ▒██▒"
echo -e "${RED}░ ▒▓ ░▒▓░░░ ▒░ ░▒▓▒░ ░  ░ ▒▒   ▓▒█░░▓  ░ ▒▓ ░▒▓░"
echo -e "${RED}  ░▒ ░ ▒░ ░ ░  ░░▒ ░       ▒   ▒▒ ░ ▒ ░  ░▒ ░ ▒░"
echo -e "${RED}  ░░   ░    ░   ░░         ░   ▒    ▒ ░  ░░   ░ "
echo -e "${RED}   ░        ░  ░               ░  ░ ░     ░   "  
                                                
echo -e "\033[92m Repairing.....\e[0m"
apt remove -y ruby
cp -r ~/Metasploit-termux/.object/ruby.deb $loc
cd $loc
apt install -y ./ruby.deb 
apt-mark hold ruby
cd $HOME/metasploit-framework 
gem install bundler
bundle config set force_ruby_platform true
bundle install
gem install actionpack
bundle update activesupport
bundle update --bundler
bundle install -j$(nproc --all)
bundle config build.nokogiri --use-system-libraries
wget https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt >/dev/null 2>&1
bash fix-ruby-bigdecimal.sh.txt
clear
echo -e "\033[92m"
center "Creating Postgresql Database\e[0m"
mkdir -p $PREFIX/var/lib/postgresql >/dev/null 2>&1
initdb $PREFIX/var/lib/postgresql 
pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql -l logfile start
termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
cd $loc
rm $ver.tar.gz 
rm ruby.deb 
echo -e "\033[92m"
"Repaired Successfully\e[0m"
cd ~/Metasploit-termux ; bash metasploit.sh
