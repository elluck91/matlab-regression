function reportStepDetection()
%% Accuracy Step Detection
% The charts below summarize the results of the Regression Test
    createHistogram();
    createCDF();
    displayLinkToAccuracyLog();

end

function createHistogram()
    global output;
    accuracyLog = importdata([output 'AccuracyLog.csv']);
    
    f1 = figure;
    h1 = histogram(accuracyLog.data(:,4), 'BinEdges',0:100);
    h1.Normalization = 'probability';
    h1.BinWidth = 5;
    grid on
    title('Error % of Test Vectors')
    xlabel('% error')
    ylabel('PDF')
    
    f2 = figure;
    h2 = histogram(accuracyLog.data(:,3), 'BinEdges',0:100);
    h2.Normalization = 'probability';
    h2.BinWidth = 5;
    grid on
    title('Accuracy')
    xlabel('% accuracy')
    ylabel('PDF')
end

function createCDF()
    global output;
    accuracyLog = importdata([output 'AccuracyLog.csv']);
    data = accuracyLog.data(:,3);
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

function displayLinkToAccuracyLog()
%%
% Sample Size in Accuracy Log shows the number of samples in the "active"
% stage.
% To see the individual test breakdown click <AccuracyLog.csv here> .
end