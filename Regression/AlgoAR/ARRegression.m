function ARRegression(settings, index)
[parent, ~, ~] = fileparts(settings.pathList{index});
[~, foldername, ~] = fileparts(parent);
basePath = [settings.HOME '/PreviouslyProcessedFiles/' settings.algo '/' foldername];
accelData = [basePath '/Accel_Data_Scaled_Resampled.csv'];
algoOutput = [settings.output 'Regression_Algorithm'];
%Step III in Flow Chart: Data in algorithm format to algorithm decision output
algoOutput = ARRegressionAlgo(accelData, algoOutput);
fprintf('Completed Regression Algorithm Module\n');

%Step V in Flow Chart: Algorithm decision to confusion & transition matrix generation
smartGt = [basePath '/Smart_GroundTruth_Tag_Data.csv'];
[Algorithm_Accuracy] = ARResultProcess(algoOutput, smartGt, settings, index);
fprintf('Completed Result Processing Module\n');

fprintf('Completed Regression Analysis.\n');
    
fprintf('Accuracy is : %.2f\n\n', Algorithm_Accuracy);
end
