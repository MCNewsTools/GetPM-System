#!/bin/bash


rm select-lang.sh
printf "\33[0;93m"
echo "選擇 PocketMine 核心"
printf "\e[0m"

printf "\33[0;93m"
echo -n "（1）"
printf "\33[0m"
echo -n "PocketMine-MP"
printf "\33[0;91m"
echo " (0.15 | PHP7)"
printf "\33[0m"

printf "\33[0;93m"
echo -n "（2）"
printf "\33[0m"
echo -n "Genisys"
printf "\33[0;91m"
echo " (0.15 | PHP7)"
printf "\33[0m"

printf "\33[0;93m"
echo -n "（3）"
printf "\33[0m"
echo -n "ClearSky"
printf "\33[0;91m"
echo " (0.15 | PHP7)"
printf "\33[0m"

echo "=========================================="
printf "\33[0;92m"
echo -n "輸入："
printf "\33[0m"

read character
case $character in
    1 ) wget -q -O - http://getpm.mcpe.tw/lang/zh-TW/getpm/ | bash -s - -v PocketMine-MP
        ;;
    2 ) wget -q -O - http://getpm.mcpe.tw/lang/zh-TW/getpm/ | bash -s - -v Genisys
        ;;
	3 ) wget -q -O - http://getpm.mcpe.tw/lang/zh-TW/getpm/ | bash -s - -v ClearSky
        ;;
    * ) printf "\33[0;91m"
	    echo "請輸入正確的編號"
		printf "\e[0m"
		printf "\33[0;93m"
        echo "1~3"
		printf "\e[0m"
esac
