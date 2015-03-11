#!/bin/sh

## PRUEFUNG ##

# DAV_HOME
if [ ! "$DAV_HOME" ]; then
    echo "Fehler: Die DAV_HOME Umgebungsvariable ist nicht gesetzt!"
    echo
    echo "Beenden mit Return"
    read trash
    exit 1
fi

# Ist perl installiert ?
which perl >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Fehler: perl ist nicht auf Ihrem System installiert."
    echo
    echo "Beenden mit Return"
    read trash
    exit 1
fi

# Alle Instanz beenden
if ! semdump -n; then
    echo "Fehler: Programme beenden"
    echo "Diese Prozedur kann nur korrekt ablaufen, wenn das Arztprogramm"
    echo "an ALLEN Bildschirmen beendet wurde. Das System hat festgestellt,"
    echo "dass noch nicht alle Bildschirme das Arztprogramm verlassen haben!"
    echo
    echo "Bitte beenden Sie das Arztprogramm an ALLEN Bildschirmen und starten"
    echo "Sie die Prozedur dann erneut."
    echo
    echo "Beenden mit Return"
    read trash
    exit 1
fi

# Bin ich root ?
if ! [ "`id -u`" = "0" ]; then

    echo "Geben Sie bitte das \"root\" Passwort ein"

    while true
    do
        if su -c "${DAV_HOME}/wkflinfl/cleaner/dp_cleaner.sh"; then
            break
        fi
    done

    exit 0
fi


## GO ##

cd $DAV_HOME/wkflinfl/cleaner
if [ $? -ne 0 ]; then
   echo "Fehler: Der Pfad $DAV_HOME/wkflinfl/cleaner existiert nicht"
   exit
fi

echo
echo "CGM-Assist IPC-Resourcen Reset"
echo "------------------------------"

echo "DP-Prozesse beenden"
killall -9 dpclientx >/dev/null 2>/dev/null
killall -9 wkflbr32 >/dev/null 2>/dev/null
killall -9 wkflbu32 >/dev/null 2>/dev/null
killall -9 wkflsr32 >/dev/null 2>/dev/null
killall -9 dpLogreciever >/dev/null 2>/dev/null
killall -9 start_dplogreceiver.sh >/dev/null 2>/dev/null

echo "IPC-Reset"
ipcs -a | ./ipc_remover.pl >/dev/null 2>/dev/null

echo "Lösche Inhalt temp-Ordner ($DAV_HOME/wkflinfl/temp/*)"
rm -rf $DAV_HOME/wkflinfl/temp/* >/dev/null 2>/dev/null

echo "Lösche alte socket-Dateien und Error-Logs (../wkflinfl/uds/*_*_*)"
uds_files=`find $DAV_HOME/wkflinfl/uds -name "*_*_*"`
for k in $uds_files
do
    rm -rf $k >/dev/null 2>/dev/null
done

echo "Lösche temporäre Dateien (/tmp/qipc_*)"
qipc_files=`find /tmp -name "qipc_*"`
for i in $qipc_files
do
    rm -rf $i >/dev/null 2>/dev/null
done

# Go to Home !
cd $DAV_HOME

# Fertig
echo
echo "Fertig"
echo "Beenden mit Return"
read trash
