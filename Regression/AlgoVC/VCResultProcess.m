function VCResultProcess(settings, index, result_percent, GTfloorCount, floorsCounted, verticalContextGT, GTMatrix)
    field1='accuracy'; val1 = result_percent;
    field2='inputAddr'; val2 = settings.pathList{index};
    field3='gt'; val3 = GTMatrix;
    field4 = 'accuracyLogFile'; val4 = [settings.output 'AccuracyLog.csv'];
    field5 = 'GTfloorCount'; val5 = GTfloorCount;
    field6 = 'floorsCounted'; val6 = floorsCounted;
    field7 = 'verticalContextGT'; val7 = verticalContextGT;
    algorithmData = struct(field1, val1, field2, val2, field3, val3, field4, val4, field5, val5, field6, val6, field7, val7);
    logVCAccuracy(algorithmData);
end