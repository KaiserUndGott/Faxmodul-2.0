#!/bin/bash
echo "Benutzer anlegen:"
	while true
		do
        	clear
        	echo
		if [ -z "$log" ]; then
        		echo "DV-Benutzer anlegen... [ (b)eenden ]"
		else
        		echo "DV-Benutzer anlegen... [ (b)eenden ]" 2>>$log
		fi
        	echo "--------------------------------------------"
        	echo -n "Anmeldenamen: "
        	read NAME
        	if [ "$NAME" == "b" ]; then
        	        break
        	else
			if [ -z "$DAV_HOME" ]; then
        	        export DAV_HOME=/home/david
			fi
                	/home/david/makesluser $NAME
		fi
	done
