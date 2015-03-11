
# -----------------------------------------------------------------------
# Programm kopiert eine Datei oder einen Ordner in alle User.
#
# Programm muss als root ausgeführt werden!
# 
# Uebergabeparameter:
# $1 = Dateiname
# $2 = Zielpfad im Userverzeichnis. Das Userverzeichnis wird automatisch
#      davorgesetzt.
# Beispiel: $2 = .kde/share/apps
#           kopiert wird $1 nach /home/ALLE_USER/.kde/share/apps
#
# $1 kann mit oder ohne Pfadangabe sein.
# Ohne Pfadangabe = aktuelles Verzeichnis
# -----------------------------------------------------------------------

clear

[ "`id -u`" = "0" ] || { echo "Programm muss als root ausgefuehrt werden.
Abbruch.
Weiter mit Return...";read dummy; exit; }

if [ -z "$1" -o -z "$2" ]; then
   echo "

   zu wenig Uebergabeparameter. Erwartet wird:
   Parameter 1 = zu kopierende Datei oder Ordner
   Parameter 2 = Zielpfad im Userverzeichnis, z.B. .kde/share/apps 
   Abbruch

   Weiter mit Return...
"
   read dummy
   exit
fi

if [ "`echo $2|cut -c1`" = "/" -o "`echo $2|tail -c2`" = "/" ]; then
   echo "
   Parameter 2 (Zielpfad) darf nicht mit einem / beginnen oder enden!
   Abbruch

   Weiter mit Return...
"
   read dummy
   exit
fi

if [ ! -e "$1" ]; then
   echo "
   Kann die zu kopierende Datei (Parameter 1) nicht finden.
   Abbruch

   Weiter mit Return...
"
   read dummy
   exit
fi

# if [ ! -e "/home/david/$2" ]; then
#    echo "
#    Der angegebene Zielpfad im Userverzeichnis existiert nicht.
#    Abbruch
# 
#    Weiter mit Return...
# "
#    read dummy
#    exit
# fi

for i in `ls /home`; do
   u=`cat /etc/passwd|awk '{FS=":"}{print $1}'|fgrep -w "$i"`
   if [ -n "$u" ]; then
      mkdir -p /home/$u/$2
      cp -rpvf $1 /home/$u/$2 
      chown -R $u:users /home/$u/$2
   fi
done
echo "

Fertig.
"
#Weiter mit Return...
#"
#read dummy

exit 0
