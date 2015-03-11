#!/bin/bash


# Liefert die Terminalkennung derjenigen lokalen DATA VITAL Instanz,
# welche zuletzt einen Patienten aufgerufen hat.
#
# Bestandteil des Speedpoint Faxmoduls
#
# Speedpoint (FW), Stand: Juli 2014, Verion 1


TKFILE="/home/david/.faxhelper.txt"

 echo "DAV_ID: $DAV_ID" >$TKFILE
 echo "Pat.nr: $1"     >>$TKFILE
 echo "Wert-2: $2"     >>$TKFILE
 echo "LockID: $3"     >>$TKFILE
 echo "Wert-4: $2"     >>$TKFILE
 echo "Wert-5: $2"     >>$TKFILE
 echo "Wert-6: $2"     >>$TKFILE
#echo "Wert-7: $2"     >>$TKFILE
#echo "Wert-8: $2"     >>$TKFILE
#echo "Wert-9: $2"     >>$TKFILE

chmod 666 $TKFILE

exit
