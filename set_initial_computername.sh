#!/bin/zsh

# Get currently logged in user
loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# Only proceed if _mbsetupuser is logged in (used by Apple for setup screens)
if [[ ! $loggedInUser = "_mbsetupuser" ]]; then
  echo "Logged in user is not _mbsetupuser. Exiting..."
  exit 0
fi

# Get serial number
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

# Set name to serial number (in case name is not set by user)
scutil --set ComputerName "$serialNumber"
sleep 1
scutil --set LocalHostName "$serialNumber"
sleep 1
scutil --set HostName "$serialNumber"
sleep 1

# Get the logged in UID
loggedInUID=$(id -u $loggedInUser)

# Prompt for Computer Name as the user
/bin/launchctl asuser "${loggedInUID}" sudo -iu "${loggedInUser}" whoami
computerName=$(/bin/launchctl asuser "${loggedInUID}" sudo -iu "${loggedInUser}" /usr/bin/osascript<<EOF
set answer to text returned of (display dialog "Set Computer Name" with title "UC Davis ISG" default answer "$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')" giving up after 900)
EOF
)

# Check to make sure $computerName is set
if [[ -z $computerName ]]; then
  echo "Computer Name not set. Exiting..."
  exit 0
fi

# Set name using variable created above
scutil --set ComputerName "$computerName"
sleep 1
scutil --set LocalHostName "$computerName"
sleep 1

echo "Computer Name set to $computerName"
name_length=${#computerName}
echo $name_length
if [[ $name_length -gt 15 ]]; then
    # Remove the second hyphen
    echo "The host name is longer than 15 characters, so we are truncating it for AD binding purposes"
    shortenedComputerName=`echo $computerName | sed 's/-\([0-9]\)/\1/'`
    echo "Modified host name: $shortenedComputerName"
    scutil --set HostName "$shortenedComputerName"
    sleep 1
else
    scutil --set HostName "$computerName"
    sleep 1
fi

# Confirm Computer Name
/bin/launchctl asuser "${loggedInUID}" sudo -iu "${loggedInUser}" /usr/bin/osascript<<EOF
display dialog "Computer Name set to " & host name of (system info) buttons {"OK"} default button 1 with title "UC Davis ISG" giving up after 5
EOF
sudo jamf recon
