function createdFiles = createVCFile(settings, dataToCreate)
    createdFiles = [];
    numOfFiles = length(dataToCreate);
    outputDir = settings.output;
    API_Folder_Creation(outputDir, 'Data_Preprocessing');
    outputDir = strcat(outputDir,'/Data_Preprocessing');
    
    for i = 1:numOfFiles
        fprintf('Creating file %i / %i.\n', i, numOfFiles);
        try
            %create mergedData file
            input = dataToCreate{i};
            sensorType = [memsConsts.sensAccId, ...
                  memsConsts.sensPressureId];
            [topdir, input, ext] = fileparts(input);
            input = [input ext];
            readOnlyMsgs = [10102, 10201, 10504, 10510];
            data = plotSensorData('fname', input,'verbose', 0, 'topdir', topdir, 'plotting', 0, 'sensorType', sensorType, 'readOnlyMsgs', readOnlyMsgs);
            
            %{
            pressureMean = mean(data.pressure.x);
            
            for n = 1:length(data.pressure.x)
                diff = abs(data.pressure.x(n) - pressureMean);

                if data.pressure.x(n) > pressureMean
                    data.pressure.x(n) = pressureMean - diff;
                else
                    data.pressure.x(n) = pressureMean + diff;
                end

            end
            %}
            mergedData = mergeSort(data.acc, data.pressure);
            mergedDataFile = [outputDir '/mergedData.csv'];
            save(mergedDataFile,'mergedData');
            storeData(mergedDataFile, dataToCreate, i, settings.algo);
            
            smartGT=[outputDir '/floorCount.csv'];
            fgttag=fopen(smartGT,'w');
            %fprintf(fgttag,'MessageID,GT Step Count\n');
            fprintf(fgttag,'10510, %s,', num2str(data.floorCount));
            fclose(fgttag);
            storeData(smartGT, dataToCreate, i, settings.algo);
            
            verticalContext = [outputDir '/verticalContext.csv'];
            fgttag=fopen(verticalContext,'w');
            %fprintf(fgttag,'MessageID,GT Step Count\n');
            fprintf(fgttag,'10504, %s,', num2str(data.verticalContext));
            fclose(fgttag);
            storeData(verticalContext, dataToCreate, i, settings.algo);
            
            createdFiles{length(createdFiles) + 1} = dataToCreate{i};
        catch e
            fprintf('%s \n', e.message);
        end
    end
    
end