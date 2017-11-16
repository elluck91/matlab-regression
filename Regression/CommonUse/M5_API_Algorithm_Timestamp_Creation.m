function M5_Algorithm_Decision_Timestamp_Data_Address=M5_API_Algorithm_Timestamp_Creation(M5_API_Algorithm_Decision_Address,M5_API_RCAlgorithm,M5_API_Folder_Address)

%Define sampletime depending on the algorithm selected
if strcmp(M5_API_RCAlgorithm,'ActivityRecognition')
    Samplingtime=62.5; % time in milliseconds
elseif strcmp(M5_API_RCAlgorithm,'CarryPosition')
    Samplingtime=20; %time in milliseconds
elseif strcmp(M5_API_RCAlgorithm,'StepDetection')
    Samplingtime=20; %time in milliseconds
end

%Activity Code--> Timestamp, Activity Code
%Traverse the activity code file and append the timestamp for each code
%Create and open the input files: activity code & modified activity code
finput=fopen(M5_API_Algorithm_Decision_Address);
M5_Algorithm_Decision_Timestamp_Data_Address=[M5_API_Folder_Address '/Algorithm_Decision_Timestamp_Data.csv'];
foutput=fopen(M5_Algorithm_Decision_Timestamp_Data_Address,'w');
Timestamp=0;
ipline=fgetl(finput);
while ischar(ipline)
    fprintf(foutput,'%.2f, %d,\n',Timestamp,str2num(ipline));
    Timestamp=Timestamp+Samplingtime;
    ipline=fgetl(finput);
end
fclose('all');
end