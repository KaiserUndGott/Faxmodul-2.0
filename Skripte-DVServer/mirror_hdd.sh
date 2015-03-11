#!/bin/bash


# lokale Spiegelung des Systems auf zweite HDD mit rsync.
# Rootrechte erforderlich, Ziel-HDD muss eingehaengt sein.
# Zur Vervendung mit cron.
#
# Speedpoint (FW), Stand: Dezember 2014


# Variablen, bitte anpassen -----------------------------------------
#
part1=sdb1                    # Partition / auf der Mirror-Disk
part2=sdb2                    # Partition /home auf der Mirror-Disk
ziel1=/mnt/mirror_root        # Mountpoint 1 (/ der Spiegelplatte)
ziel2=/mnt/mirror_home        # Mountpoint 2 (/home der Spiegelplatte)
#
mtest=/install/skripte/mirror_check.sh  # Skript z. Test d. SpiegelHDD
#
user=david                    # Empfaenger der Statusmails
#
# -------------------------------------------------------------------








# Los









# Duerfen wir das hier alles?
if [ ! "`id -u`" = "0" ]; then
   echo ""
   echo "ABBRUCH, Rootrechte erforderlich!"
   echo ""
   exit 1
fi


# User vorhanden?
[ -e "`cat /etc/passwd | fgrep $user`" ] && echo "ABBRUCH, $user existiert nicht." && exit 1


# Log anlegen und Sync starten
log=`mktemp mirror.XXXXXXXX`
echo "----- Start `date +%d.%m.%Y\ \-\ \%R\ \%Z`" >>$log


$mtest 
if [ $? -ne 0 ]; then 
   echo "Festplattenspiegelung nicht möglich, bitte Speedpoint anrufen!." | mail -s "Fehler bei der Festplattenspiegelung!" $user@localhost
   exit 1
fi

# ISAM beenden
echo "ISAM Dienst beenden..."
hier=`pwd`
cd /home/david
./iquit >/dev/null 2>&1 || echo "Fehler beim Beenden des ISAM Dienstes."


# Sync starten

# Rootpartition:
echo "$ziel1 wird synchronisiert..."
rsync -aH --delete --one-file-system --force \
			--exclude=/mnt       \
			--exclude=/proc      \
			--exclude=/sys       \
			--exclude=/dev       \
			--exclude=/home / $ziel1/ 2>>$log
status1=`echo $?`
jetzt=`date +%a_%d_%b_%Y_%Hh%M` && touch $ziel1/sync_$jetzt
#
# Homepartition
echo "$ziel2 wird synchronisiert..."
rsync -aH --delete --one-file-system --force /home/ $ziel2/ 2>>$log
status2=`echo $?`
jetzt=`date +%a_%d_%b_%Y_%Hh%M` && touch $ziel2/sync_$jetzt

# Status berichten
jetzt=`date +%d.%m.%Y_%R-%Z`
echo "----------------------------------------------------------------------" >>$log
echo "Ende: $jetzt" >>$log
if [ $status1 = "0" -a $status2 = "0" ]; then
   echo "Plattenspiegelung erfolgreich abgeschlossen." | tee -a $log
   tail -n2 $log | mail -s "Festplattenspiegelung ok :-)" $user
else
   cp $log /tmp/Spiegelung.txt
   echo "Bitte Anhang beachten!" | mail -s "ACHTUNG: Fehler bei der Festplattenspiegelung!" -a /tmp/Spiegelung.txt $user@localhost
   rm -f /tmp/Spiegelung.txt
fi


# ISAM starten
cd /home/david
echo -n "ISAM starten..."
./isam >/dev/null 2>&1 && echo "OK"
cd $hier

#echo "Skript Ende."
#echo ""
rm -f $log

exit 0
