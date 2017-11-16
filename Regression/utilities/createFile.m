function createdFiles = createFile(settings, dataToCreate)
%CREATEFILE Utility function executing two modules:
% II Data Preprocessing
% III Ground Truth Generation
% 
% CREATEFILE OVERWRITES DATA IF PREVIOUSLY GENERATED
% To generate only new data, use createNewFile() instead.
    createdFiles = [];
    numOfFiles = length(dataToCreate);
    for i = 1:numOfFiles
        fprintf('Creating file %i / %i.\n', i, numOfFiles);
        try
            %create resampled accel data
            [accData, gt] = DataProcessing(dataToCreate{i}, settings);
            % create smartGT data
            smartGT = Module_GroundTruth_Processing(dataToCreate{i}, settings.algo, settings.output, gt);
            % store Accel and GT in PreviouslyProcessedFiles
            storeData(accData, dataToCreate, i, settings.algo);
            storeData(smartGT, dataToCreate, i, settings.algo);
            createdFiles{length(createdFiles) + 1} = dataToCreate{i};
        catch e
            fprintf('%s \n', e.message);
        end
    end

end

