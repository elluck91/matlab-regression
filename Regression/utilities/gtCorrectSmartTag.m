function gtCorrectSmartTag( dirLocation )
    if isdir(dirLocation)
        subfolderlist=strsplit(genpath(dirLocation),';');

        [~,Folder_Count]=size(subfolderlist);
        
        for Folder_No=1:Folder_Count-1;
            Subfolder_Address=subfolderlist{Folder_No};
            Subfolder_Contents=dir(Subfolder_Address);

            for Subfolder_No=3:length(Subfolder_Contents)
                if ~Subfolder_Contents(Subfolder_No).isdir
                    if ~isempty(strfind(Subfolder_Contents(Subfolder_No).name,'ST_PDR_Log'))
                        disp(['Processing file ', num2str(Folder_No-2), '/', num2str(Folder_Count-3)])
                        strPdrOriginal = fopen([Subfolder_Address '/' Subfolder_Contents(Subfolder_No).name], 'r');
                        [Dataset_Folder_Name,Dataset_File_Name,~]=fileparts(Subfolder_Address);
                        [~, UserName, ~] = fileparts(Dataset_Folder_Name);
                        line = fgetl(strPdrOriginal);
                        while line ~= -1
                            comma = strfind(line,',');
                            code = line(1:comma-1);
                            
                            if strcmp(code, '10504')
                                activity = line(comma(1, 2) + 2: comma(1, 2) + 2);
                                if  strcmp(activity, '7') || strcmp(activity, '8') || strcmp(activity, '9') || strcmp(activity, '10')
                                    
                                    path = strcat(pwd, '/Output/ActivityRecognition_', UserName, '_', Dataset_File_Name,'_', 'ST_PDR_Log/Smart_GroundTruth_Tag_Data.csv');
                                    if ~exist(path, 'file')
                                        disp(['The file: ', path, ' has not generated GT.'])
                                    else
                                        gtSmartTag = importdata(path);
                                
                                        startTag = gtSmartTag.data(1, 3);
                                        endTag = gtSmartTag.data(end, 4);

                                        tempFile = strcat(pwd, '/Output/ActivityRecognition_', UserName, '_', Dataset_File_Name,'_', 'ST_PDR_Log/temp.csv');
                                        correctedGT = fopen(tempFile, 'w');
                                        fprintf(correctedGT, strcat(gtSmartTag.textdata{:}, '\n'));
                                        fprintf(correctedGT, ['10504, 1, ', num2str(startTag), ', ', num2str(endTag), ',']);
                                        fprintf('\n');


                                        copyfile(strcat(pwd, '/Output/ActivityRecognition_', UserName, '_', Dataset_File_Name,'_', 'ST_PDR_Log/temp.csv'), ...
                                            strcat(pwd, '/Output/ActivityRecognition_', UserName, '_', Dataset_File_Name,'_', 'ST_PDR_Log/Smart_GroundTruth_Tag_Data.csv'));
                                        
                                        res = fclose(correctedGT);
                                        delete(tempFile);
                                        fprintf('\n')
                                        disp('Correction completed')
                                        fprintf('\n')
                                    end
                                
                                else
                                    disp(['Activity Code: ', activity, ' --- Skipping file.'])
                                end
                            end
                            line = fgetl(strPdrOriginal);
                        end
                    fclose('all');
                    end
                end
            end
        end
    else
        fprintf('Enter correct directory address');
    end

end