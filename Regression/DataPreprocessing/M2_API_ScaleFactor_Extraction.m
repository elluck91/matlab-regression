function M2_API_ScaleFactor=M2_API_ScaleFactor_Extraction(M2_API_Data_PDR_Format_Address)

fid=fopen(M2_API_Data_PDR_Format_Address);
tline=fgetl(fid);
while ischar(tline)
    a=strfind(tline,',');
    if strcmp(tline(1:a(1)-1),'10102')
        M2_API_ScaleFactor_Accelerometer=str2double(tline(a(8)+2:a(9)-1));
        break;
    end
    tline=fgetl(fid);
end  
M2_API_ScaleFactor=M2_API_ScaleFactor_Accelerometer;
end