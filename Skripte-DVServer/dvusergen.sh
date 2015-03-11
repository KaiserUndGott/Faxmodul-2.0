#!/bin/bash


# DV User mit einheitlichen Profilen anlegen.
# Folgende weitere Skripte werden benoetigt:
#    - webercopy.sh
#    - DisplayAusgabe.sh



# ----------------------------------------------------------------------------------
#
minUser=10                                       # erster anzulegender User (platzx)
userpw="david"                                  # gewuenschtes User Passwort
maxUser=20                                      # letzter anzulegender User
webercp="/install/skripte/webercopy.sh"         # Pfad und Name
displ="/install/skripte/DisplayAusgabe.sh"      # Pfad und Name
#
# ----------------------------------------------------------------------------------






# ab hier bitte Finger weg!






# Pruefungen auf Rootrechte:
#
if [ ! "`id -u`" -eq "0" ]; then
   echo "Sorry, nur fuer root ausfuehrbar."
   exit 1
fi

if [ ! -e $webercp ]; then
   echo "ABBRUCH! $webercp nicht gefunden."
   exit 1
fi

#echo ""
#echo "Sabayon Profil angelegt...?  (STRG-C) fuer Abbruch, sonst ENTER"
#read dummy

echo ""
echo "Es werden nun die User $minUser bis $maxUser angelegt. Weiter mit ENTER, sonst (STRG-C)"
read dummy

until [ $minUser -gt $maxUser ];do
      [ $minUser -lt 10 ] && minUser1="0$minUser" || minUser1=$minUser
      export DAV_HOME=/home/david
      /home/david/makedaviduser platz$minUser1
      sed -i '$d' /home/david/david.cfg # nicht benoetigte Zeile aus david.cfg entfernen
      usermod -c "Arbeitsplatz $minUser1"  \
              -g users -G audio,cdrom,dialout,disk,floppy,lp,tty,uucp,video,lock,wheel,tape platz$minUser1
      echo "platz$minUser1:$userpw" >/tmp/userpw.DavidX    
      chpasswd -c DES </tmp/userpw.DavidX
      mkdir -p -m 775 /home/platz$minUser1/Public
      mkdir -p -m 750 /home/platz$minUser1/.Maildir
      mkdir -p /home/platz$minUser1/Desktop
      ln -s /home/david/trpword/Praxisdokumente /home/platz$minUser1/Desktop/Praxisdokumente
      ln -s /home/david/trpword/Praxisdokumente /home/platz$minUser1/Praxisdokumente
      echo "User platz$minUser1 mit PW $userpw angelegt."
      cp $displ /home/platz$minUser1/.DisplayAusgabe.sh
      echo "/home/platz$minUser1/.DisplayAusgabe.sh" >> /home/platz$minUser1/.bash_profile
      echo "export HISTTIMEFORMAT=\"%d.%m.%Y - %H:%M:%S -> \"" >> //home/platz$minUser1/.bashrc
      echo "/home/david/nm.sh &" >> /home/platz$minUser1/.bash_profile
      echo "">>/etc/samba/smb.conf
      echo "[platz$minUser1\$]">>/etc/samba/smb.conf
      echo "	path = /home/david/trpword/.stationen/platz$minUser1">>/etc/samba/smb.conf
      echo "	read only = No">>/etc/samba/smb.conf
      echo "	guest ok = Yes">>/etc/samba/smb.conf
      mkdir /home/david/trpword/.stationen/platz$minUser1 2>/dev/null
      chmod -R 775 /home/david/trpword/.stationen && chown -R david:users /home/david/trpword/.stationen
      cp -pv /home/david/pordner.sh /home/david/pordner_p$minUser1.sh
      cp -pv /home/david/.face /home/platz$minUser1/ && chown platz$minUser1:users /home/platz$minUser1/.face
      cp -r /home/david/.mozilla /home/platz$minUser1/ && chown -R platz$minUser1:users /home/platz$minUser1/.mozilla
      cp /home/install/Desktopsymbole/*.desktop /home/platz$minUser1/Desktop/ && chown -R platz$minUser1:users /home/platz$minUser1/Desktop/*
      #
      minUser=`expr $minUser + 1`
done

cd /home
for arg in platz*
do
	chown -R $arg:users $arg
	chmod -R 755 $arg
done

$webercp /home/david/.local/share/applications .local/share
$webercp /home/david/.gconf/apps .gconf
$webercp /home/david/.gconf/desktop .gconf
$webercp /home/david/.qt/qtrc .qt
$webercp /home/david/.config/user-dirs.dirs .config
$webercp /home/david/.config/user-dirs.locale .config

for i in `ls -la /home | grep users | awk '{print $NF}'`; do chown -R $i:users /home/$i/.local; done >/dev/null 2>&1
for i in `ls -la /home | grep users | awk '{print $NF}'`; do chown -R $i:users /home/$i/.Maildir; done >/dev/null 2>&1

echo ""
echo "Fertig."
echo "Einzelne User ggf. im XGreeter aus- /einblenden (siehe /root/Desktop/custom.conf)!"
echo "Bei Bedarf Skripte /home/david/pordner_p??.sh anpassen!"
echo ""

rm -f /tmp/userpw.DavidX
service smb restart

echo ""
echo ""
exit 0
