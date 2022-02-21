pkg install ruby
gem install lolcat
clear

banner() {
echo '
  .---------------------------------------.  
  |         ╔╗              ╔╗        ╔╗  |  Give Star
  |        ╔╝╚╗             ║║       ╔╝╚╗ |  INFO
  |╔╗╔╗╔══╗╚╗╔╝╔══╗ ╔══╗╔══╗║║ ╔══╗╔╗╚╗╔╝ |  
  |║╚╝║║╔╗║ ║║ ╚ ╗║ ║══╣║╔╗║║║ ║╔╗║╠╣ ║║  |  I Am Raj Aryan
  |║║║║║║═╣ ║╚╗║╚╝╚╗╠══║║╚╝║║╚╗║╚╝║║║ ║╚╗ |  18 / Learner
  |╚╩╩╝╚══╝ ╚═╝╚═══╝╚══╝║╔═╝╚═╝╚══╝╚╝ ╚═╝ |  
  | ╔╗                  ║║                |  WEBSITES
  |╔╝╚╗                 ╚╝                |  
  |╚╗╔╝╔══╗╔═╗╔╗╔╗╔╗╔╗╔╗╔╗ Support US     |  h4ck3r.me
  | ║║ ║╔╗║║╔╝║╚╝║║║║║╚╬╬╝ Android Version|  explores.social
  | ║╚╗║║═╣║║ ║║║║║╚╝║╔╬╬╗ 4.4 to latest  |  
  | ╚═╝╚══╝╚╝ ╚╩╩╝╚══╝╚╝╚╝ @h4ck3r_0      |  Ethical Hacker
  | by H4ck3r    Madewith♥                |  Programmer
  .---------------------------------------.                    
                                                                                                           
' | lolcat
 echo""
 echo -e "\e[1;31m  [\e[32m√\e[31m] \e[1;91m by \e[1;36mRaj Aryan \e[93m/ \e[100;92m Youtube.com/c/H4Ck3R0\e[0m"

                  }
wr () {
           
                               printf "\033[1;91m Invalid input!!!\n"
                               selection
                               }
                               1line() {
                                        cd ~/Metasploit-termux/.object ; bash ml.sh
                                        cd ~/Metasploit-termux ; bash metasploit.sh 
                                        
                                       }
                                       2line() {
                                                
                                                cd ~/Metasploit-termux/.object ; bash r.sh
                                                cd ~/Metasploit-termux ; bash metasploit.sh
                                               }
                                               3line() {
                                                      
                                                       cd ~/Metasploit-termux/.object ; bash b.sh                                                      
                                                       cd ~/Metasploit-termux ; bash metasploit.sh
                                                       
                                                         }
                                                          4line() {
                                                                  cd ~/Metasploit-termux/.object ; bash re.sh                                                      
                                                       cd ~/Metasploit-termux ; bash metasploit.sh
                                                                  cd ~/kali-theme ; bash metasploit.sh
                                                                  }
                                                                  5line() {                                                                  
                                                                            rm -rf ~/Metasploit-termux
                                                                            cd
                                                                            git clone https://github.com/h4ck3r0/Metasploit-termux
                                                                            cd ~/Metasploit-termux ; bash metasploit.sh
       
                                                                  }
    selection () {
                                           
                                            echo -e -n "\e[1;96m Choose\e[1;96m Option : \e[0m"
                                            cd ~/Metasploit-termux
                                            read a
                                            case $a in
                                            1) 1line ;;
                                            2) 2line ;;
                                            3) 3line ;;
                                            4) 4line ;;
                                            5) 5line  ;;
                                            6) exit ;;
                                            *) wr ;;

                                            esac 
                                            }

  menu () {
                                  banner
                                  printf "\n\033[1;91m[\033[0m1\033[1;91m]\033[1;92m Metasploit Installation\n"
                                  printf "\033[1;91m[\033[0m2\033[1;91m]\033[1;92m Repair\n"
                                  printf "\033[1;91m[\033[0m3\033[1;91m]\033[1;92m Backup\n"
                                  printf "\033[1;91m[\033[0m4\033[1;91m]\033[1;92m Restore\n"
                                  printf "\033[1;91m[\033[0m5\033[1;91m]\033[1;92m Update\n"
                                  printf "\033[1;91m[\033[0m6\033[1;91m]\033[1;92m Exit\n\n\n"
                                  
                                  selection
                                  }
menu
