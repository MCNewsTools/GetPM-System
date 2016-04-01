#!/bin/bash


printf "\33[0;93m"
echo "Select language"
printf "\e[0m"

printf "\33[0;93m"
echo -n "（1）"
printf "\33[0m"
echo -n "English"
printf "\33[0;92m"
echo " en"
printf "\33[0m"

printf "\33[0;93m"
echo -n "（2）"
printf "\33[0m"
echo -n "繁體中文"
printf "\33[0;92m"
echo " zh-TW"
printf "\33[0m"

printf "\33[0;93m"
echo -n "（3）"
printf "\33[0m"
echo -n "简体中文"
printf "\33[0;92m"
echo " zh-CN"
printf "\33[0m"

echo "=========================================="
printf "\33[0;92m"
echo -n "Enter："
printf "\33[0m"

read character
case $character in
    1 ) wget -q -O - http://getpm.techplayer.org/lang/en/ | bash
        ;;
    2 ) wget -q -O - http://getpm.techplayer.org/lang/zh-TW/ | bash
        ;;
    3 ) wget -q -O - http://getpm.techplayer.org/lang/zh-CN/ | bash
        ;;
    * ) printf "\33[0;91m"
	    echo "Please enter the correct number"
		printf "\e[0m"
		printf "\33[0;93m"
        echo "1~3"
		printf "\e[0m"
esac
