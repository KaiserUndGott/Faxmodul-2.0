#!/bin/bash



# Pruefung auf Rootkits
# Muss als root laufen.
#
# Speedpoint nG (FW), Stand: Oktober 2013



# Hier bitte anpassen: ---------------------------------------
#
USER="david@localhost"
VSCAN="/home/david/trpword" 
#
# ------------------------------------------------------------






# Pruefungen auf Rootrechte:
#
if [ ! "`id -u`" -eq "0" ]; then
   echo "Sorry, nur fuer root ausfuehrbar."
   exit 1
fi

# ------------------------------------------------------------


# Virensuche

LOG=`mktemp /tmp/vir.XXXXXXXXXX` || exit 1

echo ""
echo "Virenscan von `date`: Suche in $VSCAN." | tee -a $LOG
echo "" >>$LOG
echo "Virenschutzdaten werden aktualisiert." | tee -a $LOG
freshclam 2>&1 >>$LOG
echo "" >>$LOG
clamscan --log=$LOG --bell --infected $VSCAN

if [ `cat $LOG | grep "Infected" | awk '{print $3}'` -ne 0 ]; then
   echo "*****************************************************************************"
   echo "*****************************************************************************"
   echo "Virenfund in $VSCAN, bitte dringend Speedpoint anrufen!"
   echo "*****************************************************************************"
   echo "*****************************************************************************"
   cat $LOG | mail -s "Virenalarm!" $USER
else
   echo "Keine Viren gefunden."
   cat $LOG | mail -s "Virenpruefung ok :-)" $USER
fi

echo "Ende. Details siehe Mail an $USER."
echo ""
rm $LOG

exit 0
