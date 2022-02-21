clear

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

banner() {
echo "\e[31m"
echo'

░▒█▀▀▀█░█▀▀░█░░█▀▀░█▀▄░▀█▀░░░▒█░░▒█░█▀▀░█▀▀▄░█▀▀░░▀░░▄▀▀▄░█▀▀▄
░░▀▀▀▄▄░█▀▀░█░░█▀▀░█░░░░█░░░░░▒█▒█░░█▀▀░█▄▄▀░▀▀▄░░█▀░█░░█░█░▒█
░▒█▄▄▄█░▀▀▀░▀▀░▀▀▀░▀▀▀░░▀░░░░░░▀▄▀░░▀▀▀░▀░▀▀░▀▀▀░▀▀▀░░▀▀░░▀░░▀

'
echo ""
 echo -e "\e[1;31m  [\e[32m√\e[31m] \e[1;91m by \e[1;36mRaj Aryan \e[93m/ \e[100;92m Youtube.com/c/H4Ck3R0\e[0m"

                  }
wr () {
           
                               printf "\033[1;91m Invalid input!!!\n"
                               selection
                               }
                               1line() {

                                                        cd ~/Metasploit-termux/.object ; bash l.sh
                                                        
                                       }
                                       2line() {
                                                cd ~/Metasploit-termux/.object ; bash m.sh
                                                
                                               }
                                                       
    selection () {
                                           
                                            echo -e -n "\e[1;96m Choose\e[1;96m Option : \e[0m"
                                            cd ~/Metasploit-termux
                                            read a
                                            case $a in
                                            1) 1line ;;
                                            2) 2line ;;
                                            3) exit ;;
                                            *) wr ;;

                                            esac 
                                            }

  menu () {
                                  banner
                                  printf "\n\033[1;91m[\033[0m1\033[1;91m]\033[1;92m metasploit  for  4.4 and 6.0 version \n"
                                  printf "\033[1;91m[\033[0m2\033[1;91m]\033[1;92m Metasploit  for  7.0 and  above \n"
                                  printf "\033[1;91m[\033[0m3\033[1;91m]\033[1;92m Exit\n\n\n"
                                  
                                  selection
                                  }
                  menu
