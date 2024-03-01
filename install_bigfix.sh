#!/bin/bash
#Jamf Variable for Department Code
DEPT="PUTYOURDEPARTMENTHERE"

#Clear parameters
BFI=
FILE=
FOLDER=

#OS Version
osVer=$(sw_vers | grep ProductVersion | awk -F'.' '{print $1}' | awk '{print $2}')

#Delete previous install folder, if it exists
FOLDER=/Library/isg/install/BigFix/
if [ -d "$FOLDER" ]; then 
	sudo rm -r -f $FOLDER/*
fi

#Download latest macOS 11+ client with config files
curl "https://getbigfix.ucdavis.edu/generate_installer.php?reqtype=M&dept=$DEPT" -k -o /tmp/bigfix.zip

#Unzip installer and put .ZIP content in /Library/isg/install/BigFix
sudo mkdir -p /Library/isg/install/BigFix
sudo unzip /tmp/bigfix.zip -d /Library/isg/install/BigFix

#Get BigFix Installation PKG filename
BFI=$(ls /Library/isg/install/BigFix/ | grep -i pkg)

#If statement for OS version installation
if [ "$osVer" == "10" ]; then
	#Delete previous PKG
	sudo rm -f "/Library/isg/install/BigFix/$BFI"
	#Download macOS 10.14-10.15 BesAgent PKG
	curl "https://software.bigfix.com/download/bes/100/BESAgent-10.0.4.32-BigFix_MacOSX10.14.pkg" -k -o /Library/isg/install/BigFix/besinstall.pkg
	BFI=$(ls /Library/isg/install/BigFix/ | grep -i pkg)
	#Install BES Agent for macOS 10.14-10.15
	sudo installer -pkg /Library/isg/install/BigFix/$BFI -target /
else
	#Install BES Agent for macOS 11+
	sudo installer -pkg /Library/isg/install/BigFix/$BFI -target /
fi
