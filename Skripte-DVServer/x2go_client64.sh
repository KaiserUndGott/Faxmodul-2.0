#!/bin/bash
LOG=/tmp/x2go_client64.log
rpm -i --force --nodeps x2go/client/sl63_64/*.rpm
cd x2go
rpm -i --force --nodeps libjpeg-turbo-1.2.1-3.el6_5.i686.rpm libjpeg-turbo-1.2.1-3.el6_5.x86_64.rpm libXcomp-3.5.0.22-1.el6.x86_64.rpm nx-libs-3.5.0.22-1.el6.x86_64.rpm  nxagent-3.5.0.22-1.el6.x86_64.rpm nxproxy-3.5.0.22-1.el6.x86_64.rpm > $LOG 2>&1
