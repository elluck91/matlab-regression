function logVCAccuracy(algorithmData)
    if ~strcmp(algorithmData.verticalContextGT,'NA')
        if ~exist(algorithmData.accuracyLogFile,'file')
            fid = fopen(algorithmData.accuracyLogFile,'w');
            header = ['FileName, Timestamp, ' ...
                'GT Floor Count, Floors Counted, GT Vertical Context, ' ...
                'Sample Size, Unknown, On Floor, Up/Down, Stairs, Elevator, Escalator, Context Accuracy \n'];
            fprintf(fid, header);

        else
            fid = fopen(algorithmData.accuracyLogFile,'a+');
        end
        
        fileContent = importdata(algorithmData.accuracyLogFile);

        if iscell(fileContent)
            [ algoResults, sampleSize ] = getAlgoResults(fileparts(algorithmData.accuracyLogFile));
            fprintf(fid,'%s, %s, %.2f, %.2f, %d, %d, %d, %d, %d, %d, %d, %d, %.2f\n', ...
                algorithmData.inputAddr, datestr(clock), ...
                algorithmData.GTfloorCount, algorithmData.floorsCounted, ...
                algorithmData.verticalContextGT, sampleSize, algoResults(1, 2), algoResults(1, 3), algoResults(1, 4), algoResults(1, 5), ...
                algoResults(1, 6), algoResults(1, 7), algorithmData.accuracy);
        elseif ~any(strcmp(fileContent.textdata,algorithmData.inputAddr))
            [ algoResults, sampleSize ] = getAlgoResults(fileparts(algorithmData.accuracyLogFile));
            fprintf(fid,'%s, %s, %.2f, %.2f, %d, %d, %d, %d, %d, %d, %d, %d, %.2f\n', ...
                algorithmData.inputAddr, datestr(clock), ...
                algorithmData.GTfloorCount, algorithmData.floorsCounted, ...
                algorithmData.verticalContextGT, sampleSize, algoResults(1, 2), algoResults(1, 3), algoResults(1, 4), algoResults(1, 5), ...
                algoResults(1, 6), algoResults(1, 7), algorithmData.accuracy);
        end
        fclose(fid);
    end
end

function [results, sampleSize] = getAlgoResults(outputDir)
    sampleData = [outputDir '/Result_Processing/ConfusionMatrixAltitude.csv'];
    samples = csvread(sampleData, 1, 1);
    sampleSize = sum(samples(1, :));
    results = zeros(1, length(samples(1, :)));
    for i = 1:length(samples)
        results(1, i) = samples(1, i); 
    end
end