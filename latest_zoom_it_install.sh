#!/bin/sh
####################################################################################################
# Script to download and install Zoom.


# Set preferences - set to anything besides "true" to disable
hdvideo="true"
ssodefault="true"
ssohost="ucdavis-shcs.zoom.us"


# choose language (en-US, fr, de)
lang=""
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 1 AND, IF SO, ASSIGN TO "lang"
if [ "$4" != "" ] && [ "$lang" == "" ]; then
        lang=$4
else 
        lang="en-US"
fi

pkgfile="ZoomInstallerIT.pkg"
plistfile="us.zoom.config.plist"
logfile="/Library/Logs/ZoomInstallScript.log"
url="https://zoom.us/client/latest/ZoomInstallerIT.pkg"

# Construct the plist file for preferences
echo "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>nogoogle</key>
        <string>1</string>
        <key>nofacebook</key>
        <string>1</string>
        <key>ZDisableVideo</key>
        <true/>
        <key>ZAutoJoinVoip</key>
        <true/>
        <key>ZDualMonitorOn</key>
        <true/>" >> /tmp/${plistfile}

if [ "${ssohost}" != "" ]; then
echo "
<key>ZAutoSSOLogin</key>
<true/>
<key>ZSSOHost</key>
<string>$ssohost</string>" >> /tmp/${plistfile}
fi
echo "<key>ZAutoFullScreenWhenViewShare</key>
<true/>
<key>ZAutoFitWhenViewShare</key>
<true/>" >> /tmp/${plistfile}

if [ "${hdvideo}" == "true" ]; then
echo "<key>ZUse720PByDefault</key>
<true/>" >> /tmp/${plistfile}
else
echo "<key>ZUse720PByDefault</key>
<false/>" >> /tmp/${plistfile}
fi

echo "<key>ZRemoteControlAllApp</key>
<true/>
</dict>
</plist>" >> /tmp/${plistfile}
                # Download and install new version

/usr/bin/curl -L -o /tmp/${pkgfile} ${url}
/bin/echo "`date`: Installing PKG..." >> ${logfile}
/usr/sbin/installer -allowUntrusted -pkg /tmp/${pkgfile} -target /

/bin/sleep 10
/bin/echo "`date`: Deleting downloaded PKG." >> ${logfile}
/bin/rm /tmp/${pkgfile}


/bin/echo "`date`: Zoom is already up to date, running ${currentinstalledver}." >> ${logfile}
/bin/echo "--" >> ${logfile}
    
exit 0
