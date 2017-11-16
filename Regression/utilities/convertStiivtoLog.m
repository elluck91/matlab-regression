function res = convertStiivtoLog(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functionconvertSBGtoLog(varargin)
%
% Replay a file
%
% Usage:
%
% convertSBGtoLog;                           % runs from current directory with default options
% convertSBGtoLog('topdir', './'); % runs from directoy topdir
%
% see file for other vararagin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
topdir = './';
data = [];
fname = 'log_Striiv.txt';
res = [];
refsample_rate = []; % 100 may be
for n=1:2:length(varargin)
    switch varargin{n}
        case 'topdir'
            topdir = varargin{n+1};
        case 'fname'
            fname = varargin{n+1};
        case 'RefSampRate'
            refsample_rate = varargin{n+1}; % 100 or 200
        otherwise
            error(['unrecognized arg: ' varargin{n}])
    end
end

if (~isempty(topdir) && topdir(end) ~= '/'), topdir = [topdir '/']; end

if (~exist(topdir, 'dir'))
    disp([topdir ' does not exist: exit']);
    res = struct('');
    return;
end


fid = fopen([topdir '/' fname],'r');
if (fid == -1)
    disp(['Could not open file for reading: ' topdir '/' fname]);
    res = struct('');
    return;
end

if(isempty(refsample_rate))
    disp('No sample rate is set for reference file: using defualt 50 Hz');
    refsample_rate = 50;
end

memsSATInfo.nSens = 1;
memsSATInfo.sensSrc = 2;
memsSATInfo.sensorInfo(1).type = 193;
memsSATInfo.sensorInfo(1).isDataCal = 0;
memsSATInfo.sensorInfo(1).sample_ms = 20;
memsSATInfo.sensorInfo(1).range = 4;
memsSATInfo.sensorInfo(1).SF = 4/2^15;          % i.e. full scale = 16g

%%
sysSample_rate = 50;
send_Rate = 5;
%%
% refsample_rate = input('Sample Rate for Referece system = ');
fac = refsample_rate/sysSample_rate;

n = 0;
disp(['parsing file: ' fname]);
%fgetl(fid);          % header
%data format = [roll	pitch	yaw	accel X	accel Y	accel Z	gyro X	gyro Y	gyro Z	mag X	mag Y	mag Z	temp 0	temp 1]

while(1)
    line = fgetl(fid);
    if (line == -1), break; end
    if (length(line) < 5), continue; end
    valData =  str2num(line);
    % k = strfind(line,sprintf('\t'))
    if(~isempty(valData) && length(valData)>=4)
        n = n+1;
        accData.x(n) = valData(2);
        accData.y(n) = valData(3);
        accData.z(n) = valData(4);
    end
end
fclose(fid);

%resample to system sample rate
if(fac~=1)
    accData.x = resample(accData.x,1,fac);
    accData.y = resample(accData.y,1,fac);
    accData.z = resample(accData.z,1,fac);
end

n = 0; p = 0;
msgLength = sysSample_rate/send_Rate;
L = length(accData.x)/msgLength;
for m = 1:L
    timestamp = (m-1)*1000/send_Rate;
    n = n+1;
    dataStruc.x = accData.x((m-1)*msgLength + 1: m*msgLength);
    dataStruc.y = accData.y((m-1)*msgLength + 1: m*msgLength);
    dataStruc.z = accData.z((m-1)*msgLength + 1: m*msgLength);
    sensType = 193;
    dt = round(1000/sysSample_rate);
    sensorData = getSensorData(dataStruc, memsSATInfo.sensorInfo, sensType,timestamp,dt);
    sensorHeader.id = 10201;
    sensorHeader.timestamp = sensorData.timestamp;
    data.memsSensData(n).header = sensorHeader;
    data.memsSensData(n).data = sensorData;
end
data.memsConfig.header.timestamp = data.memsSensData(1).header.timestamp;
data.memsConfig.header.id = 10102;
data.memsConfig.data = memsSATInfo;

data.memsControl.header.timestamp = data.memsConfig.header.timestamp;
data.memsControl.header.id = 10103;
data.memsControl.data.controlMask = 4294967295;

data.memsInit.header.timestamp = data.memsConfig.header.timestamp;
data.memsInit.header.id = 10101;
data.memsInit.data.switch = 1;

%writeLog


% Added by Lukasz Juraszek. Used to generate Step Data and place it in
% appropriate directory for Refression Framework's use.
[~, name, ~] = fileparts(fname);
folderCreationStatus = API_Folder_Creation('C:/MATLAB/Regression_framework/Step_Data', name);
dirName = ['C:/MATLAB/Regression_framework/Step_Data/' name '/'];
% end of Lukasz's code.


fid = fopen(fullfile(dirName,'ST_PDR_Log.txt'),'wt');
fprintf( fid,'%d, %d, %d, %d, %d, %d, %d, %d, %f, -1,\n', data.memsConfig.header.id, data.memsConfig.header.timestamp, data.memsConfig.data.nSens, ...
    data.memsConfig.data.sensSrc, data.memsConfig.data.sensorInfo(1).type, data.memsConfig.data.sensorInfo(1).isDataCal, ...
    data.memsConfig.data.sensorInfo(1).range, data.memsConfig.data.sensorInfo(1).sample_ms, data.memsConfig.data.sensorInfo(1).SF);

fprintf( fid,'%d, %d, %d,\n', data.memsControl.header.id, data.memsControl.header.timestamp, data.memsControl.data.controlMask);

%fprintf( fid,'10003, 49013668, 175, 90, 44, 1,\n');
%fprintf( fid,'10250,0, 193, 3, 1, -19, -10, -21, 1.0141, 0.0, 0.0, 0.0, 0.98239, 0.0, 0.0, 0.0, 0.99013,\n');
%fprintf( fid,'10250,0, 195, 3, 1, 400, 220, -73, 1.3681, 0.0, 0.0, 0.0, 1.3326, 0.0, 0.0, 0.0, 1.4283,\n');
%fprintf( fid,'10250,0, 194, 3, 1, 0, -937, 288, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0,\n');
fprintf( fid,'%d, %d, %d,\n', data.memsInit.header.id,data.memsInit.header.timestamp,data.memsInit.data.switch);
%fprintf( fid,'10002, 0, 1, 1458719037000, 447114506, 1513832723, 4162, 1200, 1200, 0, 0,\n');

for m = 1:length(data.memsSensData)
    fprintf( fid,'%d, %d, ',data.memsSensData(m).header.id, data.memsSensData(m).header.timestamp);
    z = StructToMsg10201(data.memsSensData(m).data);
    for k=1:length(z)
        if (abs(round(z(k))-z(k))< 1E-8)
            fprintf(fid, '%d, ', z(k));
        else
            fprintf(fid, '%f, ', z(k));
        end
    end
    fprintf(fid,'\n');
end
% Code added by Lukasz Juraszek. Writes GT to the ST_PDR_Log
gtCode = 10505;
gtFile = importdata(['C:\MATLAB\StepDetectionData\GT\res_thLSB_32_' fname]);
stepCount = gtFile(end, end);
fprintf(fid,'%d, %d, %d,', gtCode,  data.memsSensData(length(data.memsSensData)).header.timestamp, stepCount);
fprintf(fid,'\n');
%End of Lukasz's code.

% fprintf( fid,'%d, %d, %d, %d, %d, %d,',data.memsSensData(n).header.id, data.memsSensData(n).header.timestamp, ...
%     data.memsSensData(m).data.timestamp, data.memsSensData(m).data.nSens, data.memsSensData(m).data.data.type, sensorData.data.N);
% for k = 1:
%     ' %d, %d, %d, %d',
r = length(data.memsSensData);
fprintf( fid,'%d, %d, %d,\n', data.memsInit.header.id, data.memsSensData(r).header.timestamp,0);
fclose('all');
end

function sensorData = getSensorData(data, info, sensType,timestamp,dt)
sensorData = [];
switch sensType
    case 193
        sensorData.data.type = 193;
    case  195
        sensorData.data.type = 195;
    case 194
        sensorData.data.type = 194;
end

switch sensorData.data.type
    case 193
        SF = info(1).SF;
    case 194
        SF = info(2).SF;
    case 195
        SF = info(3).SF;
end

sensorData.nSens = 1;
sensorData.data.N = length(data.x);
for n=1:sensorData.data.N
    samples(n).x = round((data.x(n))/ SF);
    samples(n).y = round((data.y(n))/ SF);
    samples(n).z = round((data.z(n))/ SF);
    samples(n).dt = (n-1)*dt;
end
sensorData.data.datablock = samples;
sensorData.timestamp = timestamp;
end

function data = StructToMsg10201(z)
data = zeros(1,500);
k = 1;

data(k) = z.timestamp; k = k+1;
data(k) = z.nSens; k = k+1;
for n = 1:z.nSens
    data(k) = z.data(n).type; k = k+1;
    data(k) = z.data(n).N; k = k+1;
    nDim = bitshift(bitand(z.data(n).type,192),-6);
    for p = 1:z.data(n).N
        data(k) = z.data(n).datablock(p).dt; k = k+1;
        data(k) = z.data(n).datablock(p).x; k = k+1;
        if(nDim==3)
            data(k) = z.data(n).datablock(p).y; k = k+1;
            data(k) = z.data(n).datablock(p).z; k = k+1;
        end
    end
end
data = data(1:k-1);
end