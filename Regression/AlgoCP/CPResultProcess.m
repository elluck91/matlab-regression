function [accuracy] = CPResultProcess(algoOutput, smartGt, settings, index)
global combinedMatrix;
results = [settings.output 'Result_Processing'];

%API 5.2: Algorithm Timestamp Creation
timestamps = CPAlgorithmTimestampsCreator(algoOutput, results);

%API 5.3: Algorithm_Smart_GT_Comparison
[smartActivity, gt] = CPGTCheck(timestamps, smartGt, results);

%API 5.4: Metrics_Generation
[matrix, combinedMatrix] = CPMetricsGen(smartActivity, results, gt, settings);

%API 5.5: Accuracy_Calculation   
accuracy = CPAccuracyCalc(matrix, gt);
 
%API 5.6: Accuracy Logging
CPLogger(accuracy, settings, gt, index);

end