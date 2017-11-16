function [ resampledAccData, gt ] = DataProcessing( dataToProcess, settings )
algo = settings.algo;
outputDir = settings.output;
API_Folder_Creation(outputDir, 'Data_Preprocessing');
outputDir = strcat(outputDir,'/Data_Preprocessing');

%API 2.2
%Get the sampling rate of all sensors
samplingRate = samplingRateCalculation(dataToProcess);

%API 2.3
%Call function to extract PDRformat data messages for accel,mag,gyro
[accData, gt] = M2_API_Sensor_Data_Extraction(dataToProcess,outputDir, algo);

%API 2.4
%Get the scale factor to compute the scaled sensor data
scaleFactor = M2_API_ScaleFactor_Extraction(dataToProcess);

%API 2.5
%Get the scaled data of extracted sensor data messages
scaledData = M2_API_Scaling(accData,outputDir,algo,scaleFactor,samplingRate);

%API 2.6
%Get the resampled data for the algorithm under regression test
resampledAccData = M2_API_Resampling(scaledData,algo, samplingRate,outputDir); 

end

