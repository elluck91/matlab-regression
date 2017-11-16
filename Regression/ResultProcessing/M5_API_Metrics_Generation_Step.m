function [M5_API_Combined_Conf_Matrix_Address, M5_API_GT_StepCount,M5_API_Algo_StepCount] = M5_API_Metrics_Generation_Step(M5_API_SmartActivityCode_Data_Address)
fid=fopen(M5_API_SmartActivityCode_Data_Address);
tline=fgetl(fid);
tline=fgetl(fid);
a=strfind(tline,',');
M5_API_GT_StepCount=tline(a(1)+2:a(2)-1);
M5_API_Algo_StepCount=tline(a(2)+2:a(3)-1);
M5_API_Combined_Conf_Matrix_Address = [];
end