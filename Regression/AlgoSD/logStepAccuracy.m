function logStepAccuracy(algorithmData)
    if ~exist(algorithmData.accuracyLogFile,'file')
            fid = fopen(algorithmData.accuracyLogFile,'w');
            header = 'FileName, Timestamp, Step Count, Ground Truth Count, Accuracy, Error \n';
            fprintf(fid, header);
    else
        fid = fopen(algorithmData.accuracyLogFile,'a+');
    end

    fileContent = importdata(algorithmData.accuracyLogFile);
    
    if iscell(fileContent)
        fprintf(fid,'%s, %s, %d, %d, %.2f, %.2f \n', ...
            algorithmData.inputAddr, datestr(clock), algorithmData.accuracy(1, 1), ...
            algorithmData.gt, algorithmData.accuracy(1, 2), 100 - algorithmData.accuracy(1, 2));
    elseif ~any(strcmp(fileContent.textdata,algorithmData.inputAddr))
        fprintf(fid,'%s, %s, %d, %d, %.2f, %.2f \n', ...
            algorithmData.inputAddr, datestr(clock), algorithmData.accuracy(1, 1), ...
            algorithmData.gt, algorithmData.accuracy(1, 2), 100 - algorithmData.accuracy(1, 2));
    end
    fclose(fid);
end
