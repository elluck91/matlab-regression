function timestamps = SDAlgorithmTimestampCreator(algoOutput, results)
Samplingtime = 20; % time in milliseconds
finput = load(algoOutput, '-mat');
timestamps = [results '/Algorithm_Decision_Timestamp_Data.csv'];
Timestamp = 0;
dataToWrite = zeros(length(finput), 2);
for i = 1:length(finput.algoOutput)
    dataToWrite(i, 1) = Timestamp;
    dataToWrite(i, 2) = finput.algoOutput(i);
    Timestamp = Timestamp + Samplingtime;
end
save(timestamps, 'dataToWrite');
end