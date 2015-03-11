#!/bin/bash


# Script loescht alte Druckauftraege aus dem DV Spooler.
# Zur Verwendung durch root z.B. mit cron.
#
# Speedpoint nG (FW), Stand: Dezember 2012


alter=2                   # max. Alter der Druckjobs in Tagen


# -----------------------------------------------------------








# Duerfen wir das hier alles?
if [ ! "`id -u`" = "0" ]; then
   clear
   echo "**********************************************"
   echo "***   ABBRUCH - Rootrechte erforderlich    ***"
   echo "**********************************************"
   echo
   exit 1
fi

echo ""
echo "veraltete Druckjobs suchen..."
find /home/david/spool.hist -name '*.SP' -atime +$alter -print0 | xargs -0 --no-run-if-empty rm -f
echo "Druckjobs mit Alter >$alter Tage wurden entfernt."

exit 0
