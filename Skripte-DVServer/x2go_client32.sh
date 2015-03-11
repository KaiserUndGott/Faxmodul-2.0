#!/bin/bash
LOG=/tmp/x2go_client32.log
rpm -i --force --nodeps x2go/client/sl63_32/*.rpm > $LOG 2>&1
