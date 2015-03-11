#!/bin/bash
LOG=/tmp/x2go_install.log
rpm -e freenx-server > $LOG 2>&1
rpm -e nx >> $LOG 2>&1
rpm -i --force --nodeps x2go/*.rpm  >> $LOG 2>&1
cp -v skripte/gnome.sh /usr/local/bin  >> $LOG 2>&1
chmod 755  /usr/local/bin/gnome.sh  >> $LOG 2>&1
mkdir /home/david/trpword/x2go_clients >> $LOG 2>&1
cp x2go/client/* /home/david/trpword/x2go_clients >> $LOG 2>&1
