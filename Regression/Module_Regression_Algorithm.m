function M3_Algorithm_Decision_Output_Address = Module_Regression_Algorithm(M3_Data_Algorithm_Format_Address)
%API 3.1
%Calling API_Folder_Creation with Folder_Address & New_Folder_Name to be created as input
Folder_Address=Output_Data_Address;
New_Folder_Name='Regression_Algorithm';
Folder_Creation_Status=API_Folder_Creation(Folder_Address,New_Folder_Name);

if Folder_Creation_Status
    M3_Folder_Address=strcat(Folder_Address,'/',New_Folder_Name);
else
    disp(strcat('error in Module:', New_Folder_Name, ' in creating folder:', New_Folder_Name));
end

switch M3_RCAlgorithm
    case 'ActivityRecognition'
        M3_Accel_Data = importdata(M3_Data_Algorithm_Format_Address);
        AccX=M3_Accel_Data(:,2);
        AccY=M3_Accel_Data(:,3);
        AccZ=M3_Accel_Data(:,4);
        ifReset=1;
        Noofsamples=length(AccX);
    case 'CarryPosition'
        M3_Accel_Data=importdata(M3_Data_Algorithm_Format_Address);
        AccX=M3_Accel_Data(:,2);
        AccY=M3_Accel_Data(:,3);
        AccZ=M3_Accel_Data(:,4);
        Noofsamples=length(AccX);
end

M3_Dataset_Address=strcat(M3_Folder_Address,'/Algorithm_Decision_Output.csv');
Debug_data_Address=strcat(M3_Folder_Address,'/Algo_Debug_Output.csv');
Combined_Debug_data_Address=strcat(fileparts(fileparts(Output_Data_Address)),'/Combined_CarryPos_Debug_Output.csv');
i=1;
%For step detection Algo
if strcmp(M3_RCAlgorithm,'StepDetection')
    M3_Algooutput=Pedometer_RunRegression(M3_Data_Algorithm_Format_Address);

    %For activity detection & carry position Algo
elseif strcmp(M3_RCAlgorithm,'ActivityRecognition') || strcmp(M3_RCAlgorithm,'CarryPosition')
    for SampleNo=1:Noofsamples
        switch M3_RCAlgorithm
            case 'ActivityRecognition'
                Algoactivitycode=ActivityRecognizerFunction(AccX(SampleNo), AccY(SampleNo), AccZ(SampleNo) , ifReset);
                ifReset = 0;
                M3_Algooutput(SampleNo)=Algoactivitycode;
               
            case 'CarryPosition'
                %             Carryalgofolder=[pwd '\CarryPosMatlabCode'];
                %             cd(Carryalgofolder);
                [Algocarrypositioncode,features]=CarryPositionRecognizerFunction(AccX(SampleNo), AccY(SampleNo), AccZ(SampleNo) , SampleNo);
                M3_Algooutput(SampleNo)=Algocarrypositioncode;
                %for debugging
                if sum(features)
                    CarryAlgoData(i,:)=features'; 
                    i=i+1;
                end
        end
    end
end
algoOutput = M3_Algooutput';
save(M3_Dataset_Address,'algoOutput');
if strcmp(M3_RCAlgorithm,'CarryPosition')
    fid=fopen(Debug_data_Address,'w');
    if ~exist(Combined_Debug_data_Address,'file')
        fid2=fopen(Combined_Debug_data_Address,'w');
        fprintf(fid2,'Energies1, Energies2, Energies3, Energies4, Energies5, Energiesnorm1, Energiesnorm2, Energiesnorm3, Energiesnorm4, Energiesnorm5, MeanvalueAccX, MeanvalueAccY, MeanvalueAccZ, Roll, Pitch, p2pvalue, Var\n');
    else
        fid2=fopen(Combined_Debug_data_Address,'a');
    end
    fprintf(fid,'Energies1, Energies2, Energies3, Energies4, Energies5, Energiesnorm1, Energiesnorm2, Energiesnorm3, Energiesnorm4, Energiesnorm5, MeanvalueAccX, MeanvalueAccY, MeanvalueAccZ, Roll, Pitch, p2pvalue, Var');
    fclose(fid);
    fclose(fid2);
    dlmwrite(Debug_data_Address,CarryAlgoData,'roffset',1,'-append');
    dlmwrite(Combined_Debug_data_Address,CarryAlgoData,'-append');
end
fclose('all');
M3_Algorithm_Decision_Output_Address=M3_Dataset_Address;
end

        