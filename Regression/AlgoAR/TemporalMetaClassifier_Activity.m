function [ filteredState ] = TemporalMetaClassifier_Activity(currentState,ifFirst)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
persistent stationaryTimeMap walkingTimeMap fastWalkingTimeMap joggingTimeMap bikingTimeMap drivingTimeMap
persistent lastConfidentState confidentState
persistent duration
persistent highActivityThresh

if ifFirst
    stationaryTimeMap = 0;
    walkingTimeMap = 0;
    fastWalkingTimeMap = 0;
    joggingTimeMap = 0;
    bikingTimeMap = 0;
    drivingTimeMap = 0;
    lastConfidentState = 1;
    confidentState = 1;
    highActivityThresh = 5;
    duration = 0;
end

contextUpdated = 0;

%Shift with time all time maps and remove the not required bits
stationaryTimeMap = stationaryTimeMap*2^1;    stationaryTimeMap = mod(stationaryTimeMap,2^2);
walkingTimeMap = walkingTimeMap*2^1;          walkingTimeMap = mod(walkingTimeMap,2^7);
fastWalkingTimeMap = fastWalkingTimeMap*2^1;  fastWalkingTimeMap = mod(fastWalkingTimeMap,2^7);
joggingTimeMap = joggingTimeMap*2^1;          joggingTimeMap = mod(joggingTimeMap,2^7);

%Shift with time of low intensity acitivity only if it is not
%stationary to take care of driving|Biking to Stationary
%transitions on red lights
if currentState~=1
    bikingTimeMap = bikingTimeMap*2^1; bikingTimeMap = mod(bikingTimeMap,2^30);
    drivingTimeMap = drivingTimeMap*2^1; drivingTimeMap = mod(drivingTimeMap,2^30);
end

%Update the time maps
switch currentState
    case 1
        stationaryTimeMap = stationaryTimeMap+1;
    case 2
        walkingTimeMap = walkingTimeMap+1;
    case 3
        fastWalkingTimeMap = fastWalkingTimeMap+1;
    case 4
        joggingTimeMap = joggingTimeMap+1;
    case 5
        bikingTimeMap = bikingTimeMap+1;
    case 6
        drivingTimeMap = drivingTimeMap+1;
end

%Get last 2 instances and see if 2 are stationary
stationaryVotes = GetSumOfBits_Activity(stationaryTimeMap,2);
if stationaryVotes == 2
    lastConfidentState = confidentState;
    confidentState = 1;
    contextUpdated = 1;
end

%Get last 5/7 instances and see if 5/7  are walking
if ~contextUpdated
    walkingVotes = GetSumOfBits_Activity(walkingTimeMap,highActivityThresh);
    if walkingVotes == highActivityThresh
        lastConfidentState = confidentState;
        confidentState = 2;
        contextUpdated = 1;
    end
end

%Get last 5/7  instances and see if 5/7  are fast walking
if ~contextUpdated
    fastWalkingVotes = GetSumOfBits_Activity(fastWalkingTimeMap,highActivityThresh);
    if fastWalkingVotes == highActivityThresh
        lastConfidentState = confidentState;
        confidentState = 3;
        contextUpdated = 1;
    end
end

%Get last 5/7  instances and see if 5/7  are jogging
if ~contextUpdated
    joggingVotes = GetSumOfBits_Activity(joggingTimeMap,highActivityThresh);
    if joggingVotes == highActivityThresh
        lastConfidentState = confidentState;
        confidentState = 4;
        contextUpdated = 1;
    end
end

%Get last 30 instances and see if more than 23 are biking
if ~contextUpdated
    bikingVotes = GetSumOfBits_Activity(bikingTimeMap,30);
    if bikingVotes > 23
        lastConfidentState = confidentState;
        confidentState = 5;
        contextUpdated = 1;
    end
end

%Get last 30 instances and see if more than 23 are driving
if ~contextUpdated
    drivingVotes = GetSumOfBits_Activity(drivingTimeMap,30);
    if drivingVotes > 23
        lastConfidentState = confidentState;
        confidentState = 6;
        contextUpdated = 1;
    end
end

if contextUpdated==1
    %If current confidence state is Stationary
    if confidentState == 1
        % High Intensity -> Stationary ; Reset the high intensity maps
        if lastConfidentState == 2 || lastConfidentState == 3 || lastConfidentState == 4
            walkingTimeMap = 0;
            fastWalkingTimeMap = 0;
            joggingTimeMap = 0;
        end
        % Low Intensity -> Stationary ; Update the low intensity
        % time maps
        if lastConfidentState == 5 || lastConfidentState == 6
            drivingTimeMap = floor(drivingTimeMap/2^26);%Shift by 23+3
            bikingTimeMap = floor(bikingTimeMap/2^26);%Shift by 23+3
        end
    end
    
    % High Intensity|Stationary -> Low Intensity ; Reset the high
    % intensity maps and increase the high activity thresh
    if confidentState == 5 || confidentState == 6
        if lastConfidentState == 1 || lastConfidentState == 2 || lastConfidentState == 3 || lastConfidentState == 4
            highActivityThresh = 7;
            walkingTimeMap = 0;
            fastWalkingTimeMap = 0;
            joggingTimeMap = 0;
        end
    end
    
    % Low Intensity|Stationary -> High Intensity ; Reset the low
    % intensity maps
    if confidentState == 2 || confidentState == 3 || confidentState == 4
        if lastConfidentState == 1 || lastConfidentState == 5 || lastConfidentState == 6
            drivingTimeMap = 0;
            bikingTimeMap = 0;
            highActivityThresh = 5;
        end
    end
end

%Global counter to check static
if confidentState == 1
    duration = duration+1;
    if duration==2*60
        walkingTimeMap = 0;
        fastWalkingTimeMap = 0;
        joggingTimeMap = 0;
        drivingTimeMap = 0;
        bikingTimeMap = 0;
        highActivityThresh = 5;
    end
    if duration>2*60
        duration=2*60;
    end
else
    duration = 0;
end
filteredState = confidentState;
end

