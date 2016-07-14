#!/bin/bash

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
		echo "錯誤，curl 或 wget 未發現"
	fi
fi

if [ "$update" == "on" ]; then
	echo "[3/4] 按照用戶的要求，正在跳過 PHP 重新編譯程序"
else
	echo -n "[3/4] 正在獲取 PHP7:"
	echo " 正在檢查是否有可用的建構檔..."
	if [ "$forcecompile" == "off" ] && [ "$(uname -s)" == "Darwin" ]; then
		set +e
		UNAME_M=$(uname -m)
		IS_IOS=$(expr match $UNAME_M 'iP[a-zA-Z0-9,]*' 2> /dev/null)
		set -e
		if [[ "$IS_IOS" -gt 0 ]]; then
			rm -r -f bin/php7/ >> /dev/null 2>&1
			echo -n "[3/4] 發現可用的 iOS PHP7 建構檔，正在下載 $IOS_BUILD.tar.gz..."
			download_file "http://getpm.mcpe.tw/PocketMine/PHP/$IOS_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在進行檢查..."
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
				echo " 完成"
				alldone=yes
			else
				echo " 檢測到無效的建構檔"
			fi
		else
			rm -r -f bin/php7/ >> /dev/null 2>&1
			if [ `getconf LONG_BIT` == "64" ]; then
				echo -n "[3/4] 發現可用的 MacOS 64位元 PHP7 建構檔，正在下載 $MAC_64_BUILD.tar.gz..."
				MAC_BUILD="$MAC_64_BUILD"
			else
				echo -n "[3/4] 發現可用的 MacOS 32位元 PHP7 建構檔，正在下載 $MAC_32_BUILD.tar.gz..."
				MAC_BUILD="$MAC_32_BUILD"
			fi
			download_file "http://getpm.mcpe.tw/PocketMine/PHP/$MAC_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在進行檢查..."
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
				echo " 完成"
				alldone=yes
			else
				echo " 檢測到無效的建構檔"
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
			rm -r -f bin/php7/ >> /dev/null 2>&1
			echo -n "[3/4] 發現可用的 Raspberry Pi PHP7 建構檔，正在下載 $RPI_BUILD.tar.gz..."
			download_file "http://getpm.mcpe.tw/PocketMine/PHP/$RPI_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在進行檢查..."
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
				echo " 完成"
				alldone=yes
			else
				echo " 檢測到無效的建構檔"
			fi
		elif [ "$IS_ODROID" -eq 0 ] && [ "$forcecompile" == "off" ]; then
			rm -r -f bin/php7/ >> /dev/null 2>&1
			echo -n "[3/4] 發現可用的 ODROID PHP7 建構檔，正在下載 $ODROID_BUILD.tar.gz..."
			download_file "http://getpm.mcpe.tw/PocketMine/PHP/$ODROID_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在進行檢查..."
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
				echo " 完成"
				alldone=yes
			else
				echo " 檢測到無效的建構檔"
			fi
		elif [ "$forcecompile" == "off" ] && [ "$(uname -s)" == "Linux" ]; then
			rm -r -f bin/php7/ >> /dev/null 2>&1
			
			if [[ "$(cat /etc/redhat-release 2>/dev/null)" == *CentOS* ]]; then
				if [ `getconf LONG_BIT` = "64" ]; then
					echo -n "[3/4] 發現可用的 CentOS 64位元 PHP7 建構檔，正在下載 $CENTOS_64_BUILD.tar.gz..."
					LINUX_BUILD="$CENTOS_64_BUILD"
				else
					echo -n "[3/4] 發現可用的 CentOS 32位元 PHP7 建構檔，正在下載 $CENTOS_32_BUILD.tar.gz..."
					LINUX_BUILD="$CENTOS_32_BUILD"
				fi
			else
				if [ `getconf LONG_BIT` = "64" ]; then
					echo -n "[3/4] 發現可用的 Linux 64位元 PHP7 建構檔，正在下載 $LINUX_64_BUILD.tar.gz..."
					LINUX_BUILD="$LINUX_64_BUILD"
				else
					echo -n "[3/4] 發現可用的 Linux 32位元 PHP7 建構檔，正在下載 $LINUX_32_BUILD.tar.gz..."
					LINUX_BUILD="$LINUX_32_BUILD"
				fi
			fi
			
			download_file "http://getpm.mcpe.tw/PocketMine/PHP/$LINUX_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " 正在進行檢查..."
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
				echo " 完成"
				alldone=yes
			else
				echo " 檢測到無效的建構檔，請更新你的作業系統"
			fi
		fi
		if [ "$alldone" == "no" ]; then
			set -e
			echo "[3/4] 找不到可用的建構檔，正在自動編譯 PHP"
			exec "./compile.sh"
		fi
	fi
fi

echo "[*] PHP7下載完成！"
exit 0