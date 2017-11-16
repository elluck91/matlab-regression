function accDataAddr = OptimizedExtractionForApp(SensorMsgsDataAddressinput)
    dataAddress = strcat(SensorMsgsDataAddressinput,'/');
    fid = fopen([dataAddress 'AccelDataMsgs.csv']);
    data = dlmread([dataAddress 'AccelDataMsgs.csv']);
    fout = fopen([dataAddress 'AccelDataTimeStampAndNumberOfSamples.csv'],'w');
    accDataAddr = [dataAddress 'AccelData.csv'];
    fdata = fopen(accDataAddr,'w');
    fprintf(fdata,'TimeStamp,AccX,AccY,AccZ');

    fprintf(fout,'SysTime,TimeStamp,NoOfSamplesPerSecond\n');
    dataSize = sum(data(:, 6));
    totalData = zeros(dataSize, 4);
    
    index = 1;
    
    for row = 1: size(data)
        for sample = 1:data(row, 6)
            totalData(index, :) = [data(row, 3)+data(row, 7+4*(sample-1)) data(row, 7 + 4*(sample-1)+1) data(row, 7 + 4*(sample-1)+2) data(row, 7 + 4*(sample-1)+3)];
            index = index + 1;
        end
    end
    
    save([dataAddress 'AccelData.csv'], 'totalData');
    fclose(fid);
    fclose(fout);
    fclose(fdata);
end