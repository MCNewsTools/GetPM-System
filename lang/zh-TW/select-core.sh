#!/bin/bash


rm select-lang.sh
echo "選擇 PocketMine 核心"
echo "（1）PocketMine-MP (0.14 | PHP7)"
echo "（2）Genisys (0.14 | PHP7)"
echo "（3）pmb (0.14 | PHP7)"
echo "=========================================="
echo -n "輸入："

read character
case $character in
    1 ) wget -q -O - http://getpm.reh.tw/lang/zh-TW/getpm/ | bash -s - -v PocketMine-MP
        ;;
    2 ) wget -q -O - http://getpm.reh.tw/lang/zh-TW/getpm/ | bash -s - -v Genisys
        ;;
    3 ) wget -q -O - http://getpm.reh.tw/lang/zh-TW/getpm/ | bash -s - -v pmb
        ;;
    * ) echo "請輸入正確的編號"
        echo "1~3"
esac
