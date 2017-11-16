ALGO=$1
USER=$2
STATUS=$3
PATH=$4
#"C:/MATLAB2014b/bin/matlab.exe" -logfile "public/javascripts/"$STATUS".txt" -nodisplay -nosplash -nodesktop -r "Regression_Framework indir $PATH Algo $ALGO user $USER; close all; exit"

"C:/MATLAB2014b/bin/matlab.exe" -logfile "status/$STATUS.txt" -nodisplay -nosplash -nodesktop -r "Regression_Framework indir $PATH Algo $ALGO user $USER; close all; exit"
