function ARLogger(accuracy, settings, gt, index)

    field1='accuracy'; val1 = accuracy;
    field2='inputAddr'; val2 = settings.pathList{index};
    field3='gt'; val3 = gt;
    field4 = 'accuracyLogFile'; val4 = [settings.output 'AccuracyLog.csv'];
    algorithmData = struct(field1, val1, field2, val2, field3, val3, field4, val4);
    logActivityAccuracy(algorithmData);
end