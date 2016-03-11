#!/bin/bash


echo "Select PocketMine Core"
echo "（1）genisys (0.14 | PHP7)"
echo "（2）pmb (0.14 | PHP5)"
echo "=========================================="
echo -n "Enter："

read character
case $character in
    1 ) wget -q -O - http://getpm.reh.tw/lang/en/getpm/ | bash -s - -v genisys
        ;;
    2 ) wget -q -O - http://getpm.reh.tw/lang/en/getpm/ | bash -s - -v pmb
        ;;
    * ) echo "Please enter the correct number"
        echo "1~2"
esac
