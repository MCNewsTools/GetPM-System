#!/bin/bash

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

echo "Downloading select-lang.sh..."
download_file "http://getpm.reh.tw/select-lang.sh" > select-lang.sh
chmod +x select-lang.sh

printf "\33[0;91m"
echo -n "[*] Done! Run"
printf "\33[0m"
printf "\33[0;92m"
echo " ./select-lang.sh"
printf "\33[0m"