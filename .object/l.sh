
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

latestverr(){
curl https://raw.githubusercontent.com/rapid7/metasploit-framework/master/Gemfile.lock -s|grep metasploit-framework|head -1|sed 's/ //g'|sed 's#(# #g;s#)##g;s# #: #g'|awk '{print $2}'
}
# Un Wanted Source Lists
rm $PREFIX/etc/apt/sources.list.d/*

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
msfvar=6.1.36
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
# Not Need Any More

# sed '/rbnacl/d' -i Gemfile.lock
# sed '/rbnacl/d' -i metasploit-framework.gemspec

echo 
#fixed

# sed -i "305,\$ s/0.13.1/0.14.1/" Gemfile.lock

gem install bundler

declare NOKOGIRI_VERSION=$(cat Gemfile.lock | grep -i nokogiri | sed 's/nokogiri [\(\)]/(/g' | cut -d ' ' -f 5 | grep -oP "(.).[[:digit:]][\w+]?[.].")
# gem install nokogiri --platform=ruby
# sed 's|nokogiri (1.*)|nokogiri (1.8.0)|g' -i Gemfile.lock

# gem install nokogiri -v 1.8.0 -- --use-system-libraries
gem install nokogiri -v $NOKOGIRI_VERSION -- --use-system-libraries

# for aarch64 
bundle config build.nokogiri "--use-system-libraries --with-xml2-include=$PREFIX/include/libxml2"; bundle install

gem install actionpack
bundle update activesupport
bundle update --bundler
bundle install -j$(nproc --all)
gem install pry

#$PREFIX/bin/find -type f -executable -exec termux-fix-shebang \{\} \;
#rm ./modules/auxiliary/gather/http_pdf_authors.rb

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

# sed -i '355 s/::Exception, //' $PREFIX/bin/msfvenom
# sed -i '481, 483 {s/^/#/}' $PREFIX/bin/msfvenom
# sed -Ei "s/(\^\\\c\s+)/(\^\\\C-\\\s)/" /data/data/com.termux/files/home/metasploit-framework/lib/msf/core/exploit/remote/vim_soap.rb

## Payload Generating Error Fix

sed -i '86 {s/^/#/};96 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.2.0/gems/concurrent-ruby-1.0.5/lib/concurrent/atomic/ruby_thread_local_var.rb
sed -i '442, 476 {s/^/#/};436, 438 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.2.0/gems/logging-2.3.0/lib/logging/diagnostic_context.rb
rm -rf /data/data/com.termux/files/usr/bin/msfvenom
sed -i '13,14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.2.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/encryption_algorithm/functionable.rb;sed -i '15 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.2.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/encryption_algorithm/functionable.rb;sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.2.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp256.rb;sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.2.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp384.rb;sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.2.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp521.rb

cd;cd metasploit-framework;ln -s $HOME/metasploit-framework/msfvenom /data/data/com.termux/files/usr/bin/
clear
echo -e "\e[34m[\e[92m✓\e[34m]\033[92m Creating Postgresql Database\e[0m"
sleep 5.0
mkdir -p $PREFIX/var/lib/postgresql >/dev/null 2>&1
initdb $PREFIX/var/lib/postgresql 
pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql -l logfile start
termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
echo -e "\e[34mINSTALLED SUCCESSFULLY....[\e[92m✓\e[34m]\e[92m"

termux-open-url https://h4ck3r.me/how-to-install-metasploit-in-termux/

sleep 5.0
echo -e "\e[0m"
clear
cd ~/metasploit-framework && ./msfconsole
