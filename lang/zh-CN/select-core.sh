#!/bin/bash


echo "选择 PocketMine 核心"
echo "（1）genisys (0.14 | PHP7)"
echo "（2）pmb (0.14 | PHP5)"
echo "=========================================="
echo -n "输入："

read character
case $character in
    1 ) wget -q -O - http://getpm.reh.tw/lang/zh-CN/getpm/ | bash -s - -v genisys
        ;;
    2 ) wget -q -O - http://getpm.reh.tw/lang/zh-CN/getpm/ | bash -s - -v pmb
        ;;
    * ) echo "请输入正确的编号"
        echo "1~2"
esac
