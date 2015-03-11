#!/bin/bash

# Diverse Wartungslaeufe und Pruefungen
# Zum Aufruf als root per cron

PFAD="/install/skripte"

$PFAD/mirror_check.sh
   if [ "`echo $?`" -ne "0" ]; then
      echo "Die Spiegelfestplatte muss dringend geprueft werden." | mail -s "WARNUNG: Festplattenfehler!" david@localhost
   else
      echo "Die Spiegelfetplatte ist korrekt eingebunden." | mail -s "Festplattenspiegelung okay :-)" david@localhost
   fi

$PFAD/nxclean.sh
$PFAD/deloldSP.sh
export DAV_HOME=/home/david && $PFAD/dp_cleaner.sh
#$PFAD/rkcheck.sh

exit 0
