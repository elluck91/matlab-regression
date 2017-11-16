function [gt] = M2_API_ExtractAccelMagAndGyroMsgs(stPdr,outputDir, algo)
gt = 'NA';
outputDir = strcat(outputDir,'/');
fid = fopen(stPdr);
fAcc = fopen([outputDir 'AccelDataMsgs.csv'],'w');

tline = fgetl(fid);
while ischar(tline)
    a = strfind(tline,',');
    messageType = tline(1:a(1)-1);
    if strcmp(messageType,'10201')
        if strcmp(tline(a(4)+1),' ')
            sensorName = tline(a(4)+2:a(5)-1);
        else
            sensorName = tline(a(4)+1:a(5)-1);
        end
        if strcmp(sensorName,'193')
            fprintf(fAcc,[tline '\n']);
        end
    elseif strcmp(messageType,'10504') && strcmp(algo, 'AR')
        gt = tline(a(2)+2:a(3)-1);
    elseif strcmp(messageType,'10505') && strcmp(algo, 'SD')
        gt = tline(a(2)+2:a(3)-1);
    elseif strcmp(messageType,'10508') && strcmp(algo, 'CP')
        gt = tline(a(2)+2:a(3)-1);
    end
    tline = fgetl(fid);
end
fclose(fid);
fclose(fAcc);

if strcmp(gt, 'NA')
    error('Ground Truth data missing in test file. Aborting!')
end

end
