function logActivityAccuracy(algorithmData)
    if ~strcmp(algorithmData.gt,'NA')
        if ~exist(algorithmData.accuracyLogFile,'file')
            fid = fopen(algorithmData.accuracyLogFile,'w');
            header = ['FileName, GroundTruth, ' ...
                'Accuracy, Timestamp, SampleSize, Unknown, ' ...
                'Stationary, Walking, Fastwalking, Jogging, Biking, Driving \n'];
            fprintf(fid, header);

        else
            fid = fopen(algorithmData.accuracyLogFile,'a+');
        end
        
        fileContent = importdata(algorithmData.accuracyLogFile);

        if iscell(fileContent)
            [ algoResults, sampleSize ] = getAlgoResults(fileparts(algorithmData.accuracyLogFile));
            fprintf(fid,'%s, %d, %.2f, %s, %d, %d, %d, %d, %d, %d, %d, %d\n', ...
                algorithmData.inputAddr, algorithmData.gt, ...
                algorithmData.accuracy, datestr(clock), sampleSize, algoResults(1, 1), ...
                algoResults(1, 2), algoResults(1, 3), algoResults(1, 4), algoResults(1, 5), ...
                algoResults(1, 6), algoResults(1, 7));
        elseif ~any(strcmp(fileContent.textdata,algorithmData.inputAddr))
            [ algoResults, sampleSize ] = getAlgoResults(fileparts(algorithmData.accuracyLogFile));
            fprintf(fid,'%s, %d, %.2f, %s, %d, %d, %d, %d, %d, %d, %d, %d\n', ...
                algorithmData.inputAddr, algorithmData.gt, ...
                algorithmData.accuracy, datestr(clock), sampleSize, algoResults(1, 1), ...
                algoResults(1, 2), algoResults(1, 3), algoResults(1, 4), algoResults(1, 5), ...
                algoResults(1, 6), algoResults(1, 7));
        end
        fclose(fid);
    end
end

function [results, sampleSize] = getAlgoResults(outputDir)
    sampleData = [outputDir '/Result_Processing/ConfusionMatrix.csv'];
    samples = csvread(sampleData, 1, 1);
    sampleSize = sum(samples(1, :));
    results = zeros(1, length(samples(1, :)));
    for i = 1:length(samples)
        results(1, i) = samples(1, i); 
    end
end