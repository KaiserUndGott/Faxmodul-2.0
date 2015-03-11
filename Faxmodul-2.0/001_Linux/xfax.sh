#!/bin/bash





###############################################################################
#                                                                             #
# Dieses Skript ist Bestandteil des Speedpoint Faxmoduls.                     #
# Zur Konfiguration und zur Bedienung bitte die Anleitung beachten!           #
#                                                                             #
# !!   Skript DisplayAusgabe.sh erforderlich   !!                             # 
# !!   /usr/bin/Xdialog erforderlich           !!                             # 
#                                                                             #
# Version 2.1                                                                 #
# Speedpoint next Generations GmbH (4H,MR,FW), Stand: September 2014          #
#                                                                             #
###############################################################################






###############################################################################
#
# Konfigurationsbereich - Bitte anpassen:                                              
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Mehrplatzversion [0/1]:
# Auf Mehrplatzsystemen werden automatisch mehrere FritzFax Instanzen 
# angesteuert, sofern lizensiert.
#

mehrplatz="1"

#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Variante H-Arzt oder Variante U-Arzt [H/U]: 
# Faxnufnummer des jew. aktuellen Hausaerztes oder des Ueberweisers anbieten?
# Ist beides gefordert, bitte zwei unterschiedliche cups Drucker anlegen.
#

faxliste="U"

#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Angaben zum Netzwerk:
#
# Im folgenden trpword Unterordner werden Fax- und Protokolldaten abgelegt:
#

cupsout="faxout"

#
#
# Hier die IP Adresse DATA VITAL Servers angeben (Quelle fuer Laufwerk W:):
#

linuxpc="172.16.11.164"

#
#
# Samba Freigabename für /home/david/trpword (SMB Share Name fuer trpword):
#

smbshare="Word"

#
#
# IP Adresse des Default Windows Faxservers:
# Falls am lokalen WinPC kein Fritzfax startbar ist, wird dieser Default
# verwendet:
#

winpc="172.16.11.98"

#
#
# Port, auf welchem an allen (!) teilnehmenden Windows Rechnern der Rexserver
# ansprechbar ist:
#

port="6667"

#
#
# Infodatei mit aktueller DAV_ID sowie Terminalkennung, wird automatisch bei
# jedem Pat.aufruf aktualisiert, sofern Exportskript "faxmodul.sh" in DV 
# aktiv ist. Nur Dateinamen (ohne Pfad) angeben, siehe spfaxmodul.sh!
#

helpfile=".faxhelper.txt"

#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Startbefehl für 4hFriFa.exe an allen (!) WindowsPCs (DAVCMD Schreibweise):
#

FriFax="c:\\FritzSendFax\\4hfrifa20.exe"

#
#
# Soll 4hFriFa.exe mit nowindow.exe gestartet werder, hier das passende Präfix
# eintragen: "C:\\david\nowindow.exe". Ansonsten leer lassen.
#

nowindow=""

#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# OPTIONALE PARAMETER:
#
# Hier den FritzFax Installationspfad (ohne EXE) in DAVCMD Schreibweise angeben:
# Ohne korrekte Angabe kann kein automatischer FritzFax Start erfolgen.
# Der Default lautet: "C:\\Program Files (x86)\FRITZ"\!"" (inklusive aller ")
#

fritzpfad="C:\\Program Files (x86)\FRITZ"\!""

#
#
# Falls hier "1" eingestellt wird, ist das Skript "gespraechiger" und es werden
# temporaere Daten sowie Faxdateien erhalten.
#

debug="1"

#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Ende des Konfigurationsbereiches
#
###############################################################################








# Ab hier bitte Finger weg ----------------------------------------------------







# Function:
# --------------------------------------------
#
function_cleanlogs()
{
  # Logfiles aufraeumen:
  if [ ! "$debug" = "1" ]; then
     rm -f $faxfile               2>/dev/null
     rm -f $FaxPfad/*.pdf         2>/dev/null
     rm -f $faxfehler             2>/dev/null
     rm -f $FaxPfad/Faxversand.ok 2>/dev/null
     rm -f $aerztelisteprg        2>/dev/null
  fi
}
#
# --------------------------------------------


# Definitionen:
FriFax="$nowindow c:\\FritzSendFax\\4hfrifa20.exe"
FaxNr=$2  
FaxPfad=/home/david/trpword/$cupsout
FaxPfadWin="\\\\$linuxpc"\\$smbshare\\$cupsout\\
ichbins=`whoami`
helpfile="/home/$ichbins/$helpfile"
debuglog="$FaxPfad/SP_Log.txt"
export XAUTHORITY=/home/$ichbins/.Xauthority
export DISPLAY=`cat /home/$ichbins/DisplayAusgabe`


# ggf. Logdatei anlegen:
[ "$debug" = "1" ] && echo "----- `date` -------------------------------------------------" >>$debuglog
[ "$debug" = "1" ] && echo "Debug Logdatei ist $debuglog."


# Fehler ausgeben, falls keine Ausgabedatei von DisplayAusgabe.sh gefunden:
if [ ! -e /home/$ichbins/DisplayAusgabe ]; then
   echo ""
   echo "****************************************************************"
   echo "Faxmodul nicht initialisiert, wurde DisplayAusgabe.sh gestartet?"
   echo "****************************************************************"
   echo ""
   echo "Kein XDialog initialisiert (EXIT)." | tee -a $debuglog
   exit 1
fi


# Ausgabeordner ggf. anlegen:
[ ! -d $FaxPfad ] && mkdir -p -m 777 $FaxPfad
#
if [ ! -d $FaxPfad ]; then
   [ "$debug" = "1" ] && echo "Faxordner $FaxPfad konnte nicht angelegt werden (EXIT)." >>$debuglog
   /usr/bin/Xdialog --title "Fehler"                      \
                    --ok-label "Abbruch"                                \
                    --msgbox "$FaxPfad konnte nicht angelegt werden.\n\Kein Faxversand moeglich." 0 0
   function_cleanlogs
   exit 1
fi
#


######################################
# Wurde uns eine Faxdatei uebergeben?
######################################

if [[ ! $1 ]]; then
    [ "$debug" = "1" ] && echo "Es wurde keine Faxdatei uebergeben (EXIT)." >>$debuglog
    /usr/bin/Xdialog --title "Fehler"                                  \
                     --ok-label "Abbruch"                              \
                     --msgbox "Es wurde keine Faxdatei uebergeben.\n   \
    Kein Faxversand moeglich." 0 0
    function_cleanlogs
    exit 1
else
   # Falls uebergebene Faxdatei kein PDF, dann konvertieren:
   if [ `file $1 | awk -F":" '{print $2}' | head -c4 | tail -c3` = "PDF" ]; then
      faxfile=$1
   else
      ps2pdf $1 $1.pdf
      faxfile=$1.pdf
   fi
   quelle="pdf"
fi
#
[ "$debug" = "1" ] && echo "Der Faxauftrag wurde durch User \"$2\" gestartet." >>$debuglog
[ "$debug" = "1" ] && echo "cups-pdf liefert Datei $1." >>$debuglog


###############################################################################
# Ermittlung der Terminal-ID des aktuellen Users, sofern moeglich             #
###############################################################################

# Ist eine Infodatei vorhanden?
if [ -e "$helpfile" ]; then
   dvid=`sed -n '1p' $helpfile | awk {'print $2'}`
   lkid=`sed -n '4p' $helpfile | awk {'print $2'}`
   # Ist aktuell ein Patient aufgerufen?
   if [ -r "/home/david/trpword/$lkid/patienten$lkid.txt" ]; then    
      [ "$debug" = "1" ] && echo "Ein Patient ist aktuell aufgerufen." >>$debuglog
      
      [ "$debug" = "1" ] && echo "Aktuelle DAV_ID ist \"$dvid\"." >>$debuglog
      [ "$debug" = "1" ] && echo "Aktuelle LockID ist \"$lkid\"." >>$debuglog
   else
      # Fehler bzw. kein Pat. aufgerufen:
      dvid=$ichbins
      [ "$debug" = "1" ] && echo "Aktuell ist kein Patient aufgerufen." >>$debuglog
   fi
else
   [ "$debug" = "1" ] && echo "$helpfile nicht gefunden, manueller Modus." >>$debuglog
fi   
#
$dvid=$2


#######################################################################
# Falls Mehrplatzsystem aktiviert, IP Adresse fuer FritzFax ermitteln:
#######################################################################

if [ "$mehrplatz" = "1" ]; then
   [ "$debug" = "1" ] && echo "Die Mehrplatzversion des Faxmoduls ist aktiviert." >>$debuglog
   ipposl=`who | fgrep $ichbins | fgrep -v / | fgrep -v tty | grep -b -o \( | awk 'BEGIN {FS=":"} {print $1}'`
   ipposr=`who | fgrep $ichbins | fgrep -v / | fgrep -v tty | grep -b -o \) | awk 'BEGIN {FS=":"} {print $1}'`

   ipadr=`who  | fgrep $ichbins | fgrep -v /                                \
                                | fgrep -v tty                              \
                                | cut -c$ipposl-$ipposr >/dev/null 2>&1     \
                                | sed 's/ //g'                              \
                                | sed 's/(//g'                              \
                                | sed 's/)//g'`
   #
   if [ "$ipadr" = "" ]; then
      #[ "$debug" = "1" ] && echo "$dvid ist lokal bzw. per XDMCP angemeldet." >>$debuglog
      [ "$debug" = "1" ] && echo "Der default Faxserver $winpc wird verwendet." >>$debuglog
      ipadr=$winpc
   else
      [ "$debug" = "1" ] && echo "Ermittelte IP Adresse fuer FritzFax Aufruf: \"$ipadr\" (Default war $winpc)." >>$debuglog
   fi
else
   [ "$debug" = "1" ] && echo "Die Mehrplatzversion des Faxmoduls ist nicht aktiviert, der zentrale Faxserver ist $winpc." >>$debuglog  
   ipadr=$winpc 
fi


##################################################################
# Pruefung, ob FritzFax auf der eben ermittelten IP gestartet ist:
##################################################################

# Ggf. zunaechst altes Flag entfernen:
[ -d /home/david/trpword/faxflag ] && rm -rf /home/david/trpword/faxflag
#
# Schreibe ein Flag nach W:, sofern FritzFax in der Tasklist gefunden:
echo "DAVCMD tasklist | findstr "FriFax32.exe" && mkdir W:\\faxflag" | netcat $ipadr $port 2>/dev/null
# Suche jetzt das Flag:
if [ -d /home/david/trpword/faxflag ]; then
   [ "$debug" = "1" ] && echo "Ein Flag für FritzFax wurde auf $ipadr gefunden." >>$debuglog
   [ "$debug" = "1" ] && echo "$ipadr wird fuer den Faxaufruf verwendet." >>$debuglog
   rm -rf /home/david/trpword/faxflag
else
   # Kein FritzFax Task gefunden:
   [ "$debug" = "1" ] && echo "Es wurde kein Flag für FritzFax in $FaxPfad gefunden." >>$debuglog
   # FritzFax Start versuchen:
   [ "$debug" = "1" ] && echo "Ein FritzFax Startversuch auf $ipadr wird unternommen." >>$debuglog
   echo "DAVCMD 'cd /D '\"$fritzpfad\"' & start /min FriFax32.exe -a'" | netcat $ipadr $port
   Xdialog --title "Faxserver Start" \
           --infobox "Bitte einen Augenblick warten, der Faxserver wird gestartet..." 0 0 7000 
   # Nochmals nach FritzFax Task suchen:
   echo "DAVCMD tasklist | findstr "FriFax32.exe" && mkdir W:\\faxflag" | netcat $ipadr $port 2>/dev/null
   # Flag jetzt vorhanden?
   if [ -d /home/david/trpword/faxflag ]; then
      [ "$debug" = "1" ] && echo "FritzFax konnte auf $winpc gestartet werden." >>$debuglog
      rm -rf /home/david/trpword/faxflag
   else
      # Auf den Standard Faxserver ausweichen:
      [ "$debug" = "1" ] && echo "FritzFax konnte nicht gestartet werden." >>$debuglog
      [ "$debug" = "1" ] && echo "$winpc wird verwendet (bitte dort manuell starten)." >>$debuglog
      ipadr=$winpc
   fi
fi


# Aerzteliste zur Anzeige mit /usr/bin/Xdialog vorbereiten:
[ "$debug" = "1" ] && echo "Folgende Dateien werden verarbeitet:" >>$debuglog
aerzteliste1="/home/david/trpword/aerzte.001"
       [ "$debug" = "1" ] && echo "    Arztliste: $aerzteliste1" >>$debuglog
aerztelisteprg="/home/david/aerzteliste.sh"
       [ "$debug" = "1" ] && echo "    Skript fuer Arztliste: $aerztelisteprg" >>$debuglog
UFile="/home/david/trpword/$lkid/patienten$lkid.txt"
       [ "$debug" = "1" ] && echo "    DV Exportdatei 1: $UFile" >>$debuglog
ueberweiser1="/home/david/trpword/$lkid/ueberweiser.txt"
       [ "$debug" = "1" ] && echo "    Generiert wird: $ueberweiser1" >>$debuglog
PFile="/home/david/trpword/$lkid/text.$lkid"
       [ "$debug" = "1" ] && echo "    DV Exportdatei 2: $PFile" >>$debuglog


# Sofern Exportdatei vorliegt, entsprechenden Arzt finden:
if [ -e $UFile ];then
   # Arztdatei generieren und dabei Sonderzeichen filtern bzw. Umlaute konvertieren:
   iconv -f ISO-8859-1 -t UTF-8 $UFile >$ueberweiser1
   #
   # H-Arzt oder U-Arzt anbieten?
   if   [ "$faxliste" = "H" ]; then    
        FaxNr=`tail -n1 $ueberweiser1 | awk -F";" '{print $69}' | sed 's/[^0-9]//g'`
        UArzt=`tail -n1 $ueberweiser1 | awk -F";" '{print $65}' | tr -d "[]"`
        UOrt=`tail -n1 $ueberweiser1  | awk -F";" '{print $67}' `
        UStr=`tail -n1 $ueberweiser1  | awk -F";" '{print $66}' `
   elif [ "$faxliste" = "U" ]; then
        FaxNr=`tail -n1 $ueberweiser1 | awk -F";" '{print $55}' | sed 's/[^0-9]//g'`
        UArzt=`tail -n1 $ueberweiser1 | awk -F";" '{print $51}' | tr -d "[]"`
        UOrt=` tail -n1 $ueberweiser1 | awk -F";" '{print $53}' `
        UStr=` tail -n1 $ueberweiser1 | awk -F";" '{print $52}' `
   else     
        /usr/bin/Xdialog --title "Hinweis"    \
                         --msgbox "Arztauswahl nicht korrekt konfiguriert. \nBitte Faxnummer manuell eingeben." 0 0    
   fi
else
   FaxNr=""
fi
#
rm $ueberweiser1 2>/dev/null


# Ab hier neue Logdatei zur Auswertung durch 4hFriFa:
faxfehler=$FaxPfad/4HFaxerror.txt
echo "Faxserver   : $ipadr" > $faxfehler
echo "PatDatenFile: $PFile" >> $faxfehler
echo "FaxPfad     : $FaxPfad" >> $faxfehler
echo "Faxdatei    : $1" >> $faxfehler
echo "User        : $2" >> $faxfehler
echo "Dateityp    : $quelle" >> $faxfehler
echo "" >> $faxfehler


#########################################################
# Dialoge zur manuellen Eingabe der Faxnummer generieren:
#########################################################

if [ "$quelle" = "pdf" ]; then
   retval=""
   until [ $retval = 0 -o $retval = 255 ]; do      
         # Ermitteln, ob seitens DV eine Exportdatei bereit liegt: 
         if [ -s $UFile ]; then
            zusatz="\n\nAktueller Empfaenger:\n\n$UArzt\n$UStr\n$UOrt"
         else
            zusatz=""
         fi
         #
         /usr/bin/Xdialog --cancel-label "Arzt suchen"  \
                 --title "Faxnummer eingeben"           \
                 --clear                                \
                 --inputbox "- Bitte die Faxnummer eingeben -$zusatz" 20 70 $FaxNr 2>/tmp/inbox.tmp.$$
         retval=$?
         FaxNr=`cat /tmp/inbox.tmp.$$`
         rm -f /tmp/inbox.tmp.$$
         if [[ $retval = 1 ]]; then 
            if [ -e $aerzteliste1 ];then
               # ausführbare Datei mit /usr/bin/Xdialog u. integrierter Ärzteliste erzeugen:
               # Leerzeile am Anfang (wegen bash)
               echo -e "\n" >$aerztelisteprg 
               chmod 775 $aerztelisteprg  
               # Teil 1 des /usr/bin/Xdialogs in Programmdatei einfügen:
               echo "/usr/bin/Xdialog --cancel-label "\""Zurueck zur manuellen Eingabe"\"" \
                             --title "\""Faxnummer Auswahl"\""                             \
                             --menu "\""Liste der Ueberweiser"\"" 30 90 14 \\" >> $aerztelisteprg
               # Ärzteliste einfügen
               # Teil 2 des /usr/bin/Xdialogs in Programmdatei einfügen
               iconv -f ISO-8859-1 -t UTF-8 $aerzteliste1 \
                        | awk -v HK="\"" -F";" '{gsub(" ","",$8)}{if($8!="")print HK$4HK" "HK$8HK" \\"}' \
                        | sort >>$aerztelisteprg
               echo "2> /tmp/inbox.tmp.$$" >> $aerztelisteprg
               # erstelltes /usr/bin/Xdialog-Programm ausführen
               $aerztelisteprg
               # Faxnr herausfiltern
               select=`cat /tmp/inbox.tmp.$$`
               FaxNr=`cat $aerztelisteprg|fgrep -w "$select"|awk '{print $(NF-1)}'|sed 's/[^0-9]//g'`
               echo $FaxNr >>/home/david/Desktop/Faxnr.txt
               rm -f /tmp/inbox.tmp.$$
            else
               /usr/bin/Xdialog --title "Listenanzeige" --msgbox "Es ist keine Ueberweiserdatei vorhanden" 6 60
            fi
         fi
   done
# ToDo: else Abschnitt, z.B. zur Faxverarbeitung von Jobs aus der OO-Schnittstelle oder Kontextmenue
fi


# Falls leere Faxnummer uebergeben oder Abbruch durch Benutzer:
if [[ ! $FaxNr && $retval = 0 ]]; then
   /usr/bin/Xdialog --title "Abbruch" --msgbox "Es wurde keine Faxnummer eingegeben." 6 60
   echo "Es wurde keine Faxnummer angegeben (EXIT)." >> $faxfehler
   function_cleanlogs
   exit 1
elif [[ $retval = 255 ]]; then
   /usr/bin/Xdialog --title "Abbruch" --msgbox "Abbruch durch Benutzer" 6 60
   echo "Abbruch durch Benutzer (EXIT)." >> $faxfehler
   function_cleanlogs
   exit 1
fi


# Falls keine Datei als Parameter von CUPS erhalten:
if [[ ! -e $1 ]]; then
   /usr/bin/Xdialog --msgbox "Faxdatei wurde nicht gefunden." 6 60
   echo "Faxdatei wurde nicht gefunden (EXIT)." >> $faxfehler
   function_cleanlogs
   exit 1
fi


# Namen des Patienten bestimmen:
if [ -e $PFile ];then
    p1="$(sed -n '1p' $PFile)"
    p2="$(sed -n '2p' $PFile)"
    p3="$(sed -n '3p' $PFile)"
    PNam=$p2"_"$p3"_[$p1]"
    # ggf. dessen Patientennummer ermitteln:
    PatNr="Patient_$(sed -n '1p' $PFile)"
else
    PatNr="Patient_unbekannt"
fi


# Weitere Zusammenfassung der Ergebnisse:
[ "$debug" = "1" ] && echo "    Name des cups-pdf Dokuments: $faxfile." >>$debuglog
[ "$debug" = "1" ] && echo "    Name des aktiven Patienten: \"$PNam\"." >>$debuglog
[ "$debug" = "1" ] && echo "Name des Faxdukuments: \"$PatNr.pdf\"." >>$debuglog
[ "$debug" = "1" ] && echo "Weitere Infos siehe $faxfehler." >>$debuglog
[ "$debug" = "1" ] && echo "" >>$debuglog


# Diese Daten werden von 4hFriFa verarbeitet:
echo "Variablen sind OK" >> $faxfehler
echo "Faxfile: $faxfile" >> $faxfehler
echo "Ziel: $FaxPfad/$PatNr.pdf" >> $faxfehler
echo "Faxnummer: $FaxNr" >> $faxfehler
cp $faxfile $FaxPfad/$PatNr.pdf
chmod 777 $FaxPfad/*
#
if [[ ! $FaxPfad/$PatNr.pdf ]]; then
   echo "Exportdatei nicht gefunfden (EXIT)." >> $faxfehler
   rm $FaxPfad/Faxversand.ok
   function_cleanlogs
   exit
fi


#######################################################
# Uebergabe der Faxdatei mitsamt Parametern an Windows:
####################################################### 

# der 3. Parameter wird zur Zeit durch 4HFriFa nicht ausgewertet:
echo "DAVCMD $FriFax" $FaxNr $PatNr.pdf $PNam $FaxPfadWin | netcat $ipadr $port
sleep 3


#####################################
# Fehlerpruefung durch 4hFriFa20.exe:
#####################################

faxlog=$FaxPfad/4HFaxprotokoll.txt
status="$(echo "Pat-Nr:"$PatNr "  -  "   \
        $(sed -n '7,7 p' $PFile) "  -  " \
        $(sed -n '8,8 p' $PFile) "  -  " \
        $(sed -n '9,9 p' $PFile) "  -  " \
        $(sed -n '6,6 p' $PFile))"
#
if [ -f $FaxPfad/Faxversand.ok ]; then
   date >>$faxlog
   echo $status >>$faxlog
   echo "Fax Vorbereitung fuer User '$dvid' an $FaxNr ok." >>$faxlog
   echo "FritzFax Aufruf an $ipadr erfolgreich." >>$faxlog
   function_cleanlogs
else
   date >>$faxlog
   echo "" >>$faxlog
   echo "######" >>$faxlog
   echo "######  FEHLER  :-(" >>$faxlog
   echo "######  FritzFax Aufruf fuer User '$dvid' fehlgeschlagen." >>$faxlog
   echo "######  Bitte Laufwerk W: & Konfiguration von 4hFriFa.exe pruefen." >>$faxlog
   echo "######" >>$faxlog
   echo "" >>$faxlog
   echo $status >>$faxlog
   cat $faxfehler >>$faxlog
   #rm -f $FaxPfad/$PatNr.pdf
   /usr/bin/Xdialog --title "Fehler"                         \
           --center                                          \
           --msgbox "Aufruf des Faxmoduls fehlgeschlagen.\nBitte $faxlog pruefen." 0 0
fi
#
echo "---------------------------------------------------------------------" >>$faxlog


#############
# Aufraeumen:
#############

chmod 666 $FaxPfad/*
if [ ! "$debug" = "1" ]; then
   rm -f $debuglog
   rm -f $FaxPfad/*.pdf
   rm -f $FaxPfad/Faxversand.ok 
   rm -f $FaxPfad/Faxerror.txt
else
   rm -f $faxfile
fi
#
# umfasst $faxlog mehr als 2000 Zeilen, werden die aeltesten 20 Zeilen geloescht.
# Erfolge erzeugen je 5, Misserfolge je 20 Eintraege.
if [ `sed -n $= $faxlog` -gt 2000 ]; then sed -i '1,20d' $faxlog; fi
#
# Konvertierung der Protokolldateien fuer Windows Editoren:
unix2dos -o $FaxPfad/Fax*.txt
unix2dos -o $faxlog

exit 0
