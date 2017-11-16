function reportVerticalContext()
%% Accuracy Activity Recognition
% The charts below summarize the results of the Regression Test
    global combinedMatrix;
    [data, accuracyLog] = createHistogram();
    createCDF(data);
    createHistoramByDataPoints(accuracyLog);
    displayConfusionMatrix(combinedMatrix);
    
    displayLinkToAccuracyLog();
    delete(combinedMatrix);
end

function [data, logFilePath] = createHistogram()
    global output;

    logFilePath = [output 'AccuracyLog.csv'];
    accuracyLog = fopen(logFilePath, 'r');
    
    fgetl(accuracyLog);
    line = fgetl(accuracyLog);
    i = 1;
    while (line ~= -1)
        line = strsplit(line, ',');
        individualAccuracy = line(1, end);
        accuracyList(1, i) = individualAccuracy;
        i = i + 1;
        line = fgetl(accuracyLog);
    end
    
    data = zeros(1, length(accuracyList));
    for j = 1:length(accuracyList)
       data(1, j) = str2double(accuracyList(j)); 
    end
    
    %subplot(3,1,1);
    
    f2 = figure;
    h1 = histogram(data, 'BinEdges',0:100);
    h1.Normalization = 'probability';
    h1.BinWidth = 5;
    grid on
    title('Accuracy of Test Vectors')
    xlabel('Accuracy')
    ylabel('PDF')
    fclose(accuracyLog);
end

function createCDF(data)
    sortedData = sort(data);
    tmp = sort(reshape(data,prod(size(data)),1));
    Xplot = reshape([tmp tmp].',2*length(tmp),1);

    tmp = [1:length(data)].'/length(data);
    Yplot = reshape([tmp tmp].',2*length(tmp),1);
    Yplot = [0; Yplot(1:(end-1))];

    f2 = figure;
    plot(Xplot, Yplot);
    grid on
    title('Cumulative Density Function')
    xlabel('Accuracy')
    ylabel('%')
end

function createHistoramByDataPoints(accuracyLog)
    accuracyLog = fopen(accuracyLog, 'r');
    fgetl(accuracyLog);
    line = fgetl(accuracyLog);
    
    completeData = [];
    while (line ~= -1)
        line = strsplit(line, ',');
        testAccuracy = str2num(cell2mat(line(1, end)));
        testSize = str2num(cell2mat(line(1, 6)));

        lastIndex = length(completeData);
        for k = 1:testSize
            completeData(1, lastIndex + k) = testAccuracy;
        end
        line = fgetl(accuracyLog);
    end
    
    edges = [0:10:100];
    %subplot(3,1,3);
    f3 = figure;
    h2 = histogram(completeData, edges);
    h2.Normalization = 'probability';
    h2.BinWidth = 5;
    grid on
    title('Data Accuracy by Data Point')
    xlabel('Accuracy')
    ylabel('Percentage of Points')
    fclose(accuracyLog);
end

function displayConfusionMatrix(M5_Confusion_Matrix_Address)
    % extracted from combined confusion matrix
    data = csvread(M5_Confusion_Matrix_Address, 1, 1);
    
    for i = 1:length(data)
        rowSumIndex = size(data);
        rowSumIndex = rowSumIndex(1,1);
        data(i, rowSumIndex + 1) = sum(data(i,:));
    end
    
    for i = 1:length(data)-1
        data(length(data), i) = data(i, i);
    end
    
    for row = 1:length(data)-1
        for col = 1:length(data)-1
            if isnan((data(row, col) / data(row, length(data))) * 100)
                data(row, col) = 0;
            else
                data(row, col) = round((data(row, col) / data(row, length(data))) * 100, 2);
            end
        end
    end
    
    data(length(data), length(data)) = sum(data(:, length(data)));
    
    
    f = figure('Position', [0 0 730 420]);
    t =  uitable(f, 'RowName',{'Unknown';'On Floor';'Up/Down';'Stairs';'Elevator';'Escalator'; 'Correct Detection'}, ...
                    'ColumnName', {'Unknown';'On Floor';'Up/Down';'Stairs';'Elevator';'Escalator'; 'Sum'}, ...
                    'data',data,  ...
                    'units', 'normalized', ...
                    'ColumnWidth', {66}, ...
                    'FontS', 12,...
                    'pos', [0 0.3 1 0.5]);
    description = uicontrol('Style','text', ...
        'Position', [0 85 730 40], ...
        'String','Values in the cells display percentage vales. In the bottom row and right-most column the values are a sum of both active and inactive stages of the sample data.');
end

function displayLinkToAccuracyLog()
%%
% Sample Size in Accuracy Log shows the number of samples in the "active"
% stage.
% To see the individual test breakdown click <AccuracyLog.csv here> .

end