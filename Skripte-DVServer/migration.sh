#!/bin/bash

# DV Datenmigration; Speedpoint (FW), Stand: Maerz 2011


# Pfade festlegen -------------------------------------------
#
quelle="/install/migration/home/david"    # Quelldaten
ziel="/home/david"                        # DAV_HOME
log="/install/migration/migration.log"    # Logdatei
faillog="/install/migration/faillog.txt"  # Fehlerlog
ctorg="/install/migration/ctorg.conf"     # Konfig fuer KVK
#
# -----------------------------------------------------------


# Ausfuehrung als root?
#
if [ ! "`id -u`" = "0" ]; then
   clear
   echo "**********************************************"
   echo "***   ABBRUCH - Rootrechte erforderlich    ***"
   echo "**********************************************"
   echo
   exit 1
fi


clear
echo "########################"
echo "###  Datenmigration  ###"
echo "########################"
echo ""
echo "Es werden Daten"
echo "    von ---> $quelle"
echo "   nach ---> $ziel" 
echo "kopiert."
echo ""
echo "Daten in $ziel werden dabei ueberschrieben!"
echo ""
echo "Weiter (j/n) [n]?"
stty cbreak -echo
Z=`dd bs=1 count=1 2>&-`
stty -cbreak echo 
case $Z in
   j*|J*) ;;
       *) echo ""
          echo "Abbruch durch Benutzer." 
          echo ""
          exit 0 ;;
esac

clear
echo "Wurde die alte ctorg.conf nach $ctorg kopiert (sonst Abbruch)?"
echo "(j/n) [n]?"
echo ""
stty cbreak -echo
Z=`dd bs=1 count=1 2>&-`
stty -cbreak echo 
case $Z in
   j*|J*) kvk=true
          ;;
       *) echo "ctorg.conf wird NICHT migriert."
          sleep 5
          kvk=false
          ;;
esac


hier="`pwd`"


# Quelldaten vorhanden?
#
if [ ! -s $quelle/david2.isa ]; then
   echo "ABBRUCH - Quelldaten in $quelle vorhanden??"
   echo ""
   exit 1
fi


# Versionscheck
#
echo ""
echo "Pruefe Versionen der Datenbanken in Quelle und Ziel..."
#
#-------------------------------------------------------------------------------------
# alte Version: Nur eine DB wird geprueft:
#if [ "`$ziel/doc -v $quelle/david2.isa`" != "`$ziel/doc -v $ziel/david2.isa`" ]; then
#   echo "ABBRUCH - DV Versionen nicht identisch!"
#   echo ""
#   exit 1
#else
#   echo "DV Versionen identisch, Datenmigration beginnt."
#   echo ""
#fi
#-------------------------------------------------------------------------------------
#
# neue Version: ALLE DBs werden geprueft:
listQ="/install/migration/dbversion_quelle.txt" && rm -f $listQ 2>/dev/null
listZ="/install/migration/dbversion_ziel.txt"   && rm -f $listQ 2>/dev/null
#
i=""
for i in {1..9}; do echo "Version david$i.isa: `$ziel/doc -v $quelle/david$i.isa`" >>$listQ; done
for i in {1..9}; do echo "Version david$i.isa: `$ziel/doc -v $ziel/david$i.isa`"   >>$listZ; done
#
echo "Folgende Versionen wurden gefunden (erste Spalte = Quelle, zweite Spalte = Ziel):"
diff -y $listQ $listZ
echo ""
#
if [ "$(diff -q $listQ $listZ)" != "" ]; then
   echo "Die DV Versionen in Quelle und Ziel sind nicht identisch!"
   echo "Die Migration wird ohne Veraenderung der Daten abgebrochen."
   echo ""
   exit 1
else
   echo "DV Versionen identisch, Datenmigration beginnt..."
   echo ""
fi


# Abfahrt
#
if [ -e $faillog ]; then
   mv -f $faillog $faillog.bak
fi
touch $faillog
#
echo "ISAM abschalten..."
cd $ziel
./iquit
#
echo "Dateien kopieren..."
cp -vpf $quelle/david?.is? $ziel/ >>$log 2>>$faillog
cp -vpf $quelle/cgmassist.is? $ziel/ >>$log 2>>$faillog
cp -vpf $quelle/docfo.fbn $ziel/ >>$log 2>>$faillog
cp -vpf $quelle/*.txd $ziel/ >>$log 2>>$faillog
cp -vpf $quelle/txtparam.* $ziel/ >>$log 2>>$faillog
cp -vpf $quelle/printer.dbf $ziel/ >>$log 2>>$faillog
cp -vpf $quelle/labor.tpl $ziel/ >>$log 2>>$faillog
cp -vpf $quelle/david.cfg $ziel/Desktop/OLD_david.cfg >>$log 2>>$faillog
cp -vpf $quelle/*.XKM $ziel/ >>$log 2>>$faillog
cp -vpf $quelle/vcscmd?.sh $ziel/ >>$log 2>/dev/null
cp -pf $quelle/meddb.alter $ziel/ 2>>/dev/null
cp /home/david/dmpassist.demo /home/david/dmpassist && chmod +x /home/david/dmpassist
if [ "`ls $quelle/*.print`" ]; then
   mkdir $ziel/Desktop/OLD_Printscripts
   cp -vpf $quelle/*.print $ziel/Desktop/OLD_Printscripts/ >>$log 2>>$faillog
else
   echo "Keine Druckscripte in $quelle gefunden."
fi

#
if [ $kvk ]; then
   cp -vpf $ctorg /home/david/Desktop/OLD_ctorg.conf
fi
#
echo "Verzeichnisse kopieren..."
cp -rvpf $quelle/eHKS $ziel/ >>$log 2>>$faillog
cp -rvpf $quelle/ventario $ziel/ >>$log 2>>$faillog
cp -rvpf $quelle/Verschluesselt $ziel/ >>$log 2>>$faillog
cp -rvpf $quelle/Listen $ziel/ >>$log 2>>$faillog
cp -rvpf $quelle/AISnet2 $ziel/ >>$log 2>>$faillog
cp -rvpf $quelle/dfue_* $ziel/ >>$log 2>>$faillog
cp -rvpf $quelle/vitax $ziel/ >>$log 2>>$faillog
echo "---------------------------------------------------------" >>$log
echo "trpword kopieren (kann dauern)..."
cp -rvpf $quelle/trpword $ziel/ >>$log 2>>$faillog
#
echo "Dateirechte anpassen..."
DAV_HOME=$ziel && export DAV_HOME
./bin/fixdavperms
#
echo "ISAM starten..."
./isam
#
echo ""
echo "Kopiervorgaenge abgeschlossen."
echo ""
echo "zum Fortfahren ENTER druecken..."
read dummy


# Druckumleitungen ausgeben:
#
clear
echo "Druckumleitungen ermitteln..."
if [ ! -z "`./expo -k "(41)" david3.isa`" ]; then
   ./expo -k "(41)" david3.isa >>$ziel/trpword/Druck_Uml.txt
   echo "Fertig. Tabelle leigt unter $ziel/trpword/Druck_Uml.txt."
   echo ""
   echo "Tabelle jetzt anzeigen (j/n) [j]?"
   stty cbreak -echo
   Z=`dd bs=1 count=1 2>&-`
   stty -cbreak echo 
   case $Z in
      n*|N*) ;;
          *) echo ""
             cat $ziel/trpword/Druck_Uml.txt
             echo ""
             echo "Weiter mit ENTER..."
             read dummy
             ;;
   esac
else
   echo "Es wurden keine Druckumleitungen in $ziel gefunden."
   echo ""
   echo "Weiter mit ENTER..."
   read dummy
fi


# GDT Einstellungen ermitteln:
#
clear
echo "GDT Einstellungen ermitteln..."
if [ -z "`find $quelle -type f -name gdtrc`" ]; then
   find $quelle -type f -name gdtrc >>$ziel/trpword/GDT_Config.txt
   echo "Fertig. Tabelle liegt unter $ziel/trpword/GDT_Config.txt."
   echo "Daten wurden NICHT kopiert, bitte manuell durchfuehren!"
   echo ""
   echo "Tabelle jetzt anzeigen (j/n) [j]?"
   stty cbreak -echo
   Z=`dd bs=1 count=1 2>&-`
   stty -cbreak echo 
   case $Z in
      n*|N*) ;;
          *) echo ""
             cat $ziel/trpword/GDT_Config.txt
             echo ""
             ;;
   esac
else
   echo "Es wurden keine GDT Konfigurationen in $quelle gefunden."
   echo ""
fi

echo "DV Datenmirgation abgeschlossen."


# Fehler gefunden?
#
if [ ! -z $faillog ]; then
   echo ""
   echo "ACHTUNG: Bitte  $faillog beachten!"
   echo ""
   echo "Jetzt anzeigen (j/n) [j]?"
   stty cbreak -echo
   Z=`dd bs=1 count=1 2>&-`
   stty -cbreak echo 
   case $Z in
      n*|N*) ;;
          *) echo ""
             cat $faillog
             echo ""
             echo "Weiter mit ENTER..."
             ;;   
   esac

else
   echo "Logdatei in $log."
fi

echo ""
echo "Aktion abgeschlossen."
echo ""
echo "--> Bitte ggf. 'rechte' Scripte aus dfue_* Verzeichnis(sen) ausfuehren!"
echo ""

cd $hier

exit 0
