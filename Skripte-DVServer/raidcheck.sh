#!/bin/bash

# Check auf Plattenausfall im Software RAID

user="david@localhost"    # Mailempfaenger
tool="/install/skripte/notify.sh"

if [ "`cat /proc/mdstat | grep [UU]`" ]; then
   echo "RAID ok :-)"
   echo ""
   echo "Beide Festplatten im RAID sind online." | mail -s "Festplattenspiegelung okay" $user
else
   echo "RAID Fehler!"
   echo ""
   $tool -m "Festplattenprüfung dringend erforderlich, bitte Speedpoint anrufen!"
   echo "Die Festplatten müssen geprüft werden, bitte umgehend Speedpoint anrufen!" | mail -s "ACHTUNG: Fehler im RAID" $user
fi

exit 0
