% You could run the Regression Framework like this:
% Regression_Framework('indir','C:\MATLAB\Regression_framework\Test_Data\Input\Stridelength\Antonio\20160620_161709', 'Algo', 'ActivityRecognition', 'user', 'the-actual-username')

% Remember that Regression_Framework accepts a csv file with paths to
% ST_PDR_log files, NOT the filepaths themselve
function Regression_Framework(varargin)
    close all;
    warning('off','all');
    
    % The same user may upload multiple files, we need to distinguish
    % between them, therefore we generate a unique name for each Output
    format shortg;
    c = clock;
    uniqueId = [num2str(c(1,1)) '_' num2str(c(1,2)) '_' num2str(c(1,3)) '_' num2str(c(1,4)) '_' num2str(c(1,5)) '_'];    
    
    %Store the input arguments
    for n=1:2:nargin
        switch varargin{n}
            case 'indir'
                input  = varargin{n+1};
            case 'Algo'
                algo = varargin{n+1};
            case 'user'
                userName = varargin{n+1};
            otherwise
                error('Unknown argument input.')
        end
    end
    
    paths = importdata(input);
    
    for i = 1:length(paths)
        if strcmp(paths{i}(1:2),'..')
            paths{i} = paths{i}(4:end);
        end
    end
    
    settings = emptySettings();
    settings.HOME = pwd;
    settings.algo = algo;
    settings.pathList = cellstr(paths);
    settings.userName = userName;
    settings.uniqueId = [uniqueId algo];
    
    %generateUserUploadsFolderStructure(settings);
    settings = generateOutputFolderStructure(settings);
    
    if isempty(settings.output)
        error('Folder structure could not be created.');
    end
    
    fprintf('Regression scheduled for %d files.\n', length(paths));
    
    [dataToCreate, dataExisting] = checkIfPreviouslyProcessed(settings);
    if ~strcmp(algo, 'VC') && ~isempty(dataToCreate)
        createdFiles = createFile(settings, dataToCreate);
    elseif ~isempty(dataToCreate)
        createdFiles = createVCFile(settings, dataToCreate);
    else
        createdFiles = [];
    end
    
     dataToRegression = [dataExisting createdFiles];
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call the RegressionAlgorithm
    numOfFiles = length(dataToRegression);
    for i = 1:numOfFiles
        fprintf('Regression started for %i of %i files\n', i, numOfFiles);
        try
            if strcmp(algo, 'AR')
                ARRegression(settings, i);
            elseif strcmp(algo, 'SD')
                SDRegression(settings, i);
            elseif strcmp(algo, 'CP')
                CPRegression(settings, i);
            elseif strcmp(algo, 'VC')
                vertical_context(settings, i);
            end
        catch e
            disp(e.message)
        end
    end
    
    if ~isempty(dataToRegression)
        Report(settings);
        reportGenerated = settings.output;
    else
        reportGenerated = '0';
    end
    
    
    
    % Determine how long it took to process all the data
    endTime = clock;
    timeElapsed = endTime - c;
    formattedTimeElapsed = [' Hours: ' num2str(timeElapsed(1,4)) ' Minutes: ' num2str(timeElapsed(1,5)) ' Seconds: ' num2str(abs(timeElapsed(1,6)))];
    fprintf('Elapsed time: %s', formattedTimeElapsed);
    fprintf('\nFinished\n');
    fprintf('%s', reportGenerated);
    
end

