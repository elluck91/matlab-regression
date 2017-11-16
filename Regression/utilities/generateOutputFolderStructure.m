function settings = generateOutputFolderStructure(settings)
%GENERATEFOLDERSTRUCTURE
% Function maintaining correct Output folder structure of the project
% -- Regression
% ---- Output
% ------ UserName
% -------- uniqueId
% ---------- Data_Processing
% ---------- GroundTruth_Processing
% ---------- Regression_Algorithm
% ---------- Result_Processing
    HOME = settings.HOME;
    userName = settings.userName;
    uniqueId = settings.uniqueId;
    algo = settings.algo;
    
    basePath = ['Output/' userName '/' uniqueId '/'];
    status = API_Folder_Creation(HOME, basePath);
    
    if ~status
        basePath = 0;
    end
        
    if ~strcmp(algo, 'VC')
        API_Folder_Creation(basePath,'Data_Preprocessing');
        API_Folder_Creation(basePath,'GroundTruth_Processing');
        API_Folder_Creation(basePath,'Regression_Algorithm');
        API_Folder_Creation(basePath,'Result_Processing');
    else
        API_Folder_Creation(basePath,'Result_Processing');
    end
    
    settings.output = [HOME '/' basePath];

end

