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
		echo "error, curl or wget not found"
	fi
fi

download_file "http://getpm.reh.tw/PocketMine/php-build-scripts/master/compile.sh" > compile.sh
chmod +x compile.sh

if [ "$update" == "on" ]; then
	echo "[4/4] Skipping PHP recompilation due to user request"
else
	echo -n "[4/4] Obtaining PHP7:"
	echo " detecting if build is available..."
	if [ "$forcecompile" == "off" ] && [ "$(uname -s)" == "Darwin" ]; then
		set +e
		UNAME_M=$(uname -m)
		IS_IOS=$(expr match $UNAME_M 'iP[a-zA-Z0-9,]*' 2> /dev/null)
		set -e
		if [[ "$IS_IOS" -gt 0 ]]; then
			rm -r -f bin/php7/ >> /dev/null 2>&1
			echo -n "[4/4] iOS PHP build available, downloading $IOS_BUILD.tar.gz..."
			download_file "http://getpm.reh.tw/PocketMine/PHP/$IOS_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " checking..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " regenerating php.ini..."
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
				echo " invalid build detected"
			fi
		else
			rm -r -f bin/php7/ >> /dev/null 2>&1
			if [ `getconf LONG_BIT` == "64" ]; then
				echo -n "[4/4] MacOS 64-bit PHP build available, downloading $MAC_64_BUILD.tar.gz..."
				MAC_BUILD="$MAC_64_BUILD"
			else
				echo -n "[4/4] MacOS 32-bit PHP build available, downloading $MAC_32_BUILD.tar.gz..."
				MAC_BUILD="$MAC_32_BUILD"
			fi
			download_file "http://getpm.reh.tw/PocketMine/PHP/$MAC_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " checking..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " regenerating php.ini..."
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
				echo " invalid build detected"
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
			echo -n "[4/4] Raspberry Pi PHP build available, downloading $RPI_BUILD.tar.gz..."
			download_file "http://getpm.reh.tw/PocketMine/PHP/$RPI_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " checking..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " regenerating php.ini..."
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
				echo " invalid build detected"
			fi
		elif [ "$IS_ODROID" -eq 0 ] && [ "$forcecompile" == "off" ]; then
			rm -r -f bin/php7/ >> /dev/null 2>&1
			echo -n "[4/4] ODROID PHP build available, downloading $ODROID_BUILD.tar.gz..."
			download_file "http://getpm.reh.tw/PocketMine/PHP/$ODROID_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " checking..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " regenerating php.ini..."
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
				echo " invalid build detected"
			fi
		elif [ "$forcecompile" == "off" ] && [ "$(uname -s)" == "Linux" ]; then
			rm -r -f bin/php7/ >> /dev/null 2>&1
			
			if [[ "$(cat /etc/redhat-release 2>/dev/null)" == *CentOS* ]]; then
				if [ `getconf LONG_BIT` = "64" ]; then
					echo -n "[4/4] CentOS 64-bit PHP build available, downloading $CENTOS_64_BUILD.tar.gz..."
					LINUX_BUILD="$CENTOS_64_BUILD"
				else
					echo -n "[4/4] CentOS 32-bit PHP build available, downloading $CENTOS_32_BUILD.tar.gz..."
					LINUX_BUILD="$CENTOS_32_BUILD"
				fi
			else
				if [ `getconf LONG_BIT` = "64" ]; then
					echo -n "[4/4] Linux 64-bit PHP build available, downloading $LINUX_64_BUILD.tar.gz..."
					LINUX_BUILD="$LINUX_64_BUILD"
				else
					echo -n "[4/4] Linux 32-bit PHP build available, downloading $LINUX_32_BUILD.tar.gz..."
					LINUX_BUILD="$LINUX_32_BUILD"
				fi
			fi
			
			download_file "http://getpm.reh.tw/PocketMine/PHP/$LINUX_BUILD.tar.gz" | tar -zx > /dev/null 2>&1
			chmod +x ./bin/php7/bin/*
			echo -n " checking..."
			if [ "$(./bin/php7/bin/php -r 'echo 1;' 2>/dev/null)" == "1" ]; then
				echo -n " regenerating php.ini..."
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
				echo " invalid build detected, please upgrade your OS"
			fi
		fi
		if [ "$alldone" == "no" ]; then
			set -e
			echo "[4/4] no build found, compiling PHP automatically"
			exec "./compile.sh"
		fi
	fi
fi

rm compile.sh

echo "[*] PHP7 Download done！"
exit 0