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
	  echo "[+] Enabling xdebug"
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
      echo "Invalid option: -$OPTARG" >&2
	  exit 1
      ;;
  esac
done

rm select-core.sh

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
		echo "error, curl or wget not found"
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
PUBLICKEY_URL="http://getpm.mcpe.tw/pocketmine.asc"
PUBLICKEY_FINGERPRINT="20D377AFC3F7535B3261AA4DCF48E7E52280B75B"
PUBLICKEY_LONGID="${PUBLICKEY_FINGERPRINT: -16}"
GPG_KEYSERVER="pgp.mit.edu"

function check_signature {
	echo "[*] Checking signature of $1"
	"$GPG_BIN" --keyserver "$GPG_KEYSERVER" --keyserver-options auto-key-retrieve=1 --trusted-key $PUBLICKEY_LONGID --verify "$1.sig" "$1"
	if [ $? -eq 0 ]; then
		echo "[+] Signature valid and checked!"
	else
		"$GPG_BIN" --refresh-keys > /dev/null 2>&1
		echo "[!] Invalid signature! Please check for file corruption or a wrongly imported public key (signed by $PUBLICKEY_FINGERPRINT)"
		exit 1
	fi	
}

VERSION_DATA=$(download_file "http://getpm.mcpe.tw/api/channel/$CHANNEL")

VERSION=$(echo "$VERSION_DATA" | grep '"version"' | cut -d ':' -f2- | tr -d ' ",')
BUILD=$(echo "$VERSION_DATA" | grep build | cut -d ':' -f2- | tr -d ' ",')
API_VERSION=$(echo "$VERSION_DATA" | grep api_version | cut -d ':' -f2- | tr -d ' ",')
VERSION_DATE=$(echo "$VERSION_DATA" | grep '"date"' | cut -d ':' -f2- | tr -d ' ",')
VERSION_DOWNLOAD=$(echo "$VERSION_DATA" | grep '"download_url"' | cut -d ':' -f2- | tr -d ' ",')
VERSION_DETAILS=$(echo "$VERSION_DATA" | grep '"details_url"' | cut -d ':' -f2- | tr -d ' ",')

if [ "$alternateurl" == "on" ]; then
    VERSION_DOWNLOAD=$(echo "$VERSION_DATA" | grep '"alternate_download_url"' | cut -d ':' -f2- | tr -d ' ",')
fi

if [ "$(uname -s)" == "Darwin" ]; then
	BASE_VERSION=$(echo "$VERSION" | sed -E 's/([A-Za-z0-9_\.]*).*/\1/')
else
	BASE_VERSION=$(echo "$VERSION" | sed -r 's/([A-Za-z0-9_\.]*).*/\1/')
fi

GPG_SIGNATURE=$(echo "$VERSION_DATA" | grep '"signature_url"' | cut -d ':' -f2- | tr -d ' ",')

if [ "$GPG_SIGNATURE" != "" ]; then
	ENABLE_GPG="yes"
fi

if [ "$VERSION" == "" ]; then
	printf "\33[0;91m"
	echo -n "[!] Couldn't get the latest"
	printf "\33[0;96m"
	echo -n " $NAME"
	printf "\33[0m"
	printf "\33[0;91m"
	echo " version"
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

echo -n "[*] Found"
printf "\33[0;96m"
echo -n " $NAME"
printf "\33[0m"
printf "\33[0;93m"
echo -n " $BASE_VERSION"
printf "\33[0m"
echo -n " (build"
printf "\33[0;92m"
echo -n " $BUILD"
printf "\33[0m"
echo -n ") using API"
printf "\33[0;91m"
echo " $API_VERSION"
printf "\33[0m"

echo -n "[*] This"
printf "\33[0;96m"
echo -n " $CHANNEL"
printf "\33[0m"
echo -n " build was released on"
printf "\33[0;92m"
echo " $VERSION_DATE"
printf "\33[0m"

echo -n "[*] Details:"
printf "\33[0;92m"
echo " $VERSION_DETAILS"
printf "\33[0m"

if [ "$ENABLE_GPG" == "yes" ]; then
	echo "[+] The build was signed, will check signature"
elif [ "$GPG_SIGNATURE" == "" ]; then
	if [[ "$CHANNEL" == "beta" ]] || [[ "$CHANNEL" == "stable" ]]; then
		echo "[-] This channel should have a signature, none found"
	fi
fi

echo -n "[*] Installing/updating"
printf "\33[0;96m"
echo -n " $NAME"
printf "\33[0m"
echo -n " on directory"
printf "\33[0;92m"
echo " $INSTALL_DIRECTORY"
printf "\33[0m"
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
echo " Cleaning..."
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
echo -n " Downloading"
printf "\33[0;96m"
echo -n " $NAME"
printf "\33[0m"
printf "\33[0;93m"
echo -n " $VERSION"
printf "\33[0m"
echo -n " phar..."
set +e
download_file "$VERSION_DOWNLOAD" > "$NAME.phar"
if ! [ -s "$NAME.phar" ] || [ "$(head -n 1 $NAME.phar)" == '<!DOCTYPE html>' ]; then
	rm "$NAME.phar" 2> /dev/null
	printf "\33[0;91m"
	echo " failed！"
	printf "\33[0m"
	echo -n "[!] Couldn't download"
	printf "\33[0;96m"
	echo -n " $NAME"
	printf "\33[0m"
	echo -n " automatically from"
	printf "\33[0;93m"
	echo " $VERSION_DOWNLOAD"
	printf "\33[0m"
	exit 1
else
	if [ "$CHANNEL" == "PocketMine-MP" ]; then
		download_file "http://getpm.mcpe.tw/PocketMine/PocketMine-MP/master/start-php7.sh" > start-php7.sh
		download_file "http://getpm.mcpe.tw/PocketMine/PocketMine-MP/master/start-php5.sh" > start-php5.sh
		download_file "http://getpm.mcpe.tw/PocketMine/PocketMine-MP/master/LICENSE" > LICENSE
		download_file "http://getpm.mcpe.tw/PocketMine/PocketMine-MP/master/README.md" > README.md
		download_file "http://getpm.mcpe.tw/PocketMine/PocketMine-MP/master/CONTRIBUTING.md" > CONTRIBUTING.md
	elif [ "$CHANNEL" == "Genisys" ]; then
		download_file "http://getpm.mcpe.tw/PocketMine/Genisys/master/resources/start-php7.sh" > start-php7.sh
		download_file "http://getpm.mcpe.tw/PocketMine/Genisys/master/resources/start-php5.sh" > start-php5.sh
		download_file "http://getpm.mcpe.tw/PocketMine/Genisys/master/resources/LICENSE" > LICENSE
		download_file "http://getpm.mcpe.tw/PocketMine/Genisys/master/resources/README.md" > README.md
		download_file "http://getpm.mcpe.tw/PocketMine/Genisys/master/resources/CONTRIBUTING.md" > CONTRIBUTING.md
	elif [ "$CHANNEL" == "ClearSky" ]; then
		download_file "http://getpm.mcpe.tw/PocketMine/ClearSky/master/resources/start-php7.sh" > start-php7.sh
		download_file "http://getpm.mcpe.tw/PocketMine/ClearSky/master/resources/start-php5.sh" > start-php5.sh
		download_file "http://getpm.mcpe.tw/PocketMine/ClearSky/master/resources/LICENSE" > LICENSE
		download_file "http://getpm.mcpe.tw/PocketMine/ClearSky/master/resources/README.md" > README.md
	else
		download_file "http://getpm.mcpe.tw/PocketMine/PocketMine-MP/master/start-php7.sh" > start-php7.sh
		download_file "http://getpm.mcpe.tw/PocketMine/PocketMine-MP/master/start-php5.sh" > start-php5.sh
	fi
	download_file "http://getpm.mcpe.tw/PocketMine/php-build-scripts/master/compile.sh" > compile.sh
	download_file "http://getpm.mcpe.tw/PocketMine/start.sh" > start.sh
fi

chmod +x compile.sh
chmod +x start-php7.sh
chmod +x start-php5.sh
chmod +x start.sh

printf "\33[0;92m"
echo " done!"
printf "\33[0m"

if [ "$ENABLE_GPG" == "yes" ]; then
	download_file "$GPG_SIGNATURE" > "$NAME.phar.sig"
	check_signature "$NAME.phar"
fi

wget -q -O - http://getpm.mcpe.tw/lang/en/getpm/php7/ | bash
wget -q -O - http://getpm.mcpe.tw/lang/en/getpm/php5/ | bash
rm compile.sh

echo "[*] =========================================="
echo " "

echo -n "- This"
printf "\33[0;96m"
echo -n " GetPM"
printf "\33[0m"
echo -n " system is"
printf "\33[0;92m"
echo -n " MCPE.TW"
printf "\33[0m"
echo -n " Its system, by"
printf "\33[0;93m"
echo -n " 旋風之音 (GoneTone)"
printf "\33[0m"
echo -n " (and other friends) development，And hosted"
printf "\33[0;93m"
echo -n " Sciuridae"
printf "\33[0m"
echo " hosts."
echo " "

echo -n "- This"
printf "\33[0;96m"
echo -n " GetPM"
printf "\33[0m"
echo -n " system is open source, placed in"
printf "\33[0;92m"
echo -n " GitHub"
printf "\33[0m"
echo " Welcome you to help us to develop!"
echo -n "GitHub: "
printf "\33[0;92m"
echo "https://github.com/TechPlayerTeam/getpm.mcpe.tw-source"
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
echo -n "TechPlayer Official website:"
printf "\33[0;92m"
echo " https://www.techplayer.org"
printf "\33[0m"
echo " "

printf "\33[0;93m"
echo ">>> Minecraft PE Taiwan Chinese Forum <<<"
printf "\33[0m"
echo -n "website:"
printf "\33[0;92m"
echo " https://mcpe.tw"
printf "\33[0m"
echo -n "Facebook:"
printf "\33[0;92m"
echo " https://www.facebook.com/mcpe.tw/"
printf "\33[0m"
echo -n "Twitter:"
printf "\33[0;92m"
echo " https://twitter.com/mcpe_tw"
printf "\33[0m"
echo " "

echo "[*] =========================================="
echo "[*] Everything done!"

echo -n "[*]"
printf "\33[0;92m"
echo -n " PHP7"
printf "\33[0m"
echo -n " Run"
printf "\33[0;93m"
echo " ./start-php7.sh"
printf "\33[0m"

echo -n "[*]"
printf "\33[0;92m"
echo -n " PHP5"
printf "\33[0m"
echo -n " Run"
printf "\33[0;93m"
echo " ./start-php5.sh"
printf "\33[0m"

echo -n "[*] to start"
printf "\33[0;96m"
echo " $NAME"
printf "\33[0m"
exit 0
