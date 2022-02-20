clear

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\033[1;33m"
ENDCOLOR="\e[0m"
echo -e '
____________________        _____________
|      |             |      ||           ||
|      |           _ |      ||           ||
|------|          | `-._|\  ||           ||
|      |          |       \ ||___________||
|      |          |    _  / |   _______   |
|------|------.---|_.-. |/  |  |    __ |  |
|      |      |      |      |  |   |__||  |
|______|______|______|      .--|_______|--.      Backup

' | lolcat
echo -e "${RED} MeTaSpLoIt BaCk Up PrOcEsS...$"
echo "  "
echo -e "${GREEN} [ThIs MaY TaKe TiMe UpTo 30 SeCoNdS sO wAiT]${ENDCOLOR}"

if [ -d $HOME/metasploit-framework ]; then
echo -e "${YELLOW} Metasploit is backing up...!${ENDCOLOR}"
cd $HOME/Metasploit-termux/.object
rm -rf backup
mkdir backup
termux-setup-storage
cp -r $HOME/metasploit-framework $HOME/Metasploit-termux/.object/backup
mv backup /sdcard
echo -e "${GREEN} [Backup Completed]${ENDCOLOR}"
echo -e "${YELLOW} NoW YoU CAn ReStOrE It AnY TiMe${ENDCOLOR}"
else
echo " "
echo " "
echo -e "${YELLOW} Metasploit is not installed please install it ${ENDCOLOR}"
sleep 3.0
echo " "
echo " "
cd $HOME/Metasploit-termux
bash metasploit.sh
echo " "
echo " "
fi
