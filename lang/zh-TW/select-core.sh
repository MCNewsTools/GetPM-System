#!/bin/bash


rm select-lang.sh
echo "選擇 PocketMine 核心"
echo "（1）genisys (0.14 | PHP7)"
echo "（2）pmb (0.14 | PHP5)"
echo "=========================================="
echo -n "輸入："

read character
case $character in
    1 ) wget -q -O - http://getpm.reh.tw/lang/zh-TW/getpm/ | bash -s - -v genisys
        ;;
    2 ) wget -q -O - http://getpm.reh.tw/lang/zh-TW/getpm/ | bash -s - -v pmb
        ;;
    * ) echo "請輸入正確的編號"
        echo "1~2"
esac
