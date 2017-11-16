USERNAME=$1
DIRPATH='../Output/'$USERNAME'/'
FILE="/results.zip"
for d in $DIRPATH*; do
   if [ -f $d$FILE ]
   then
      echo $d;
   fi
done
