function SDRegression(settings, index)
[parent, ~, ~] = fileparts(settings.pathList{index});
[~, folder, ~] = fileparts(parent);
basePath = ['PreviouslyProcessedFiles/' settings.algo '/' folder '/'];
accelData = [basePath 'Accel_Data_Scaled_Resampled.csv'];
algoOutput = [settings.output 'Regression_Algorithm'];

%Step III in Flow Chart: Data in algorithm format to algorithm decision output
algoOutput = SDRegressionAlgo(accelData, algoOutput);
fprintf('Completed Regression Algorithm Module\n');

%Step V in Flow Chart: Algorithm decision to confusion & transition matrix generation
smartGt = [basePath 'Smart_GroundTruth_Tag_Data.csv'];
[Algorithm_Accuracy ] = SDResultProcess(algoOutput, smartGt, settings, index);
fprintf('Completed Result Processing Module\n');

fprintf('Completed Regression Analysis for this file\n');
%disp(input);

fprintf('Accuracy is : %.2f\n', Algorithm_Accuracy(1,2));
end