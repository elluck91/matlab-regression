IN=$1
DATA="/data.csv"
OUTPUT=$IN$DATA
for d in $IN*;
  do echo $d'/ST_PDR_Log.txt' >> $OUTPUT;
done
