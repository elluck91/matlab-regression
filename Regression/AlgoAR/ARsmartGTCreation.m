function smartGtAddr = ARsmartGTCreation(gtCode,smartTagAddr)
smartTag = fopen(smartTagAddr);
smartGtAddr = [fileparts(smartTagAddr) '/Smart_GroundTruth_Tag_Data.csv'];
smartGt = fopen(smartGtAddr,'w');

%Copy first line as it has only column header information
global M4_API_GT_Activity_Output_Code;

switch gtCode
    case '0'
        M4_API_GT_Activity_Output_Code='0';
        writeGt(smartTag, smartGt, M4_API_GT_Activity_Output_Code)
    case '1'
        M4_API_GT_Activity_Output_Code='1';
        writeOneGT(M4_API_GT_Activity_Output_Code, smartTagAddr, smartGt);
    case '2'
        M4_API_GT_Activity_Output_Code='1';
        writeOneGT(M4_API_GT_Activity_Output_Code, smartTagAddr, smartGt);
    case '3'
        M4_API_GT_Activity_Output_Code='1';
        writeOneGT(M4_API_GT_Activity_Output_Code, smartTagAddr, smartGt);
    case '4'
        M4_API_GT_Activity_Output_Code='2';
        writeGt(smartTag, smartGt, M4_API_GT_Activity_Output_Code);
    case '5'
        M4_API_GT_Activity_Output_Code='3';
        writeGt(smartTag, smartGt, M4_API_GT_Activity_Output_Code);
    case '6'
        M4_API_GT_Activity_Output_Code='4';
        writeGt(smartTag, smartGt, M4_API_GT_Activity_Output_Code);
    case '7'
        M4_API_GT_Activity_Output_Code = '5';
        writeOneGT(M4_API_GT_Activity_Output_Code, smartTagAddr, smartGt);
    case '8'
        M4_API_GT_Activity_Output_Code = '5';
        writeOneGT(M4_API_GT_Activity_Output_Code, smartTagAddr, smartGt);
    case '9'
        M4_API_GT_Activity_Output_Code = '6';
        writeOneGT(M4_API_GT_Activity_Output_Code, smartTagAddr, smartGt);
    case '10'
        M4_API_GT_Activity_Output_Code = '6';
        writeOneGT(M4_API_GT_Activity_Output_Code, smartTagAddr, smartGt);
    otherwise
        M4_API_GT_Activity_Output_Code='NA';
        error(['Unknown input GT: ' M4_API_GT_Activity_Output_Code ' Check input dataset Msg: 10504']);
end

fclose('all');
end

function writeGt(smartTag, smartGt, gtCode)
    tline=fgetl(smartTag);
    outputline=tline;
    % disabled headers
    %fprintf(smartGt,outputline);
    %fprintf(smartGt,'\n');

    tline=fgetl(smartTag);
    while(ischar(tline))
        outputline=tline;
        a=strfind(outputline,',');
        if outputline(a(1)+2)=='1'
            outputline(a(1)+2) = num2str(gtCode);
        else
            outputline(a(1)+2) = '1';
        end
        fprintf(smartGt,outputline);
        fprintf(smartGt,'\n');
        tline=fgetl(smartTag);
    end
end

function writeOneGT(gtCode, smartTag, smartGt)
    gtCode = str2num(gtCode);
    data = importdata(smartTag);
    % disabled header
    %fprintf(smartGt, '%s\n', cell2mat(data.textdata));
    msgId = data.data(1,1);
    startTag = data.data(1, 3);
    stopTag = data.data(end, end);
    fprintf(smartGt, '%d, %d, %d, %d,\n', msgId, gtCode, startTag, stopTag);
end