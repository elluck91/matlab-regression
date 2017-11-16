function directories = generatePreviouslyProcessedFolderStructure(settings)
    processedData = '/PreviouslyProcessedFiles';
    arLocation = [processedData '/AR'];
    cpLocation = [processedData '/CP'];
    sdLocation = [processedData '/SD'];
    pdrLocation = [processedData '/PDR'];

    directories =  {processedData, arLocation, cpLocation, sdLocation, pdrLocation};
    
    for i = 1:length(directories)
        if ~exist(directories{i}, 'dir')
            API_Folder_Creation(settings.HOME,directories{i});
        end
    end
end