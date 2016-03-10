#!/bin/bash

CHANNEL="stable"
NAME="PocketMine-MP"

LINUX_32_BUILD="PHP_7.0.3_x86_Linux"
LINUX_64_BUILD="PHP_7.0.3_x86-64_Linux"
CENTOS_32_BUILD="PHP_7.0.3_x86_CentOS"
CENTOS_64_BUILD="PHP_7.0.3_x86-64_CentOS"
MAC_32_BUILD="PHP_7.0.3_x86_MacOS"
MAC_64_BUILD="PHP_7.0.3_x86-64_MacOS"
RPI_BUILD="PHP_5.6.10_ARM_Raspbian_hard"
# Temporal build
ODROID_BUILD="PHP_5.6.10_ARM_Raspbian_hard"
AND_BUILD="PHP_7.0.0RC3_ARMv7_Android"
IOS_BUILD="PHP_5.5.13_ARMv6_iOS"
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
	  echo "[+] 正在启用 xdebug"
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
      echo "无效选项: -$OPTARG" >&2
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
		echo "错误，找不到 curl 或是 wget"
	fi
fi

if [ "$CHANNEL" == "soft" ]; then
	NAME="PocketMine-Soft"
fi
if [ "$CHANNEL" == "genisys" ]; then
	NAME="PocketMine-Genisys"
fi

ENABLE_GPG="no"
PUBLICKEY_URL="http://getpm.reh.tw/pocketmine.asc"
PUBLICKEY_FINGERPRINT="20D377AFC3F7535B3261AA4DCF48E7E52280B75B"
PUBLICKEY_LONGID="${PUBLICKEY_FINGERPRINT: -16}"
GPG_KEYSERVER="pgp.mit.edu"

function check_signature {
	echo "[*] Checking signature of $1"
	"$GPG_BIN" --keyserver "$GPG_KEYSERVER" --keyserver-options auto-key-retrieve=1 --trusted-key $PUBLICKEY_LONGID --verify "$1.sig" "$1"
	if [ $? -eq 0 ]; then
		echo "[+] 签署已被检查并确认为有效！"
	else
		"$GPG_BIN" --refresh-keys > /dev/null 2>&1
		echo "[!] 签署无效！请检查是否汇入了错误的密钥或是密钥已经损毁 (由 $PUBLICKEY_FINGERPRINT 签署)"
		exit 1
	fi	
}

VERSION_DATA=$(download_file "http://getpm.reh.tw/api/channel/$CHANNEL")

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
	echo "[!] 无法取得 $NAME 最新的版本"
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

echo "[*] 找到 $NAME $BASE_VERSION - 建构档 $BUILD (API: $API_VERSION)"
echo "[*] 详细资料: $VERSION_DETAILS"

if [ "$ENABLE_GPG" == "yes" ]; then
	echo "[+] 建构档已被签署，即将检查签署是否有效"
elif [ "$GPG_SIGNATURE" == "" ]; then
	if [[ "$CHANNEL" == "beta" ]] || [[ "$CHANNEL" == "stable" ]]; then
		echo "[-] 找不到任何签署资料"
	fi
fi

echo "[*] 正在于路径 $INSTALL_DIRECTORY 为 $NAME 进行安装/更新"
mkdir -m 0777 "$INSTALL_DIRECTORY" 2> /dev/null
cd "$INSTALL_DIRECTORY"
echo "[1/3] 正在清理环境..."
rm -f "$NAME.phar"
rm -f README.md
rm -f CONTRIBUTING.md
rm -f LICENSE
rm -f start.sh
rm -f start.bat

#Old installations
rm -f PocketMine-MP.php
rm -r -f src/

echo -n "[2/3] 正在下载 $NAME $VERSION phar档..."
set +e
download_file "$VERSION_DOWNLOAD" > "$NAME.phar"
if ! [ -s "$NAME.phar" ] || [ "$(head -n 1 $NAME.phar)" == '<!DOCTYPE html>' ]; then
	rm "$NAME.phar" 2> /dev/null
	echo " 失败！"
	echo "[!] 无法从 $VERSION_DOWNLOAD 自动下载 $NAME"
	exit 1
else
	if [ "$CHANNEL" == "soft" ]; then
		download_file "http://getpm.reh.tw/PocketMine/PocketMine-Soft/master/resources/start.sh" > start.sh
	elif [ "$CHANNEL" == "genisys" ]; then
		download_file "http://getpm.reh.tw/PocketMine/PocketMine-Genisys/master/resources/start.sh" > start.sh
	else
		download_file "http://getpm.reh.tw/PocketMine/PocketMine-MP/master/start.sh" > start.sh
	fi
	download_file "http://getpm.reh.tw/PocketMine/PocketMine-MP/master/LICENSE" > LICENSE
	download_file "http://getpm.reh.tw/PocketMine/PocketMine-MP/master/README.md" > README.md
	download_file "http://getpm.reh.tw/PocketMine/PocketMine-MP/master/CONTRIBUTING.md" > CONTRIBUTING.md
	download_file "http://getpm.reh.tw/PocketMine/php-build-scripts/master/compile.sh" > compile.sh
fi

chmod +x compile.sh
chmod +x start.sh

echo " 完成！"

if [ "$ENABLE_GPG" == "yes" ]; then
	download_file "$GPG_SIGNATURE" > "$NAME.phar.sig"
	check_signature "$NAME.phar"
fi

if [ "$update" == "on" ]; then
	echo "[3/3] 按照用户的要求，正在跳过 PHP 重新编译程序"
else
	echo -n "[3/3] 正在获取 PHP:"
	echo " 正在检查是否有可用的建构档..."
	if [ "$forcecompile" == "off" ] && [ "$(uname -s)" == "Darwin" ]; then
		set +e
		UNAME_M=$(uname -m)
		IS_IOS=$(expr match $UNAME_M 'iP[a-zA-Z0-9,]*' 2> /dev/null)
		set -e
		if [[ "$IS_IOS" -gt 0 ]]; then
			rm -r -f bin/ >> /dev/null 2>&1
			echo -n "[3/3] 发现可用的 iOS PHP 建构档，正在下载 $IOS_BUILD.tar.gz..."
			download_file "http://getpm.reh.tw/PocketMine/PHP/$IOS_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在进行检查..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " 正在重新生成 php.ini..."
				TIMEZONE=$(date +%Z)
				echo "" > "./bin/php7/bin/php.ini"
				#UOPZ_PATH="$(find $(pwd) -name uopz.so)"
				#echo "zend_extension=\"$UOPZ_PATH\"" >> "./bin/php7/bin/php.ini"
				echo "date.timezone=$TIMEZONE" >> "./bin/php7/bin/php.ini"
				echo "short_open_tag=0" >> "./bin/php7/bin/php.ini"
				echo "asp_tags=0" >> "./bin/php7/bin/php.ini"
				echo "phar.readonly=0" >> "./bin/php7/bin/php.ini"
				echo "phar.require_hash=1" >> "./bin/php7/bin/php.ini"
				echo " done"
				alldone=yes
			else
				echo " 检测到无效的建构档"
			fi
		else
			rm -r -f bin/ >> /dev/null 2>&1
			if [ `getconf LONG_BIT` == "64" ]; then
				echo -n "[3/3] 发现可用的 MacOS 64位元 PHP 建构档，正在下载 $MAC_64_BUILD.tar.gz..."
				MAC_BUILD="$MAC_64_BUILD"
			else
				echo -n "[3/3] 发现可用的 MacOS 32位元 PHP 建构档，正在下载 $MAC_32_BUILD.tar.gz..."
				MAC_BUILD="$MAC_32_BUILD"
			fi
			download_file "http://getpm.reh.tw/PocketMine/PHP/$MAC_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在进行检查..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " 正在重新生成 php.ini..."
				TIMEZONE=$(date +%Z)
				#OPCACHE_PATH="$(find $(pwd) -name opcache.so)"
				XDEBUG_PATH="$(find $(pwd) -name xdebug.so)"
				echo "" > "./bin/php7/bin/php.ini"
				#UOPZ_PATH="$(find $(pwd) -name uopz.so)"
				#echo "zend_extension=\"$UOPZ_PATH\"" >> "./bin/php7/bin/php.ini"
				#echo "zend_extension=\"$OPCACHE_PATH\"" >> "./bin/php7/bin/php.ini"
				if [ "$XDEBUG" == "on" ]; then
					echo "zend_extension=\"$XDEBUG_PATH\"" >> "./bin/php7/bin/php.ini"
				fi
				echo "opcache.enable=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.enable_cli=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.save_comments=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.load_comments=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.fast_shutdown=0" >> "./bin/php7/bin/php.ini"
				echo "opcache.max_accelerated_files=4096" >> "./bin/php7/bin/php.ini"
				echo "opcache.interned_strings_buffer=8" >> "./bin/php7/bin/php.ini"
				echo "opcache.memory_consumption=128" >> "./bin/php7/bin/php.ini"
				echo "opcache.optimization_level=0xffffffff" >> "./bin/php7/bin/php.ini"
				echo "date.timezone=$TIMEZONE" >> "./bin/php7/bin/php.ini"
				echo "short_open_tag=0" >> "./bin/php7/bin/php.ini"
				echo "asp_tags=0" >> "./bin/php7/bin/php.ini"
				echo "phar.readonly=0" >> "./bin/php7/bin/php.ini"
				echo "phar.require_hash=1" >> "./bin/php7/bin/php.ini"
				echo " done"
				alldone=yes
			else
				echo " 检测到无效的建构档"
			fi
		fi
	else
		grep -q BCM270[89] /proc/cpuinfo > /dev/null 2>&1
		IS_RPI=$?
		grep -q sun7i /proc/cpuinfo > /dev/null 2>&1
		IS_BPI=$?
		grep -q ODROID /proc/cpuinfo > /dev/null 2>&1
		IS_ODROID=$?
		if ([ "$IS_RPI" -eq 0 ] || [ "$IS_BPI" -eq 0 ]) && [ "$forcecompile" == "off" ]; then
			rm -r -f bin/ >> /dev/null 2>&1
			echo -n "[3/3] 发现可用的 Raspberry Pi PHP 建构档，正在下载 $RPI_BUILD.tar.gz..."
			download_file "http://getpm.reh.tw/PocketMine/PHP/$RPI_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在进行检查..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " 正在重新生成 php.ini..."
				TIMEZONE=$(date +%Z)
				#OPCACHE_PATH="$(find $(pwd) -name opcache.so)"
				if [ "$XDEBUG" == "on" ]; then
					echo "zend_extension=\"$XDEBUG_PATH\"" >> "./bin/php7/bin/php.ini"
				fi
				echo "" > "./bin/php7/bin/php.ini"
				#UOPZ_PATH="$(find $(pwd) -name uopz.so)"
				#echo "zend_extension=\"$UOPZ_PATH\"" >> "./bin/php7/bin/php.ini"
				#echo "zend_extension=\"$OPCACHE_PATH\"" >> "./bin/php7/bin/php.ini"
				if [ "$XDEBUG" == "on" ]; then
					echo "zend_extension=\"$XDEBUG_PATH\"" >> "./bin/php7/bin/php.ini"
				fi
				echo "opcache.enable=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.enable_cli=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.save_comments=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.load_comments=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.fast_shutdown=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.max_accelerated_files=4096" >> "./bin/php7/bin/php.ini"
				echo "opcache.interned_strings_buffer=8" >> "./bin/php7/bin/php.ini"
				echo "opcache.memory_consumption=128" >> "./bin/php7/bin/php.ini"
				echo "opcache.optimization_level=0xffffffff" >> "./bin/php7/bin/php.ini"
				echo "date.timezone=$TIMEZONE" >> "./bin/php7/bin/php.ini"
				echo "short_open_tag=0" >> "./bin/php7/bin/php.ini"
				echo "asp_tags=0" >> "./bin/php7/bin/php.ini"
				echo "phar.readonly=0" >> "./bin/php7/bin/php.ini"
				echo "phar.require_hash=1" >> "./bin/php7/bin/php.ini"
				echo " done"
				alldone=yes
			else
				echo " 检测到无效的建构档"
			fi
		elif [ "$IS_ODROID" -eq 0 ] && [ "$forcecompile" == "off" ]; then
			rm -r -f bin/ >> /dev/null 2>&1
			echo -n "[3/3] 发现可用的 ODROID PHP 建构档，正在下载 $ODROID_BUILD.tar.gz..."
			download_file "http://getpm.reh.tw/PocketMine/PHP/$ODROID_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在进行检查..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " 正在重新生成 php.ini..."
				#OPCACHE_PATH="$(find $(pwd) -name opcache.so)"
				XDEBUG_PATH="$(find $(pwd) -name xdebug.so)"
				echo "" > "./bin/php7/bin/php.ini"
				#UOPZ_PATH="$(find $(pwd) -name uopz.so)"
				#echo "zend_extension=\"$UOPZ_PATH\"" >> "./bin/php7/bin/php.ini"
				#echo "zend_extension=\"$OPCACHE_PATH\"" >> "./bin/php7/bin/php.ini"
				if [ "$XDEBUG" == "on" ]; then
					echo "zend_extension=\"$XDEBUG_PATH\"" >> "./bin/php7/bin/php.ini"
				fi
				echo "opcache.enable=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.enable_cli=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.save_comments=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.load_comments=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.fast_shutdown=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.max_accelerated_files=4096" >> "./bin/php7/bin/php.ini"
				echo "opcache.interned_strings_buffer=8" >> "./bin/php7/bin/php.ini"
				echo "opcache.memory_consumption=128" >> "./bin/php7/bin/php.ini"
				echo "opcache.optimization_level=0xffffffff" >> "./bin/php7/bin/php.ini"
				echo "date.timezone=$TIMEZONE" >> "./bin/php7/bin/php.ini"
				echo "short_open_tag=0" >> "./bin/php7/bin/php.ini"
				echo "asp_tags=0" >> "./bin/php7/bin/php.ini"
				echo "phar.readonly=0" >> "./bin/php7/bin/php.ini"
				echo "phar.require_hash=1" >> "./bin/php7/bin/php.ini"
				echo " done"
				alldone=yes
			else
				echo " 检测到无效的建构档"
			fi
		elif [ "$forcecompile" == "off" ] && [ "$(uname -s)" == "Linux" ]; then
			rm -r -f bin/ >> /dev/null 2>&1
			
			if [[ "$(cat /etc/redhat-release 2>/dev/null)" == *CentOS* ]]; then
				if [ `getconf LONG_BIT` = "64" ]; then
					echo -n "[3/3] 发现可用的 CentOS 64位元 PHP 建构档，正在下载 $CENTOS_64_BUILD.tar.gz..."
					LINUX_BUILD="$CENTOS_64_BUILD"
				else
					echo -n "[3/3] 发现可用的 CentOS 32位元 PHP 建构档，正在下载 $CENTOS_32_BUILD.tar.gz..."
					LINUX_BUILD="$CENTOS_32_BUILD"
				fi
			else
				if [ `getconf LONG_BIT` = "64" ]; then
					echo -n "[3/3] 发现可用的 Linux 64位元 PHP 建构档，正在下载 $LINUX_64_BUILD.tar.gz..."
					LINUX_BUILD="$LINUX_64_BUILD"
				else
					echo -n "[3/3] 发现可用的 Linux 32位元 PHP 建构档，正在下载 $LINUX_32_BUILD.tar.gz..."
					LINUX_BUILD="$LINUX_32_BUILD"
				fi
			fi
			
			download_file "http://getpm.reh.tw/PocketMine/PHP/$LINUX_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在进行检查..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " 正在重新生成 php.ini..."
				#OPCACHE_PATH="$(find $(pwd) -name opcache.so)"
				XDEBUG_PATH="$(find $(pwd) -name xdebug.so)"
				echo "" > "./bin/php7/bin/php.ini"
				#UOPZ_PATH="$(find $(pwd) -name uopz.so)"
				#echo "zend_extension=\"$UOPZ_PATH\"" >> "./bin/php7/bin/php.ini"
				#echo "zend_extension=\"$OPCACHE_PATH\"" >> "./bin/php7/bin/php.ini"
				if [ "$XDEBUG" == "on" ]; then
					echo "zend_extension=\"$XDEBUG_PATH\"" >> "./bin/php7/bin/php.ini"
				fi
				echo "opcache.enable=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.enable_cli=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.save_comments=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.fast_shutdown=1" >> "./bin/php7/bin/php.ini"
				echo "opcache.max_accelerated_files=4096" >> "./bin/php7/bin/php.ini"
				echo "opcache.interned_strings_buffer=8" >> "./bin/php7/bin/php.ini"
				echo "opcache.memory_consumption=128" >> "./bin/php7/bin/php.ini"
				echo "opcache.optimization_level=0xffffffff" >> "./bin/php7/bin/php.ini"
				echo "date.timezone=$TIMEZONE" >> "./bin/php7/bin/php.ini"
				echo "short_open_tag=0" >> "./bin/php7/bin/php.ini"
				echo "asp_tags=0" >> "./bin/php7/bin/php.ini"
				echo "phar.readonly=0" >> "./bin/php7/bin/php.ini"
				echo "phar.require_hash=1" >> "./bin/php7/bin/php.ini"
				echo " done"
				alldone=yes
			else
				echo " 检测到无效的建构档，请更新你的作业系统"
			fi
		fi
		if [ "$alldone" == "no" ]; then
			set -e
			echo "[3/3] 找不到可用的建构档，正在自动编译 PHP"
			exec "./compile.sh"
		fi
	fi
fi

rm compile.sh

echo "[*] 完成！输入 ./start.sh 以运行 $NAME"
exit 0
