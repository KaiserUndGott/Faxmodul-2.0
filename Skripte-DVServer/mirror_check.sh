#!/bin/bash
#
# Script zur Verfuegbarkeitspruefung der Spiegelfestplatte.
# Bestandteil des DavdiX Mirror-Tools.
# Zum stündlichen Aufruf per cron.
#
# DavdiX conputer (FBW) - Oktober 2007
# Version 1.0
#
#
#
# Bitte ggf. anpassen: #################################################
#
root_mirror=/mnt/mirror_root              # Mountpoint 1 (Rootpartition)
home_mirror=/mnt/mirror_home              # Mountpoint 2 (Homepartition)
tool=/home/install/skripte/notify.sh      # Tool fuer Hinweisversand
warn=david@localhost                      # User fuer Mailempfang
#
# ######################################################################
#
#
#
#
# Let´s go
#
#
# Ist die zweite HDD im System?
echo ""
if [ "`cat /proc/partitions | grep sdb`" -a "`mount | grep $root_mirror`" -a "`mount | grep $home_mirror`" ]; then
   echo "Spielgel der Root Partition ok."
else
   text="Festplattenpruefung dringend erforderlich, bitte Speedpoint anrufen!"
   echo $text
   $tool -m "$text"
   echo $text | mail -s "Festplattenwarnung" $warn
   echo ""
   exit 1 
fi
#
exit 0
