function Report(settings)
    global output;
    output = settings.output;
    
    close all;
    close all hidden;
    outputDir = [settings.output 'report'];
    options.format = 'html';
    options.showCode = false;
    options.outputDir = outputDir;
            
    switch settings.algo
        case 'AR'
            publish('reportActivity.m', options);
        case 'SD'
            publish('reportStepDetection.m', options);
        case 'CP'
            publish('reportCarryPosition.m', options);
        case 'VC'
            publish('reportVerticalContext.m', options);
    end
    close('all');
    movefile([settings.output 'AccuracyLog.csv'], outputDir);
    zip([settings.output '/results.zip'], outputDir);
    
    
    removeDirectories();
end

function removeDirectories
    global output;
    dataProcessing = [output 'Data_Preprocessing'];
    regressionAlgorithm = [output 'Regression_Algorithm'];
    report = [output 'report'];
    gtProcessing = [output 'GroundTruth_Processing'];
    resProcessing = [output 'Result_Processing'];
    if exist(dataProcessing, 'dir')
        rmdir(dataProcessing, 's');
    end
    
    if exist(regressionAlgorithm, 'dir')
        rmdir(regressionAlgorithm, 's');
    end
    
    if exist(report, 'dir')
        rmdir(report, 's');
    end
    
    if exist(gtProcessing, 'dir')
        rmdir(gtProcessing, 's');
    end
    
    if exist(resProcessing, 'dir')
        rmdir(resProcessing, 's');
    end
    
end