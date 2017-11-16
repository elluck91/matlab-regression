function [accuracy] = ARResultProcess(algoOutput, smartGt, settings, index)
global combinedMatrix;
results = [settings.output 'Result_Processing'];

%API 5.2: Algorithm Timestamp Creation
timestamps = ARAlgorithmTimestampsCreator(algoOutput, results);

%API 5.3: Algorithm_Smart_GT_Comparison
%[smartActivity, gt] = ARGTCheck(timestamps, smartGt, results);
[smartActivity, gt] = OptimizedARGTCheck(timestamps, smartGt, results);

%API 5.4: Metrics_Generation
[matrix, combinedMatrix] = ARMetricsGen(smartActivity, results, gt, settings);

%API 5.5: Accuracy_Calculation   
accuracy = ARAccuracyCalc(matrix, gt);
 
%API 5.6: Accuracy Logging
ARLogger(accuracy, settings, gt, index);

end