function algoOutputPath = CPRegressionAlgo(accelData, algoOutput)

    algoOutputPath = [algoOutput '/Algorithm_Decision_Output.csv'];

    M3_Accel_Data = importdata(accelData);
    AccX=M3_Accel_Data(:,1);
    AccY=M3_Accel_Data(:,2);
    AccZ=M3_Accel_Data(:,3);
    Noofsamples = length(AccX);

    %For activity detection & carry position Algo
    M3_Algooutput = zeros(1, Noofsamples);
    for SampleNo=1:Noofsamples
        [Algocarrypositioncode, ~] = CarryPositionRecognizerFunction(AccX(SampleNo), AccY(SampleNo), AccZ(SampleNo) , SampleNo);
        M3_Algooutput(SampleNo) = Algocarrypositioncode;
    end
    
    algoOutput = M3_Algooutput';
    save(algoOutputPath, 'algoOutput');
    fclose('all');



end
