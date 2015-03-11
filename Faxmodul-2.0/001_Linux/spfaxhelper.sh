#!/bin/bash


# Liefert die Terminalkennung derjenigen lokalen DATA VITAL Instanz,
# welche zuletzt einen Patienten aufgerufen hat.
#
# Bestandteil des Speedpoint Faxmoduls
#
# Speedpoint GmbH (FW), Stand: Juli 2014, Verion 1


HELPFILE="$HOME/.faxhelper.txt"

 echo "DAV_ID: $DAV_ID" >$HELPFILE
 echo "Pat.nr: $1"     >>$HELPFILE
 echo "Wert-2: $2"     >>$HELPFILE
 echo "LockID: $3"     >>$HELPFILE
 echo "Wert-4: $2"     >>$HELPFILE
 echo "Wert-5: $2"     >>$HELPFILE
 echo "Wert-6: $2"     >>$HELPFILE

chmod 666 $HELPFILE

exit
