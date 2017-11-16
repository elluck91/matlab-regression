function smartGT = Module_GroundTruth_Processing(stPdr, algo, outputDir, gt)
    API_Folder_Creation(outputDir,'GroundTruth_Processing');
    outputDirThis = [outputDir '/GroundTruth_Processing'];

    switch algo
        case 'AR'
             accelData=strcat(outputDir,'/Data_Preprocessing','/AccelData.csv');
             smartTag = smartTagGenerator(accelData, outputDirThis);
             smartGT = ARsmartGTCreation(gt, smartTag);
        case 'CP'
            accelData=strcat(outputDir,'/Data_Preprocessing','/AccelData.csv');
            smartTag = smartTagGenerator(accelData, outputDirThis);
            smartGT = CPsmartGTCreation(gt, smartTag);
        case 'SD'
            %accelData = strcat(outputDir,'/Data_Preprocessing','/AccelData.csv');
            %smartTag = smartTagGenerator(accelData, outputDirThis);
            smartGT = SDgtCreator(gt, outputDirThis);
    end

end

