function smartGtAddr = CPsmartGTCreation(gtCode,smartTagAddr)
smartGtAddr = [fileparts(smartTagAddr) '/Smart_GroundTruth_Tag_Data.csv'];
smartGt = fopen(smartGtAddr,'w');

%Copy first line as it has only column header information
global gt;

% This switch case is incorrect. The activity code is entered manually
% when selecting interval

switch gtCode
    case '0'
        gt='0';
        writeGt(smartTagAddr, smartGt, gt)
    case '1'
        gt='1';
        writeOneGT(smartTagAddr, smartGt, gt)
    case '2'
        gt='1';
        writeOneGT(smartTagAddr, smartGt, gt)
    case '3'
        gt='2';
        writeGt(smartTagAddr, smartGt, gt)
    case '4'
        gt='6';
        writeGt(smartTagAddr, smartGt, gt)
    case '5'
        gt='6';
        writeGt(smartTagAddr, smartGt, gt)
    case '6'
        gt='3';
        writeGt(smartTagAddr, smartGt, gt)
    case '7'
        gt = '5';
        writeGt(smartTagAddr, smartGt, gt)
    case '8'
        gt = '5';
        writeGt(smartTagAddr, smartGt, gt)
    case '9'
        gt = '4';
        writeGt(smartTagAddr, smartGt, gt)
    case '11'
        gt = '7';
        writeGt(smartTagAddr, smartGt, gt)
    otherwise
        error(['Unknown input GT: ' gt ' Check input dataset Msg: 10508']);
end

fclose('all');
end

function writeGt(smartTag, smartGt, gtCode)
    smartTag = fopen(smartTag);
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
            outputline(a(1)+2) = '0';
        end
        
        fprintf(smartGt,outputline);
        fprintf(smartGt,'\n');
        tline=fgetl(smartTag);
    end
end

function writeOneGT(smartTag, smartGt, gtCode)
    gtCode = str2num(gtCode);
    data = importdata(smartTag);
    % disabled header
    %fprintf(smartGt, '%s\n', cell2mat(data.textdata));
    msgId = data.data(1,1);
    startTag = data.data(1, 3);
    stopTag = data.data(end, end);
    fprintf(smartGt, '%d, %d, %d, %d,\n', msgId, gtCode, startTag, stopTag);
end