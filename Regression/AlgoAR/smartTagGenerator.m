function smartTagAddress = smartTagGenerator(accelData, baseDir)

%%Creating output file for writing startstop tag
smartTagAddress=[baseDir '/Smart_Activity_Start_Stop_Data.csv'];
smartTagFile = fopen(smartTagAddress,'w');
fprintf(smartTagFile,'MessageID ActivityCode Starttag Stoptag\n');


samplingFrequency = 50;
accData = getAccData(accelData);
[numOfWindows, windowSize] = getWindowsNum(samplingFrequency, accData);
accProcessed = splitAccByWindow(numOfWindows, windowSize, accData, samplingFrequency);


%%%%%STEP II: Define mean for each cluster(3 in no. each for
%%%%%activity/noactivity/outliner)
walkingmean=[65 30 55 0 0];

stationarymean=[0 150 0 0 0];

%%%%STEP III: Compute histogram & euclidean distance over 3 centroids & decide to which
%%%%cluster an observation depends
stationaryclustercount = 1;
walkingclustercount = 1;

%Defining thresholds for binsize& computing the histogram
binedges=[0.5 0.9 1.1 1.6 6];

for WindowNo=1:numOfWindows
    histogram(WindowNo,:) = histc(accProcessed(WindowNo,:),binedges);
end
%bar(binedges,hold(1,:),'histc')

%computing euclidean distance
for WindowNo=1:numOfWindows
    distance(WindowNo,1) = norm(histogram(WindowNo,:)-walkingmean,5);
    distance(WindowNo,2)=norm(histogram(WindowNo,:)-stationarymean,5);
    if distance(WindowNo,1) < distance(WindowNo,2)
        activitytag(WindowNo)=1;
        walkingclustercount=walkingclustercount+1;
        if WindowNo>2
            walkingmean=(walkingmean*(walkingclustercount-1)+histogram(WindowNo,:))/walkingclustercount;
        end
    else
        activitytag(WindowNo)=0;
        stationaryclustercount=stationaryclustercount+1;
        if WindowNo>2
            stationarymean=(stationarymean*(stationaryclustercount-1)+histogram(WindowNo,:))/stationaryclustercount;
        end
    end
end



j=1; % index for maxaccDataarray 
for WindowNo=1:numOfWindows
    if activitytag(WindowNo)
       maxaccDataarray(j)= max(accProcessed(WindowNo,:));
       j=j+1;
    end
end

%%%computing max over activity period to determine noactivity zone
if exist('maxaccDataarray','var')
    meanofmaxaccData=mean(maxaccDataarray);
    stdofmaxaccData=std(maxaccDataarray);
    thresholdaccDatamax=meanofmaxaccData-1.5*stdofmaxaccData;
    thresholdaccDatamaxsuddenpeak=meanofmaxaccData+1*stdofmaxaccData;
    Noofpeaksabovethreshold=0;
    
    for WindowNo=1:numOfWindows
        %%%for sensing very low peaks-stationary data
        if max(accProcessed(WindowNo,:))<thresholdaccDatamax && distance(WindowNo,2)< 95
            activitytag(WindowNo)=0;
        end
        %%%for handling sudden peak values in accData-outliners
        if max(accProcessed(WindowNo,:))>thresholdaccDatamaxsuddenpeak
            if activitytag(WindowNo)
                for SampleNo=1:windowSize
                    if accProcessed(WindowNo,SampleNo)>thresholdaccDatamaxsuddenpeak 
                        Noofpeaksabovethreshold=Noofpeaksabovethreshold+1;
                    end
                end
                if Noofpeaksabovethreshold<1
                    activitytag(WindowNo)=0;
                end
                Noofpeaksabovethreshold=0;
            end
        end
    end
end

%%%placing extra check on last window to be identified as stop tag
if activitytag(numOfWindows)
    activitytag(numOfWindows)=0;
end

%%placing continuity check on the activity decision
for WindowNo=2:numOfWindows-2
    if activitytag(WindowNo)
        if activitytag(WindowNo-1)==0 && activitytag(WindowNo+1)==0
            activitytag(WindowNo)=0;
        end
    end
end


%Writing start stop tag onto log file
MessageIDactivitytag=10504;
lastactivitycode=-1;
stoptag=0;
for WindowNo=1:numOfWindows
    if (lastactivitycode==-1 && activitytag(WindowNo)==1) || (activitytag(WindowNo)~= lastactivitycode && lastactivitycode~=-1) 
        if lastactivitycode==-1
            starttag=((WindowNo-1)*100)*1000/samplingFrequency;
        end
        if lastactivitycode~=-1
            stoptag=((WindowNo-1)*100)*1000/samplingFrequency;
            fprintf(smartTagFile,'%d, %d, %d, %d,\n',MessageIDactivitytag, lastactivitycode, starttag, stoptag);
            starttag=((WindowNo-1)*100)*1000/samplingFrequency;
        end
        lastactivitycode=activitytag(WindowNo);
    end
    
    if (WindowNo == numOfWindows) && (stoptag ~= (WindowNo*100)*1000/samplingFrequency) && lastactivitycode ~= -1
        starttag = stoptag;
        stoptag = (WindowNo*100)*1000/samplingFrequency;
        fprintf(smartTagFile,'%d, %d, %d, %d,\n',MessageIDactivitytag, lastactivitycode, starttag, stoptag);
    end
end

if 1
    if ~sum(activitytag)
        lastactivitycode=activitytag(numOfWindows); % no activity sensed for entire period
        starttag=0;
        stoptag=((numOfWindows-1)*100)*1000/samplingFrequency;
        fprintf(smartTagFile,'%d, %d, %d, %d,\n',MessageIDactivitytag, lastactivitycode, starttag, stoptag);
    end
end

fclose('all');

end

function accData = getAccData(data)
    accelData = importdata(data);
    scalingfactor=0.000488;%PDR
    %AccX=accelData.data(:,2);
    %AccY=accelData.data(:,3);
    %AccZ=accelData.data(:,4);
    AccX=accelData(:,2);
    AccY=accelData(:,3);
    AccZ=accelData(:,4);

    AccXscaled=scalingfactor*AccX;
    AccYscaled=scalingfactor*AccY;
    AccZscaled=scalingfactor*AccZ;

    accData = sqrt(AccXscaled.^2+AccYscaled.^2 + AccZscaled.^2);
end

function [numOfWindows, windowSize] = getWindowsNum(samplingFrequency, accData)
    [sampleSize, ~]=size(accData);
    windowSize = 3 * samplingFrequency;
    % best estimate so far
    % 5 windows is 750 data points and should have 2 windows
    % 8 windows is 1200 data points and should have 4 windows
    % therefore this formula is used.
    numOfWindows = ceil((sampleSize-50)/(2*samplingFrequency));
end

function accProcessed = splitAccByWindow(numOfWindows, windowSize, accData, samplingFrequency)
    accProcessed = zeros(numOfWindows, windowSize);
    %overlap is 50 data points, so we need to increment starting point of
    %each window by 100.
    increment = samplingFrequency * 2;
    for window = 1:numOfWindows;
        for sampleNum = 1:windowSize
            if (((window - 1) * increment) + sampleNum) <= length(accData)
                accProcessed(window, sampleNum) = accData(((window - 1) * increment) + sampleNum);
            else
                break;
            end
        end
        
    end
    
end


