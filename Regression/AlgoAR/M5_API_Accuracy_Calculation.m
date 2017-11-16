function M5_API_Algorithm_Activity_Accuracy=M5_API_Accuracy_Calculation(M5_API_Confusion_Matrix_Address,M5_API_GroundTruth_Output_Code)
M5_API_GroundTruth=M5_API_GroundTruth_Output_Code;
M5_API_Conf_Mat=importdata(M5_API_Confusion_Matrix_Address);
M5_API_Conf_Mat_Data=M5_API_Conf_Mat.data;
Is_stationary_data=0;
if strcmp(M5_API_Conf_Mat.textdata(2,1),'Stationary') || ~sum(M5_API_Conf_Mat_Data(1,:))
    Is_stationary_data=1;
end
    
%Access 1st row of confusion matrix if active data or 2nd row if stationary data
M5_API_Conf_Mat_Data_Activity_Sum=sum(M5_API_Conf_Mat_Data(Is_stationary_data+1,:));
M5_API_Algo_Correct_Recognized=M5_API_Conf_Mat_Data(Is_stationary_data+1,floor(str2num(M5_API_GroundTruth))+1);
M5_API_Algorithm_Activity_Accuracy=M5_API_Algo_Correct_Recognized/M5_API_Conf_Mat_Data_Activity_Sum*100;
fid=fopen(M5_API_Confusion_Matrix_Address,'a');
fprintf(fid,'Algorithm Accuracy is %f',M5_API_Algorithm_Activity_Accuracy);
fclose(fid);
end