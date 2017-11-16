function storeData(file, dataToCreate, index, algo)    
    % Get the name of the folder of the ST_PDR_Log file
    [folderPath, ~, ~] = fileparts(dataToCreate{index});
    [~, folderName, ~] = fileparts(folderPath);
    % Name of the file to transfer
    [~, fileName, ext] = fileparts(file);
    
    
    % Move the file to the PreviouslyProcessedFiles dir
    previouslyProcessedFiles = [pwd '/PreviouslyProcessedFiles/' algo '/' folderName '/' fileName ext];
    status = API_Folder_Creation([pwd '/PreviouslyProcessedFiles/' algo], folderName);
    
    copyfile(file, previouslyProcessedFiles);
end