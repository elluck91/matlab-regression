PATH=$1
FILE="/ST_PDR_Log.txt"
COUNT=0;
for d in $PATH*; do
   if [ -f $d$FILE ]
   then
      COUNT=$((COUNT+1));
   fi
done

echo $COUNT;
