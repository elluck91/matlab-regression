function gtCorrection( dirLocation )
%GTCORRECTION Summary of this function goes here
%   takes the 81 test vectors in Test_Data directory and maps them
%   to match the data on the server.

    %Extract the dataset list from input folder address
    if isdir(dirLocation)
        subfolderlist=strsplit(genpath(dirLocation),';');

        [~,Folder_Count]=size(subfolderlist);
        for Folder_No=1:Folder_Count-1;
            Subfolder_Address=subfolderlist{Folder_No};
            Subfolder_Contents=dir(Subfolder_Address);

            for Subfolder_No=3:length(Subfolder_Contents)
                if ~Subfolder_Contents(Subfolder_No).isdir
                    if ~isempty(strfind(Subfolder_Contents(Subfolder_No).name,'ST_PDR_Log'))
                        disp(['Processing file: ' num2str(Folder_No) '/' num2str(Folder_Count-1)])
                        movefile([Subfolder_Address '/' Subfolder_Contents(Subfolder_No).name], [Subfolder_Address '/tmp_' Subfolder_Contents(Subfolder_No).name]);
                        originalName = [Subfolder_Address '/tmp_' Subfolder_Contents(Subfolder_No).name];
                        fileOriginal = fopen(originalName, 'r');
                        fileCorrected = fopen([Subfolder_Address '/' Subfolder_Contents(Subfolder_No).name], 'w');
                        line = fgetl(fileOriginal);
                        while line ~= -1
                            comma = strfind(line,',');
                            code = line(1:comma-1);
                            
                            if strcmp(code, '10504')
                                line(comma(1,2) + 2) = getMapped(line(comma(1,2) + 2));
                            end
                            
                            fprintf(fileCorrected, strcat(line, '\n'));
                            line = fgetl(fileOriginal);
                        end
                        
                        fclose(fileOriginal);
                        delete(originalName);
                        fclose('all');
                    end
                end
            end
        end
    else
        fprintf('Enter correct directory address');
    end




end

function code = getMapped(id)
    switch id
        case '0'
            code='0';
        case '1'
            code='1';
        case '2'
            code='4';
        case '3'
            code='5';
        case '4'
            code='6';
        case '5'
            code='7';
        case '6'
            code='9';
        otherwise
            error('Unknown input GT: %s. Check input dataset Msg:10504',id);
    end
end

