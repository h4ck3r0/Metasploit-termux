clear

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\033[1;33m"
ENDCOLOR="\e[0m"
echo -e '

                  ,--.!,
               __/   -*-
             ,d08b.  `|`
             0088MM     
             `9MMP.     Restore
             '| lolcat  
              echo -e "\e[1;31m  [\e[32m√\e[31m] \e[1;91m by \e[1;36mSubscribe\e[93m/ \e[100;92myoutube.com/c/h4ck3r0\e[0m"
 echo " "
echo -e "${RED}                MeTaSpLoIt Is ReStOrIng...$rset"
echo "  "
echo -e "${GREEN}       [ThIs MaY TaKe TiMe So juSt BuY mE a CofFeE]${ENDCOLOR}"
echo " "
echo -e "${RED}        Note:-${YELLOW} Make sure you have backed up metasploit  
             if not then please backup it first then run this${ENDCOLOR}"             
  if [ -d $HOME/metasploit-framework ]; then
echo -e "${YELLOW}             Metasploit Is Already Present In Termux...!${ENDCOLOR}"
echo " "
echo -e "${RED}      No need to restore it if you still want to restore it
              then remove metasploit first from termux${ENDCOLOR}"
else
clear
echo " "
echo -e "${YELLLOW}             MeTaSpLoIt Is ReStOrInG pLeAsE wAiT...${ENDCOLOR}"
echo " "
echo " "
sleep 3.0
cd $HOME
rm -rf backup
termux-setup-storage
cd /sdcard
cp -r backup $HOME
cd backup
mv metasploit-framework $HOME
cd metasploit-framework
cd ~/Metasploit-termux
bash metasploit.sh
clear
echo " "
echo " "
echo -e "${GREEN}         [${RED} If you are seeing this message then you 
 dont have a backup to restore or some internet connection
                        problem ${GREEN}]${ENDCOLOR}"
fi
echo " "
echo " "            
