#!/bin/bash




##############################################################################
#                                                                            #
# Ermittlung des X Displays von NXClient Usern zur Nutzung von Xdialog;      #
#                                                                            #
# Dieses Script schreibt die ermittelte Display Variable in eine Textdatei,  #
# welche von der SPnG Version der xfax.sh ausgewertet wird.                  #
#                                                                            #
# Bestandteil des Speedpoint Faxmoduls                                       #
#                                                                            #
# !! Funktioniert nur mit NX Sitzungen, nicht z.B. mit X2Go !!               #
#                                                                            #
# Speedpoint (TH,MR,FW) Stand: Juli 2014, Version 2.0                        #
#                                                                            #
##############################################################################




# Bitte konfigurieren ########################################################
#
# alte NX-Cacheordner bei Anmeldung entfernen (0 oder 1)?
rmnxcache="1"
#
##############################################################################



# los geht's:



# ==========================================================
# alte NX-Cacheordner entfernen (Verfahren wurde ersetzt)
#if [ $rmnxcache = "1" ]; then
#   if [ "`find .nx/ -name C-* -type d 2>/dev/null`" ];then
#      neu="`ls -tc .nx | grep '^C-' | sed -n '1p'`"
#      for i in `ls .nx | grep '^C-'`; do
#         if [ $i != $neu ]; then
#            rm -f $i
#         fi
#      done
#   fi
#fi
# ==========================================================

# ==========================================================
# alte NX-Cacheordner entfernen, neues Verfahren:

if [ $rmnxcache = "1" ]; then
   rmpfad="$HOME/.nx"
   neu=`ls -tcr $rmpfad | grep '^C-' |sed -n '1p'`
   find $rmpfad -type d -name C-* ! -name $neu -exec rm -rf {} \; 2>/dev/null
fi
# ==========================================================

if [ "`find .nx/ -name C-* -type d 2>/dev/null`" ]; then
   Tkennung="`ls -tc .nx | grep '^C-' | rev | awk 'BEGIN {FS="-"}{print $2}' | rev`"
   Display=:$Tkennung.0
   echo $Display  >$HOME/DisplayAusgabe
else
   /usr/bin/Xdialog --infobox "Verzeichnis exitiert nicht" 0 0 2000
   echo ":0.0"  > $HOME/DisplayAusgabe
fi

chmod 777 $HOME/DisplayAusgabe
export DISPLAY=`cat $HOME/DisplayAusgabe`
export XAUTHORITY=$HOME/.Xauthority

Rueckgabe=`cat $HOME/DisplayAusgabe`

if [ $DISPLAY = $Rueckgabe ];then
   /usr/bin/Xdialog --title "Hinweis" \
                    --infobox "Xdialog initialisiert (OK)." 6 35 4000
else
   /usr/bin/Xdialog --title "Warnung" \
                    --msgbox "ACHTUNG! DisplayAusgabe fehlerhaft gesetzt. \
                      $DISPLAY = $Rueckgabe" 0 0
fi

exit 0
