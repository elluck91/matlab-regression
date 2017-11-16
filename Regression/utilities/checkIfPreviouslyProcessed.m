% Returns a cell with unprocessed data files
function [dataCreated, dataExisting] = checkIfPreviouslyProcessed(settings)
    algo = settings.algo;
    
    if ~(strcmp(algo, 'AR') ...
            || strcmp(algo, 'CP') ...
            || strcmp(algo, 'SD') ...
            || strcmp(algo, 'PDR') ...
            || strcmp(algo, 'VC'))
        error('Algorithm not recognized. Please enter correct algorithm.')
    end
    
    [dataCreated, dataExisting] = listUnprocessedFiles(settings);

end

function [dataToCreate, dataExisting] = listUnprocessedFiles(settings)
    dataToCreate = [];
    dataExisting = [];
    paths = settings.pathList;
    
    precessedDataFolder = [settings.HOME '/PreviouslyProcessedFiles/' settings.algo];
    if ~exist(precessedDataFolder, 'dir')
        generatePreviouslyProcessedFolderStructure(settings);
        for i = 1:length(paths)
            dataToCreate{i} = paths{i};
        end
        return;
    else
        for i = 1:length(paths)
            if ~fopen(paths{i})
                fprintf('%s \n', 'Supplied file does not contain ST_PDR_Log.txt');
                fclose('all');
            else
                [pathName, ~, ~] = fileparts(paths{i});
                [~, folderName, ~] = fileparts(pathName);
                
                if ~strcmp(settings.algo, 'VC')
                    accelFile = [precessedDataFolder '/' folderName '/Accel_Data_Scaled_Resampled.csv'];
                    gtFile = [precessedDataFolder '/' folderName '/Smart_GroundTruth_Tag_Data.csv'];
                else
                    accelFile = [precessedDataFolder '/' folderName '/mergedData.csv'];
                    gtFloors = [precessedDataFolder '/' folderName '/floorCount.csv'];
                    gtContext = [precessedDataFolder '/' folderName '/verticalContext.csv'];
                end

                
                if  ~strcmp(settings.algo, 'VC')
                    if ~(exist(accelFile, 'file') && exist(gtFile, 'file'))
                        dataToCreate{length(dataToCreate) + 1} = [paths{i}];
                    else
                        dataExisting{length(dataExisting) + 1} = [paths{i}];
                    end
                elseif strcmp(settings.algo, 'VC')
                    if ~(exist(accelFile, 'file') && exist(gtFloors, 'file') && exist(gtContext, 'file'))
                        dataToCreate{length(dataToCreate) + 1} = [paths{i}];
                    else
                        fprintf('File %i already exists.\n', i);
                        dataExisting{length(dataExisting) + 1} = [paths{i}];
                    end
                    
                end 
                    

            end
        end
    end
    
    
end