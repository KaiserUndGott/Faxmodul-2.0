#!/bin/bash
# das Skript beseitigt Reste alter NX-Sitzungen auf dem Server
rm -rf /tmp/.nX????-lock \
/tmp/.X????-lock \
/tmp/.tX????-lock \
/tmp/nxclient.* \
/tmp/.esd-???? \
/tmp/.X11-unix/X???? \
/var/lib/nxserver/db/*/* \
/home/*/.nx/*
