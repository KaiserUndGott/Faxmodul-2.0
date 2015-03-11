#!/bin/bash


# Skript durchsucht im Homeverzeichnis der lokalen User die Maildir
# Verzeichnisse nach gelesenen bzw. geloeschten Mails, welche ein
# eingestelltes Hoechstalter ueberschritten haben und verschiebt
# diese in jeweils ein TAR pro User.
#
# Skript bitte in die crontab von root eintragen.
#
# Speedpoint nG (FW), Stand: Maerz 2015



# Bitte konfigurieren: ----------------------------------------------

# Maximales Alter der Mails in Tagen:
AGE=30

# Mail Empfaenger des Protokolls:
USER=david@localhost

# Ende der Konfiguration --------------------------------------------




# Ab hier Finger weg!




# Duerfen wir das alles?
if [ "$(id -u)" != "0" ]; then
	echo "ABBRUCH, Ausfuehrung nur durch root!"
	echo ""
	exit 1
fi

LOG=`mktemp /tmp/mailclean.XXXXXXXXXX`

# root Mails archivieren (ueber 90 Tage alt):
find /root/.Maildir -type f -name '*,S*' -ctime +90 -print0 | xargs -0 --no-run-if-empty \
     tar -rvf /root/Mailarchiv.tar --remove-files | tee -a $LOG
ERROR=$(echo $?)
[ "${ERROR}" = "0" ] || echo "Beim Archivieren der Mails von root ist ein Fehler aufgetreten." | tee -a $LOG

# User Mails archivieren:
for i in `ls -la /home | grep users | awk '{print $NF}'`; do
	find /home/$i/.Maildir -type f -name '*,S*' -ctime +$AGE -print0 | xargs -0 --no-run-if-empty \
	     tar -rvf /home/$i/Mailarchiv.tar --remove-files | tee -a $LOG
	#
	ERROR=$(echo $?)
	[ "${ERROR}" = "0" ] || echo "Beim Archivieren der Mails des Users '$i' ist ein Fehler aufgetreten." | tee -a $LOG
done

JETZT=`date`
echo "Postfach Bereinigung abgeschlosen ($JETZT). Archivierte Mails liegen ggf. in ~/Mailarchiv.tar." | tee -a $LOG
[ -s $LOG ] && cat $LOG |mail -s "Automatische Mail Archivierung" $USER
rm -f $LOG
echo ""
exit 0
