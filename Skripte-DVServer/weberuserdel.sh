#!/bin/bash

# Loeschen von DV Usern namens platzXY, erfordert Rootrechte

# Duerfen wir das hier alles?
if [ ! "`id -u`" = "0" ]; then
   clear
   echo "**********************************************"
   echo "***   ABBRUCH - Rootrechte erforderlich    ***"
   echo "**********************************************"
   echo
   exit 1
fi

# Los
userliste=`cat /etc/passwd | grep platz | awk -F: '{print $1}'`
echo ""
echo "ACHTUNG!"
echo "========"
echo ""
echo "Folgende User werden _INKLUSIVE HOMEVERZEICHNIS_ geloescht:"
echo $userliste
echo ""
echo "CTRL-C fuer Abbruch, bel. Taste fuer weiter..."
read dummy

for i in $userliste; do
   echo "$i wird geloescht..."
   userdel -rf $i 2>/dev/null
done

echo ""
echo "Fertig."
echo ""
exit 0
