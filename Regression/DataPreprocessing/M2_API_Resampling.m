function accResampled=M2_API_Resampling(accelData,algo, samplingRate,outputDir)

accelScaled = importdata(accelData);
switch algo
    case 'AR'
        M2_API_New_Sampling_Rate=16;
    case 'CP'
        M2_API_New_Sampling_Rate=50;
    case 'SD'
        M2_API_New_Sampling_Rate=50;
end

    if M2_API_New_Sampling_Rate <= samplingRate
        %Timestamp=resample(M2_API_Accel_Scaled_Data(:,1),M2_API_New_Sampling_Rate,M2_API_Accel_Sampling_Rate);
        M2_API_AccX=resample(accelScaled(:,2),M2_API_New_Sampling_Rate,samplingRate);
        M2_API_AccY=resample(accelScaled(:,3),M2_API_New_Sampling_Rate,samplingRate);
        M2_API_AccZ=resample(accelScaled(:,4),M2_API_New_Sampling_Rate,samplingRate);
        M2_API_Accel_Scaled_Resampled_Data=[M2_API_AccX M2_API_AccY M2_API_AccZ];
        %csvwrite([outputDir '/Accel_Data_Scaled_Resampled.csv'],M2_API_Accel_Scaled_Resampled_Data);

        save([outputDir '/Accel_Data_Scaled_Resampled.csv'],'M2_API_Accel_Scaled_Resampled_Data');
        accResampled = [outputDir '/Accel_Data_Scaled_Resampled.csv'];
        fclose('all');
    else
        error('dataprocessing.m error: M2_API_Accel_Sampling_Rate less than %dHz', M2_API_New_Sampling_Rate); 
    end
        

end
