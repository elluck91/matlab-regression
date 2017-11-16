function samplingRate = samplingRateCalculation(stPdr)
MsgmemsConfig=0;

if exist([pwd '/' stPdr], 'file')
    %fprintf('Exist');
else
    %fprintf('Does not exist');
    error('File does not exist');
end

fid=fopen([pwd '/' stPdr]);
tline=fgetl(fid);

while ischar(tline)
    a = strfind(tline,',');
    messageType = tline(1:a(1)-1);
    if strcmp(messageType,'10102')
        MsgmemsConfig=1;
        %find the sensor type from message
        if tline(a(4)+1)==' '
            SensorName = tline(a(4)+2:a(5)-1);
        else
            SensorName = tline(a(4)+1:a(5)-1);
        end
        % find the sampling rate of the sensorname scanned: for now only
        % accelerometer; to be extended to all sensors
        if strcmp(SensorName,'193')
            if tline(a(7)+1)==' '
                sampleTime = str2double(tline(a(7)+2:a(8)-1));
            else
                sampleTime = str2double(tline(a(7)+1:a(8)-1));
            end
            break;
        end
    end
    tline=fgetl(fid);
end

if MsgmemsConfig==0
    disp('MEMS Config Msg:10102 Not found in Log, Dataset cannot be used for Regression');
    sampleTime=str2double(tline(a(7)+1:a(8)-1));
end

fclose(fid);
samplingRate = 1000/sampleTime;
end