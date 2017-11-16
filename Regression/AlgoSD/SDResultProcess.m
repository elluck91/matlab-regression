function accuracy = SDResultProcess(algoOutput, smartGt, settings, index)

results = [settings.output '/Result_Processing'];

%API 5.2: Algorithm Timestamp Creation
timestamps = SDAlgorithmTimestampCreator(algoOutput, results);

%API 5.3: Algorithm_Smart_GT_Comparison
smartActivity = SDGTCheck(timestamps, smartGt, results);

%API 5.4: Metrics_Generation
[gt, stepCount] = SDMetricsGen(smartActivity);

%API 5.5: Accuracy_Calculation   
accuracy = SDAccuracyCalc(gt, stepCount, results);
    
%API 5.6: Accuracy Logging
SDLogger(accuracy, settings, gt, index);

end


