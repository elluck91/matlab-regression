function Folder_Creation_Status=API_Folder_Creation(Folder_Address,New_Folder_Name)

if ~exist([Folder_Address,'/', New_Folder_Name],'dir')
    Folder_Creation_Status=mkdir(strcat(Folder_Address,'/'),New_Folder_Name);
else
    Folder_Creation_Status=1;
end
if ~Folder_Creation_Status

    disp(strcat('error in creating folder:',mfilename('C:\Data\RegressionFramework\MATLAB Script\API_FolderCreation.m'),'for module:',mfilename('C:\Data\RegressionFramework\MATLAB Script\API_FolderCreation.m')));
end

