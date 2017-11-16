function generateUserUploadsFolderStructure(settings)
    userUploads = '/UserUploads';
    arLocation = [userUploads '/AR'];
    cpLocation = [userUploads '/CP'];
    sdLocation = [userUploads '/SD'];
    pdrLocation = [userUploads '/PDR'];
    vcLocation = [userUploads '/VC'];

    directories =  {userUploads, arLocation, cpLocation, sdLocation, pdrLocation, vcLocation};
    
    for i = 1:length(directories)
        if ~exist(directories{i}, 'dir')
            API_Folder_Creation(settings.HOME,directories{i});
        end
    end
end