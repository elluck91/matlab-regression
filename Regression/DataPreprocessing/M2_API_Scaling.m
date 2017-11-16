function M2_API_Accel_Scaled_Data_Address = M2_API_Scaling(M2_API_Accel_Data_Address,M2_API_Folder_Address,M2_API_RCAlgorithm,M2_API_ScaleFactor,M2_API_Accel_Sampling_Rate)

% if input for algo is in g, otherwise it has to be multiplied by 9.8
M2_API_Scaletomps2=M2_API_ScaleFactor;
M2_API_Accel_Data=importdata(M2_API_Accel_Data_Address);
%Samplingtime=median(diff(M2_API_Accel_Data.data(:,1)));
Samplingtime=median(diff(M2_API_Accel_Data(:,1)));
%check if difference in sampling time & given sampletime from 10102 msg
%have>10% deviation
if Samplingtime-1/M2_API_Accel_Sampling_Rate*1000>100/M2_API_Accel_Sampling_Rate
    error('Samplingtime from AccelData.txt not same as mentioned in Msg:10102');
end
%M2_API_Accel_Data=M2_API_Scaletomps2*M2_API_Accel_Data.data;
M2_API_Accel_Data=M2_API_Scaletomps2*M2_API_Accel_Data;
%csvwrite([M2_API_Folder_Address '/Accel_Data_Scaled.csv'],M2_API_Accel_Data);
save([M2_API_Folder_Address '/Accel_Data_Scaled.csv'],'M2_API_Accel_Data');
M2_API_Accel_Scaled_Data_Address=[M2_API_Folder_Address '/Accel_Data_Scaled.csv'];


end