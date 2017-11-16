% This function returns the following information:
% Dataset,  Algorithm,   Accuracy
% & stores it in the folder defined for output: (Output_Data_Address)

function accuracyLogAddr = M5_API_Accuracy_Logging(accuracy, algo, stPdr, gtCode)
global uniqueId;

field1='accuracy'; val1 = accuracy;
field2='inputAddr'; val2 = stPdr;
field3='gt'; val3 = gtCode;
field4 = 'accuracyLogFile'; val4 = [Output_Data_Address '/' uniqueId algo '_AccuracyLog.csv'];
algorithmData = struct(field1, val1, field2, val2, field3, val3, field4, val4);
accuracyLogAddr = val4;
switch algo
    case 'ActivityRecognition'
        logActivityAccuracy(algorithmData);
    case 'StepDetection'
        logStepAccuracy(algorithmData);
    case 'CarryPosition'
        logCarryPositionAccuracy(algorithmData);
end
    

