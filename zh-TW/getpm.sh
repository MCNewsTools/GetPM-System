#!/bin/bash

CHANNEL="stable"
NAME="PocketMine-MP"

update=off
forcecompile=off
alldone=no
checkRoot=off
XDEBUG="off"
alternateurl=on

INSTALL_DIRECTORY="./"

IGNORE_CERT="yes"

while getopts "arxucid:v:" opt; do
  case $opt in
    a)
      alternateurl=on
      ;;
    r)
      checkRoot=off
      ;;
    x)
      XDEBUG="on"
      echo "[+] 正在啟用 xdebug"
      ;;
    u)
      update=on
      ;;
    c)
      forcecompile=on
      ;;
    d)
      INSTALL_DIRECTORY="$OPTARG"
      ;;
    i)
      IGNORE_CERT="no"
      ;;
    v)
      CHANNEL="$OPTARG"
      ;;
    \?)
      echo "無效選項: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

#Needed to use aliases
shopt -s expand_aliases
type wget > /dev/null 2>&1
if [ $? -eq 0 ]; then
    if [ "$IGNORE_CERT" == "yes" ]; then
        alias download_file="wget --no-check-certificate -q -O -"
    else
        alias download_file="wget -q -O -"
    fi
else
    type curl >> /dev/null 2>&1
    if [ $? -eq 0 ]; then
        if [ "$IGNORE_CERT" == "yes" ]; then
            alias download_file="curl --insecure --silent --location"
        else
            alias download_file="curl --silent --location"
        fi
    else
        printf "\33[0;91m"
        echo "錯誤，找不到 curl 或是 wget"
        printf "\33[0m"
    fi
fi

if [ "$CHANNEL" == "soft" ]; then
    NAME="PocketMine-Soft"
fi
if [ "$CHANNEL" == "Genisys" ]; then
    NAME="Genisys"
fi
if [ "$CHANNEL" == "ClearSky" ]; then
    NAME="ClearSky"
fi

ENABLE_GPG="no"
PUBLICKEY_URL="https://getpm.reh.tw/pocketmine.asc"
PUBLICKEY_FINGERPRINT="20D377AFC3F7535B3261AA4DCF48E7E52280B75B"
PUBLICKEY_LONGID="${PUBLICKEY_FINGERPRINT: -16}"
GPG_KEYSERVER="pgp.mit.edu"

function check_signature {
    echo "[*] 檢查簽署 $1"
    "$GPG_BIN" --keyserver "$GPG_KEYSERVER" --keyserver-options auto-key-retrieve=1 --trusted-key $PUBLICKEY_LONGID --verify "$1.sig" "$1"
    if [ $? -eq 0 ]; then
        echo "[+] 簽署已被檢查並確認為有效！"
    else
        "$GPG_BIN" --refresh-keys > /dev/null 2>&1
        echo "[!] 簽署無效！請檢查是否匯入了錯誤的密鑰或是密鑰已經損毀 (由 $PUBLICKEY_FINGERPRINT 簽署)"
        exit 1
    fi  
}

VERSION_DATA=$(download_file "https://getpm.reh.tw/api/channel/json.php?channel=$CHANNEL")

VERSION=$(echo "$VERSION_DATA" | grep '"version"' | cut -d ':' -f2- | tr -d ' ",')
BUILD=$(echo "$VERSION_DATA" | grep build | cut -d ':' -f2- | tr -d ' ",')
API_VERSION=$(echo "$VERSION_DATA" | grep api_version | cut -d ':' -f2- | tr -d ' ",')
VERSION_DATE=$(echo "$VERSION_DATA" | grep '"date"' | cut -d ':' -f2- | tr -d ' ",')
VERSION_DETAILS=$(echo "$VERSION_DATA" | grep '"details_url"' | cut -d ':' -f2- | tr -d ' ",')
VERSION_DOWNLOAD=$(echo "$VERSION_DATA" | grep '"download_url"' | cut -d ':' -f2- | tr -d ' ",')

if [ "$alternateurl" == "on" ]; then
    VERSION_DOWNLOAD=$(echo "$VERSION_DATA" | grep '"alternate_download_url"' | cut -d ':' -f2- | tr -d ' ",')
fi

if [ "$(uname -s)" == "Darwin" ]; then
    BASE_VERSION=$(echo "$VERSION" | sed -E 's/([A-Za-z0-9_\.]*).*/\1/')
    VERSION_DATE_STRING=$(date -j -f "%s" $VERSION_DATE)
else
    BASE_VERSION=$(echo "$VERSION" | sed -r 's/([A-Za-z0-9_\.]*).*/\1/')
    VERSION_DATE_STRING=$(date --date="@$VERSION_DATE")
fi

GPG_SIGNATURE=$(echo "$VERSION_DATA" | grep '"signature_url"' | cut -d ':' -f2- | tr -d ' ",')

if [ "$GPG_SIGNATURE" != "" ]; then
    ENABLE_GPG="yes"
fi

if [ "$VERSION" == "" ]; then
    printf "\33[0;91m"
    echo -n "[!] 無法取得"
    printf "\33[0;96m"
    echo -n " $NAME"
    printf "\33[0m"
    printf "\33[0;91m"
    echo " 最新的版本"
    printf "\33[0m"
    exit 1
fi

GPG_BIN=""

if [ "$ENABLE_GPG" == "yes" ]; then
    type gpg > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        GPG_BIN="gpg"
    else
        type gpg2 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            GPG_BIN="gpg2"
        fi
    fi
    
    if [ "$GPG_BIN" != "" ]; then
        gpg --fingerprint $PUBLICKEY_FINGERPRINT > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            download_file $PUBLICKEY_URL | gpg --trusted-key $PUBLICKEY_LONGID --import
            gpg --fingerprint $PUBLICKEY_FINGERPRINT > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                gpg --trusted-key $PUBLICKEY_LONGID --keyserver "$GPG_KEYSERVER" --recv-key $PUBLICKEY_FINGERPRINT
            fi
        fi
    else
        ENABLE_GPG="no"
    fi
fi

echo -n "[*] 找到"
printf "\33[0;96m"
echo -n " $NAME"
printf "\33[0m"
printf "\33[0;93m"
echo -n " $BASE_VERSION"
printf "\33[0m"
echo -n " - 建構檔"
printf "\33[0;92m"
echo -n " $BUILD"
printf "\33[0m"
printf "\33[0;91m"
echo " (API: $API_VERSION)"
printf "\33[0m"

echo -n "[*] 此"
printf "\33[0;96m"
echo -n " $CHANNEL"
printf "\33[0m"
echo -n " 建構檔發布於"
printf "\33[0;92m"
echo " $VERSION_DATE_STRING"
printf "\33[0m"

echo -n "[*] 詳細資料:"
printf "\33[0;92m"
echo " $VERSION_DETAILS"
printf "\33[0m"

if [ "$ENABLE_GPG" == "yes" ]; then
    echo "[+] 建構檔已被簽署，即將檢查簽署是否有效"
elif [ "$GPG_SIGNATURE" == "" ]; then
    if [[ "$CHANNEL" == "beta" ]] || [[ "$CHANNEL" == "stable" ]]; then
        echo "[-] 找不到任何簽署資料"
    fi
fi

echo -n "[*] 正在於路徑"
printf "\33[0;92m"
echo -n " $INSTALL_DIRECTORY"
printf "\33[0m"
echo -n " 為"
printf "\33[0;96m"
echo -n " $NAME"
printf "\33[0m"
echo " 進行安裝/更新"
mkdir -m 0777 "$INSTALL_DIRECTORY" 2> /dev/null
cd "$INSTALL_DIRECTORY"
printf "\33[0;93m"
echo -n "["
printf "\33[0m"
printf "\33[0;92m"
echo -n "1"
printf "\33[0m"
printf "\33[0;93m"
echo -n "/"
printf "\33[0m"
printf "\33[0;91m"
echo -n "4"
printf "\33[0m"
printf "\33[0;93m"
echo -n "]"
printf "\33[0m"
echo " 正在清理環境..."
rm -f "$NAME.phar"
rm -f README.md
rm -f CONTRIBUTING.md
rm -f LICENSE
rm -f start.bat
rm -f start.sh
rm -f start-php7.sh
rm -f start-php5.sh

#Old installations
rm -f PocketMine-MP.php
rm -r -f src/

printf "\33[0;93m"
echo -n "["
printf "\33[0m"
printf "\33[0;92m"
echo -n "2"
printf "\33[0m"
printf "\33[0;93m"
echo -n "/"
printf "\33[0m"
printf "\33[0;91m"
echo -n "4"
printf "\33[0m"
printf "\33[0;93m"
echo -n "]"
printf "\33[0m"
echo -n " 正在下載"
printf "\33[0;96m"
echo -n " $NAME"
printf "\33[0m"
printf "\33[0;93m"
echo -n " $VERSION"
printf "\33[0m"
echo -n " phar檔..."
set +e
download_file "$VERSION_DOWNLOAD" > "$NAME.phar"
if ! [ -s "$NAME.phar" ] || [ "$(head -n 1 $NAME.phar)" == '<!DOCTYPE html>' ]; then
    rm "$NAME.phar" 2> /dev/null
    printf "\33[0;91m"
    echo " 失敗！"
    printf "\33[0m"
    echo -n "[!] 無法從"
    printf "\33[0;93m"
    echo -n " $VERSION_DOWNLOAD"
    printf "\33[0m"
    echo -n " 自動下載"
    printf "\33[0;96m"
    echo " $NAME"
    printf "\33[0m"
    exit 1
else
    if [ "$CHANNEL" == "PocketMine-MP" ]; then
        download_file "https://getpm.reh.tw/PocketMine/PocketMine-MP/master/start-php7.sh" > start-php7.sh
        download_file "https://getpm.reh.tw/PocketMine/PocketMine-MP/master/start-php5.sh" > start-php5.sh
        download_file "https://getpm.reh.tw/PocketMine/PocketMine-MP/master/LICENSE" > LICENSE
        download_file "https://getpm.reh.tw/PocketMine/PocketMine-MP/master/README.md" > README.md
        download_file "https://getpm.reh.tw/PocketMine/PocketMine-MP/master/CONTRIBUTING.md" > CONTRIBUTING.md
    elif [ "$CHANNEL" == "Genisys" ]; then
        download_file "https://getpm.reh.tw/PocketMine/Genisys/master/resources/start-php7.sh" > start-php7.sh
        download_file "https://getpm.reh.tw/PocketMine/Genisys/master/resources/start-php5.sh" > start-php5.sh
        download_file "https://getpm.reh.tw/PocketMine/Genisys/master/resources/LICENSE" > LICENSE
        download_file "https://getpm.reh.tw/PocketMine/Genisys/master/resources/README.md" > README.md
        download_file "https://getpm.reh.tw/PocketMine/Genisys/master/resources/CONTRIBUTING.md" > CONTRIBUTING.md
    elif [ "$CHANNEL" == "ClearSky" ]; then
        download_file "https://getpm.reh.tw/PocketMine/ClearSky/master/resources/start-php7.sh" > start-php7.sh
        download_file "https://getpm.reh.tw/PocketMine/ClearSky/master/resources/start-php5.sh" > start-php5.sh
        download_file "https://getpm.reh.tw/PocketMine/ClearSky/master/resources/LICENSE" > LICENSE
        download_file "https://getpm.reh.tw/PocketMine/ClearSky/master/resources/README.md" > README.md
    else
        download_file "https://getpm.reh.tw/PocketMine/PocketMine-MP/master/start-php7.sh" > start-php7.sh
        download_file "https://getpm.reh.tw/PocketMine/PocketMine-MP/master/start-php5.sh" > start-php5.sh
    fi
    download_file "https://getpm.reh.tw/PocketMine/php-build-scripts/master/compile.sh" > compile.sh
    download_file "https://getpm.reh.tw/PocketMine/start.sh" > start.sh
fi

chmod +x compile.sh
chmod +x start-php7.sh
chmod +x start-php5.sh
chmod +x start.sh

printf "\33[0;92m"
echo " 完成！"
printf "\33[0m"

if [ "$ENABLE_GPG" == "yes" ]; then
    download_file "$GPG_SIGNATURE" > "$NAME.phar.sig"
    check_signature "$NAME.phar"
fi

wget -q -O - https://getpm.reh.tw/zh-TW/php7/ | bash
wget -q -O - https://getpm.reh.tw/zh-TW/php5/ | bash
rm compile.sh

echo "[*] =========================================="
echo " "

echo -n "- 此"
printf "\33[0;96m"
echo -n " GetPM"
printf "\33[0m"
echo -n " 系統屬於"
printf "\33[0;92m"
echo -n " Minecraft 資訊工具網"
printf "\33[0m"
echo -n " 旗下系統，由"
printf "\33[0;93m"
echo -n " 旋風之音 (GoneTone)"
printf "\33[0m"
echo -n " (和其他朋友)編寫開發。"
echo " "

echo -n "- 此"
printf "\33[0;96m"
echo -n " GetPM"
printf "\33[0m"
echo -n " 系統是開源的，放置在"
printf "\33[0;92m"
echo -n " GitHub"
printf "\33[0m"
echo " 歡迎您一起幫助我們開發！"
echo -n "GitHub: "
printf "\33[0;92m"
echo "https://github.com/MCNewsTools/getpm.mcpe.tw-source"
printf "\33[0m"
echo " "

printf "\33[0;93m"
echo ">>> 旋風之音 (GoneTone) <<<"
printf "\33[0m"
echo -n "Facebook:"
printf "\33[0;92m"
echo " https://www.facebook.com/TPGoneTone"
printf "\33[0m"
echo -n "Twitter:"
printf "\33[0;92m"
echo " https://twitter.com/TPGoneTone"
printf "\33[0m"
echo " "

printf "\33[0;93m"
echo ">>> Minecraft 資訊工具網 <<<"
printf "\33[0m"
echo -n "網站:"
printf "\33[0;92m"
echo " https://mc.reh.tw"
printf "\33[0m"
echo -n "Facebook:"
printf "\33[0;92m"
echo " https://www.facebook.com/MCNewsTools"
printf "\33[0m"
echo -n "Twitter:"
printf "\33[0;92m"
echo " https://twitter.com/MCNewsTools"
printf "\33[0m"
echo " "

echo "[*] =========================================="
echo "[*] 完成！"

echo -n "[*]"
printf "\33[0;92m"
echo -n " PHP7"
printf "\33[0m"
echo -n " 輸入"
printf "\33[0;93m"
echo " ./start-php7.sh"
printf "\33[0m"

echo -n "[*]"
printf "\33[0;92m"
echo -n " PHP5"
printf "\33[0m"
echo -n " 輸入"
printf "\33[0;93m"
echo " ./start-php5.sh"
printf "\33[0m"

echo -n "[*] 以運行"
printf "\33[0;96m"
echo " $NAME"
printf "\33[0m"
exit 0