function [ algoOutputPath ] = SDRegressionAlgo( accelData, algoOutput )
    algoOutputPath = [algoOutput '/Algorithm_Decision_Output.csv'];
    M3_Algooutput = Pedometer_RunRegression(accelData);
    algoOutput = M3_Algooutput';
    save(algoOutputPath, 'algoOutput');
    fclose('all');
end

