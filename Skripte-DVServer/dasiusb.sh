#!/bin/bash
#
# Was alles sichern? Weitere Verzeichnisse bei Bedarf ergaenzen
#
QUELLE="/home/david /etc"
#
# Wohin sichern?
#
MEDIUM=/media/usbplatte
#
# Logfiles zuruecksetzen
#
cd /home/david
>usbsich.log
>usbsich0.log
>usbsich1.log
>usbsich2.log
>usbsich3.log
#
# zu benachrichtigender USER
#
MAIL_AN=david
#
# automatische Datensicherung oder manueller Aufruf aus dem Menu?
#
case $1 in 
  a|A) MODUS=automatische ;;
  *)   MODUS=manuelle ;;
esac
FEHLER="erfolgreich"
echo -e "\nStarte Datensicherung auf USB-Platte am `date "+%d.%m.%y um %H:%M Uhr"` 
========================================================================\n"  >usbsich0.log
echo -e "sichere $QUELLE $MODUS auf USB-Platte: $MEDIUM\n" >>usbsich0.log
[ "$MODUS" == "manuelle" ] && gui/davdialog --title "Datensicherung" --msg "Bitte Wechselplatte anstecken"
echo Bitte warten...
sleep 2
mount $MEDIUM >usbsich1.log 2>&1 && {
  ./iquit
  sleep 2
  sudo rsync -av  $QUELLE $MEDIUM 2>usbsich2.log 
  if [ $? -eq 0 ]
  then
    echo -e "\nBelegung des Sicherungsmediums:\n===============================\n`df -h $MEDIUM`\n" >usbsich3.log
    echo 1 - $FEHLER >>usbsich3.log
    umount $MEDIUM
    echo 2 - $FEHLER >>usbsich3.log
    sleep 3
    echo -e "\nBelegung der Platten:\n=====================\n`df -h `\n" >>usbsich3.log
    [ "$MODUS" == "manuelle" ]  && gui/davdialog --title "Datensicherung" --msg "Daten erfolgreich gesichert";
  else
   sleep 3
    echo 3 - $FEHLER >>usbsich3.log
   umount $MEDIUM
    echo 4 - $FEHLER >>usbsich3.log
   FEHLER="mit Fehler(R)"
   [ "$MODUS" == "manuelle" ] && gui/davdialog --title "Fehler bei der Datensicherung" --error "`head -10 usbsich2.log`"
  fi
  ./isam
  sync
} || { cat usbsich1.log; [ "$MODUS" == "manuelle" ] &&  gui/davdialog --title "Fehler bei der Datensicherung" --error "Wechselplatte nicht bereit"; echo 5 - $FEHLER >>usbsich3.log; umount $MEDIUM; echo 6 - $FEHLER >>usbsich3.log; FEHLER="mit Fehler(M)"; }
echo -e "\n$MODUS Datensicherung auf USB-Platte $FEHLER beendet am `date "+%d.%m.%y um %H:%M Uhr"`
========================================================================\n"  >>usbsich3.log
#
# Gesamtlogfile schreiben
#
cat usbsich?.log >usbsich.log
cat usbsich.log | mail -s "$MODUS Datensicherung $FEHLER beendet" $MAIL_AN


