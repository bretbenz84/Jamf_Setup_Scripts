#!/bin/sh
/usr/bin/sudo /usr/sbin/systemsetup -setcomputersleep Never
/usr/bin/sudo /usr/sbin/systemsetup -setrestartpowerfailure on
/usr/bin/sudo /usr/bin/pmset -a repeat wakeorpoweron weekdays 06:30:00
