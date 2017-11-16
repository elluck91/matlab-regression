function smartActivity = SDGTCheck(timestamps,smartGt,results)
algo = load(timestamps, '-mat');
gt = load(smartGt);
smartActivity = [results '\SmartActivitycodeprocessed.csv'];
falgogt = fopen(smartActivity,'w');
gtOutput = gt(end, end);
algoOutput = algo.dataToWrite(end, end);
msg = ['10505, ' num2str(gtOutput) ', ' num2str(algoOutput) ','];
fprintf(falgogt,msg);
fclose('all');
end
