#!/bin/bash



# Pruefung auf Rootkits
# Muss als root laufen.
#
# Speedpoint nG (FW), Stand: Oktober 2013



# Hier bitte anpassen: ---------------------------------------
#
USER="david@localhost"
TOOL="/install/skripte/notify.sh" 
#
# ------------------------------------------------------------









# Pruefungen auf Rootrechte:
#
if [ ! "`id -u`" -eq "0" ]; then
   echo "Sorry, nur fuer root ausfuehrbar."
   exit 1
fi

# ------------------------------------------------------------




# Rootkit Suche

LOG=`mktemp /tmp/rk.XXXXXXXXXX` || exit 1

WARN=0
INFECT=0
MESSAGE="Keine Rootkits gefunden."

echo "Rootkit Suche von `date`" >$LOG
echo "" >>$LOG
chkrootkit 2>&1 >>$LOG
echo "" >>$LOG

INFECT=`grep "INFECTED" <$LOG`
WARN=`grep "WARNING" <$LOG`
if [ -z "$INFECT" -o -z "$WARN" ]; then
   echo $MESSAGE
   echo ""
   echo $MESSAGE | mail -s "Rootkit Suche ok :-)" $USER
else
   MAILFILE="/tmp/rk-mailfile.tmp"
   MESSAGE="ACHTUNG, Rootkitbefall entdeckt!"
   echo $MESSAGE
   echo ""
   echo $INFECT >$MAILFILE
   echo "----------------------" >>$MAILFILE
   echo $WARN >>$MAILFILE
   echo "Fuer Details bitte beachten." $MAILFILE | mail -s "Rootkit Alarm!" -a $MAILFILE $USER
   $TOOL -m "Rootkit Alarm!"
   rm -f $MAILFILE
fi
rm -f $LOG

exit 0
