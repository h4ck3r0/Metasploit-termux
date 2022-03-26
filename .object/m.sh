mob=$(uname -o)
arc=$(dpkg --print-architecture)
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
center "PACKAGES BEING INSTALLED WAIT...."
sleep 5.0
python3 -m pip install --upgrade pip
python3 -m pip install requests
clear
echo -e "\e[34m[\e[92m✓\e[34m]\e[34m PACKAGES INSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[0m"

sleep 5.0

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
center "INSTALLING METASPLOIT...."
echo -e "\e[0m"
sleep 5.0
cd $HOME
git clone https://github.com/rapid7/metasploit-framework.git --depth=1
clear
echo -e "\e[34m[\e[92m✓\e[34m]\033[92mWorking On Some Fixes .....\e[0m"
sleep 5.0
cd $HOME/metasploit-framework
sed '/rbnacl/d' -i Gemfile.lock
sed '/rbnacl/d' -i metasploit-framework.gemspec

echo 


export MSF_FIX="spec.add_runtime_dependency 'net-smtp'"
sed -i "146i \  $MSF_FIX" metasploit-framework.gemspec
sed -i "277,\$ s/2.8.0/2.2.0/" Gemfile.lock

gem install bundler
sed 's|nokogiri (1.*)|nokogiri (1.8.0)|g' -i Gemfile.lock

gem install nokogiri -v 1.8.0 -- --use-system-libraries

gem install actionpack
bundle update activesupport
bundle update --bundler
bundle install -j$(nproc --all)
$PREFIX/bin/find -type f -executable -exec termux-fix-shebang \{\} \;
rm ./modules/auxiliary/gather/http_pdf_authors.rb
if [ -e $PREFIX/bin/msfconsole ];then
	rm $PREFIX/bin/msfconsole
fi
if [ -e $PREFIX/bin/msfvenom ];then
	rm $PREFIX/bin/msfvenom
fi
ln -s $HOME/metasploit-framework/msfconsole /data/data/com.termux/files/usr/bin/
ln -s $HOME/metasploit-framework/msfvenom /data/data/com.termux/files/usr/bin/
termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so

echo
echo -e "\033[32m"
center " Still Fixing....."
echo -e "\033[0m"

sed -i '355 s/::Exception, //' $PREFIX/bin/msfvenom
sed -i '481, 483 {s/^/#/}' $PREFIX/bin/msfvenom
sed -Ei "s/(\^\\\c\s+)/(\^\\\C-\\\s)/" /data/data/com.termux/files/home/metasploit-framework/lib/msf/core/exploit/remote/vim_soap.rb
sed -i '86 {s/^/#/};96 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/concurrent-ruby-1.0.5/lib/concurrent/atomic/ruby_thread_local_var.rb
sed -i '442, 476 {s/^/#/};436, 438 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/logging-2.3.0/lib/logging/diagnostic_context.rb
rm -rf /data/data/com.termux/files/usr/bin/msfvenom
sed -i '13,15 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/encryption_algorithm/functionable.rb; sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp256.rb; sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp384.rb; sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp521.rb;

cd;cd metasploit-framework;ln -s $HOME/metasploit-framework/msfvenom /data/data/com.termux/files/usr/bin/
echo -e "\e[34m[\e[92m✓\e[34m]\033[92m Creating Postgresql Database\e[0m"
sleep 5.0
mkdir -p $PREFIX/var/lib/postgresql >/dev/null 2>&1
initdb $PREFIX/var/lib/postgresql 
pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql -l logfile start
termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
echo -e "\e[34mINSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[92m"
echo 
cd ~/metasploit-framework && ./msfconsole
