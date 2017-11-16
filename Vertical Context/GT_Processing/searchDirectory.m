function files = searchDirectory(path)
    files = [];
    if isdir(path)
        subfolderlist=strsplit(genpath(path),';');
        Logfilecount=0;

        [~,Folder_Count]=size(subfolderlist);
        for Folder_No=1:Folder_Count-1; % for parent folder & all sub folders in the parent folder
            Subfolder_Address=subfolderlist{Folder_No}; % copy the address of this subfolder
            Subfolder_Contents=dir(Subfolder_Address); %list the contents of the selected folder
            for Subfolder_No=3:length(Subfolder_Contents) % start with 3 to exclude parent folder
                %Check for files in the selected subfolder
                if ~Subfolder_Contents(Subfolder_No).isdir
                    if strmatch(Subfolder_Contents(Subfolder_No).name, 'ST_PDR_Log.txt')
                        Logfilecount=Logfilecount+1;
                        files{Logfilecount}=strcat(Subfolder_Address,'\',Subfolder_Contents(Subfolder_No).name);
                    end         
                end
            end
        end
    end
end