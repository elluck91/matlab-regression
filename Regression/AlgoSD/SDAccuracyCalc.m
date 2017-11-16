function accuracy = SDAccuracyCalc(gt,stepCount,results)
    % global Output_Data_Address;
    fid = fopen([results '\StepDetection_Results.csv'],'w');
    Constant_Error = abs(gt-stepCount);
    Systematic_Error = Constant_Error/gt*100;
    fprintf(fid,'Constant Error :%.2f steps\n,Systematic Error : %.2f%%',Constant_Error,Systematic_Error);
    Algo_Accuracy = 100-Systematic_Error;
    accuracy(1, 1) = stepCount;
    accuracy(1, 2) = Algo_Accuracy;
    fclose('all');
end