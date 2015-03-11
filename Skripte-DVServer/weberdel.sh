
if [ ! $1 ]; then
   echo "Usage: weberdel.sh [DATEI]"
   exit 1
fi

anz="50"	# höchste Zahl in /home/platzXY

echo ""
echo "*************"
echo "* VORSICHT! *"
echo "*************"
echo "$1 wird rekursiv und unwiderruflich in allen Homeverzeichnissen geloescht!"
echo "Weiter mit ENTER, Abbruch mit STRG-C..."
read dummy

i="1"
while [ $i -le 9 ]; do
   rm -rvf /home/platz0$i/$1 2>>/dev/null
   i=`expr $i + 1`
done

i="10"
while [ $i -le 50 ]; do
   rm -rvf /home/platz$i/$1 2>>/dev/null
   i=`expr $i + 1`
done
echo""

exit 0
