function Stepcount = Pedometer_RunRegression(M3_Data_Algorithm_Format_Address)

%Load the data from the file and create a result file
AccelData=load(M3_Data_Algorithm_Format_Address, '-mat');


%Reset the step detection module
[ state ] = ResetStepDetectionModule;

%Feed the step detection module sample by sample
dataLength = length(AccelData.M2_API_Accel_Scaled_Resampled_Data(:,2));

normAcc = sqrt(AccelData.M2_API_Accel_Scaled_Resampled_Data(:,1).^2+AccelData.M2_API_Accel_Scaled_Resampled_Data(:,2).^2+AccelData.M2_API_Accel_Scaled_Resampled_Data(:,3).^2);

stepsFound = zeros(dataLength,1);
for i=1:dataLength
    %Load current sensor data
    AccX = AccelData.M2_API_Accel_Scaled_Resampled_Data(i,1); AccY = AccelData.M2_API_Accel_Scaled_Resampled_Data(i,2); AccZ = AccelData.M2_API_Accel_Scaled_Resampled_Data(i,3);
    
    %Run step detection module
    [ state,ifResultedUpdated ] = RunStepDetectionModuleRegression( state, AccX, AccY, AccZ);
    
    %If results are updated, then get the results
    if ifResultedUpdated == 1
        [ totalSteps, ~, stepsInfo] = GetStepDetectionResults( state );
        
        for j=1:length(stepsInfo)
            stepsFound(round(stepsInfo(j).time/50)) = normAcc(round(stepsInfo(j).time/50));
        end
        
        %Print the output here
        Stepcount(i)=totalSteps;
    end
end

%Cadence using step event
lastStepFound = 1;
for i=1:length(stepsFound)
    if stepsFound(i)~=0
        stepDuration(lastStepFound:i) = i-lastStepFound;
        lastStepFound = i;
    end
end
    