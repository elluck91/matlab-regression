function [ carryPositionCode,features ] = CarryPositionRecognizerFunction(  AccX, AccY, AccZ , currentSample )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Defining and initializing static variables
persistent lastXSamples lastYSamplesf1 lastYSamplesf2 lastYSamplesf3 lastYSamplesf4 lastYSamplesf5 bufferLocation
persistent bufferFilteredData bufferAccData bufferAccNorm
persistent latestSampleLocation sinceLastUpdate bufferFilled
persistent delta
persistent currentCarryPosition
persistent ifFirst

%Constants
%Band pass filtered data at f1
b1 = [3.73940881391929e-07,0,-1.49576352556772e-06,0,2.24364528835158e-06,0,-1.49576352556772e-06,0,3.73940881391929e-07];
a1 = [1,-7.82085617402614,26.8078908101901,-52.6023805681731,64.6247087536464,-50.9027963808390,25.1035686093294,-7.08703159056428,0.876896560840817];

%Band pass filtered data at f2
b2 = [3.73938066007897e-07,0,-1.49575226403159e-06,0,2.24362839604738e-06,0,-1.49575226403159e-06,0,3.73938066007897e-07];
a2 = [1,-7.67063984587544,25.9351589765199,-50.4761046841992,61.8445064772808,-48.8452246923267,24.2863231552238,-6.95090993849273,0.876896560840820];

%Band pass filtered data at f3
b3 = [3.73937837368224e-07,0,-1.49575134947289e-06,0,2.24362702420934e-06,0,-1.49575134947289e-06,0,3.73937837368224e-07];
a3 = [1,-7.42241284554845,24.5300939525236,-47.1041922728325,57.4574195872754,-45.5822652142064,22.9705890897494,-6.72597387602036,0.876896560840825];

%Band pass filtered data at f4
b4 = [3.73937880109907e-07,0,-1.49575152043963e-06,0,2.24362728065944e-06,0,-1.49575152043963e-06,0,3.73937880109907e-07];
a4 = [1,-7.07934686349643,22.6642785383999,-42.7251716892612,51.8012984343853,-41.3447386330810,21.2233981353638,-6.41509749645907,0.876896560840823];

%Band pass filtered data at f5
b5 = [3.73937873920368e-07,0,-1.49575149568147e-06,0,2.24362724352221e-06,0,-1.49575149568147e-06,0,3.73937873920368e-07];
a5 = [1,-6.64582538378034,20.4327690409503,-37.6366445284047,45.2906631193808,-36.4206300271818,19.1337631269615,-6.02225298512028,0.876896560840818];

windowLength = 150; %3 second window
overlap = 100;% 2 second overlap
filterSettlingDelay = 50;%20 second

if currentSample == 1
    lastXSamples = ones(9,1);
    lastYSamplesf1 = ones(9,1);
    lastYSamplesf2 = ones(9,1);
    lastYSamplesf3 = ones(9,1);
    lastYSamplesf4 = ones(9,1);
    lastYSamplesf5 = ones(9,1);
    bufferFilteredData = zeros(windowLength,5);
    bufferAccData = zeros(windowLength,3);
    bufferAccNorm = zeros(windowLength,1);
    latestSampleLocation = 0;
    sinceLastUpdate      = 0;
    bufferFilled = 0;
    bufferLocation = 0;
    delta = windowLength-overlap;
    currentCarryPosition = 0;
    ifFirst = 1;
end

%From PDR reference frame to iPhone Reference frame
AccX = -AccX;
AccY = -AccY;
AccZ = -AccZ;

%Storing the data in the acceleration buffers and updating the epochs
latestSampleLocation = mod(latestSampleLocation,windowLength)+1;
if bufferFilled
    sinceLastUpdate  = mod(sinceLastUpdate,delta)+1;
end
bufferAccData(latestSampleLocation,1) = AccX;
bufferAccData(latestSampleLocation,2) = AccY;
bufferAccData(latestSampleLocation,3) = AccZ;
normAcc = (AccX*AccX+AccY*AccY+AccZ*AccZ);
bufferAccNorm(latestSampleLocation) = normAcc;
if latestSampleLocation == windowLength
    bufferFilled = 1;
end


%Using the data to run the filters
currentIndex = mod(bufferLocation,9)+1;
lastXSamples(currentIndex) = normAcc;
lastYSamplesf1(currentIndex) = 0;
lastYSamplesf2(currentIndex) = 0;
lastYSamplesf3(currentIndex) = 0;
lastYSamplesf4(currentIndex) = 0;
lastYSamplesf5(currentIndex) = 0;
for j=0:8
    n1 = j+1;
    n2 = mod(9+bufferLocation-j,9)+1;
    lastYSamplesf1(currentIndex) = lastYSamplesf1(currentIndex) + b1(n1)*lastXSamples(n2);
    lastYSamplesf2(currentIndex) = lastYSamplesf2(currentIndex) + b2(n1)*lastXSamples(n2);
    lastYSamplesf3(currentIndex) = lastYSamplesf3(currentIndex) + b3(n1)*lastXSamples(n2);
    lastYSamplesf4(currentIndex) = lastYSamplesf4(currentIndex) + b4(n1)*lastXSamples(n2);
    lastYSamplesf5(currentIndex) = lastYSamplesf5(currentIndex) + b5(n1)*lastXSamples(n2);
    if j>0
        lastYSamplesf1(currentIndex) = lastYSamplesf1(currentIndex) - a1(n1)*lastYSamplesf1(n2);
        lastYSamplesf2(currentIndex) = lastYSamplesf2(currentIndex) - a2(n1)*lastYSamplesf2(n2);
        lastYSamplesf3(currentIndex) = lastYSamplesf3(currentIndex) - a3(n1)*lastYSamplesf3(n2);
        lastYSamplesf4(currentIndex) = lastYSamplesf4(currentIndex) - a4(n1)*lastYSamplesf4(n2);
        lastYSamplesf5(currentIndex) = lastYSamplesf5(currentIndex) - a5(n1)*lastYSamplesf5(n2);
    end
end
bufferFilteredData(latestSampleLocation,1) = lastYSamplesf1(currentIndex);
bufferFilteredData(latestSampleLocation,2) = lastYSamplesf2(currentIndex);
bufferFilteredData(latestSampleLocation,3) = lastYSamplesf3(currentIndex);
bufferFilteredData(latestSampleLocation,4) = lastYSamplesf4(currentIndex);
bufferFilteredData(latestSampleLocation,5) = lastYSamplesf5(currentIndex);
bufferLocation = mod(bufferLocation+1,9);

%Check if the epoch has when activity has to be obtained
features = zeros(17,1);
if sinceLastUpdate == delta && bufferFilled %&& currentSample>filterSettlingDelay
    %Calculate features for classification
    energies = zeros(5,1);
    meanValues = zeros(3,1);
    runningSumNormAcc = 0; runningSum2NormAcc = 0;
    maxNormAcc = -1; minNormAcc = 10;
    for i=1:windowLength
        %Getting sum of energies
        for j=1:5
            energies(j) = energies(j) + bufferFilteredData(i,j)*bufferFilteredData(i,j);
        end
        
        %Getting running sum for AccX, AccY, AccZ
        for j=1:3
            meanValues(j) = meanValues(j)+bufferAccData(i,j);
        end
        
        %Getting running sum and running square sum for normAcc
        runningSumNormAcc = runningSumNormAcc+bufferAccNorm(i);
        runningSum2NormAcc = runningSum2NormAcc+bufferAccNorm(i)*bufferAccNorm(i);
        
        %Getting max and min values
        if maxNormAcc<bufferAccNorm(i)
            maxNormAcc = bufferAccNorm(i);
        end
        if minNormAcc>bufferAccNorm(i)
            minNormAcc = bufferAccNorm(i);
        end
    end
    %Getting normalized energies
    energiesNorm = zeros(5,1);
    for j=1:5
        if energies(2)~=0
            energiesNorm(j) = energies(j)/energies(2);
        else
            energiesNorm(j) = 0;
        end
    end
    %Getting mean values
    for j=1:3
        meanValues(j) = meanValues(j)/windowLength;
    end
    %Getting angle values
    roll = atan(meanValues(1)/ meanValues(3))*180/pi;
    pitch = atan(meanValues(2)/sqrt(meanValues(3)*meanValues(3) + meanValues(1)*meanValues(1)))*180/pi;
    %Getting peak to peak value
    p2pValue = maxNormAcc-minNormAcc;
    %Getting unbiased variance
    varValue = runningSum2NormAcc-runningSumNormAcc*runningSumNormAcc/windowLength;
    varValue = varValue/(windowLength-1);
    
    %Creating array of features
    features = zeros(17,1);
    features(1:5) = energies;
    features(6:10) = energiesNorm;
    features(11:13) = meanValues;
    features(14) = roll;
    features(15) = pitch;
    features(16) = p2pValue;
    features(17)  = varValue;
    currentCarryPosition = CarryPositionDecisionTree(features);
    currentCarryPosition = TemporalMetaClassifier_Carry(currentCarryPosition,ifFirst);
    ifFirst = 0;
end

carryPositionCode = currentCarryPosition;
end

