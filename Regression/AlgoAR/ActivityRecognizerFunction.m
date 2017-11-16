function activityCode= ActivityRecognizerFunction( AccX, AccY, AccZ , ifReset)
%input Sample values of acceleration, the number of the current sample,
%window length and window overlap as number of sample
%output activityCode

windowLength  = 48;
windowOverLap = 32;

%Defining and initializing static variables
persistent AccXBuffer AccYBuffer AccZBuffer currentSignal bufferFilled;
persistent latestSampleLocation sinceLastUpdate;
persistent currentActivityCode;
persistent ifFirst

persistent lastXSamples lastYSamplesFilt1 lastYSamplesFilt2 bufferLocation
persistent filtered1Buffer filtered2Buffer
persistent longDurationFeatureBuffer longDurationFeatureBufferIndex

%Constants
%Band pass filtered data 1.5 Hz to 2.5 Hz
bFilt1 = [1,0,-2,0,1];
aFilt1 = [1,-2.49037084111258,3.02830550133554,-1.87620234933848,0.574061915083954];
gainFilt1 = 0.03; threshFilt1 = 0.4;

%Low pass filtered data with cutoff at 1.0 Hz
bFilt2 = [1,4,6,4,1];
aFilt2 = [1,-2.97684433369673,3.42230952937764,-1.78610660021804,0.355577382344410];
gainFilt2 = 0.000933498612954799; threshFilt2 = 0.035;

varScaling = 1000;
    
if ifReset == 1
    AccXBuffer = zeros(windowLength,1);
    AccYBuffer = zeros(windowLength,1);
    AccZBuffer = zeros(windowLength,1);
    currentSignal = zeros(windowLength,1);
    latestSampleLocation = 0;
    sinceLastUpdate      = 0;
    bufferFilled = 0;
    currentActivityCode = 0;
    ifFirst = 1;
    
    lastXSamples = ones(5,1);
    lastYSamplesFilt1 = ones(5,1);
    lastYSamplesFilt2 = ones(5,1);
    bufferLocation = 0;
    filtered1Buffer = zeros(windowLength,1);
    filtered2Buffer = zeros(windowLength,1);
    
    longDurationFeatureBuffer = zeros(8,4);
    longDurationFeatureBufferIndex = 0;
end

%Storing the data in the acceleration buffers and updating the epochs
latestSampleLocation = mod(latestSampleLocation,windowLength)+1;
if bufferFilled
    sinceLastUpdate  = mod(sinceLastUpdate,windowLength-windowOverLap)+1;
end
AccXBuffer(latestSampleLocation) = AccX;
AccYBuffer(latestSampleLocation) = AccY;
AccZBuffer(latestSampleLocation) = AccZ;
currentSignal(latestSampleLocation) = AccX^2+AccY^2+AccZ^2;
if latestSampleLocation == windowLength
    bufferFilled = 1;
end

%Using the data to run the filters for biking and driving
currentIndex = mod(bufferLocation,5)+1;
currentNorm = currentSignal(latestSampleLocation);
lastXSamples(currentIndex) = currentNorm;
lastYSamplesFilt1(currentIndex) = 0; lastYSamplesFilt2(currentIndex) = 0;
for j=0:4
    n1 = j+1;
    n2 = mod(5+bufferLocation-j,5)+1;
    lastYSamplesFilt1(currentIndex) = lastYSamplesFilt1(currentIndex) + bFilt1(n1)*lastXSamples(n2);
    lastYSamplesFilt2(currentIndex) = lastYSamplesFilt2(currentIndex) + bFilt2(n1)*lastXSamples(n2);
    if j>0
        lastYSamplesFilt1(currentIndex) = lastYSamplesFilt1(currentIndex) - aFilt1(n1)*lastYSamplesFilt1(n2);
        lastYSamplesFilt2(currentIndex) = lastYSamplesFilt2(currentIndex) - aFilt2(n1)*lastYSamplesFilt2(n2);
    end
end
filtered1Buffer(latestSampleLocation) = lastYSamplesFilt1(currentIndex)*gainFilt1;
filtered2Buffer(latestSampleLocation) = lastYSamplesFilt2(currentIndex)*gainFilt2;
bufferLocation = mod(bufferLocation+1,5);

%Check if the epoch has when activity has to be obtained
if sinceLastUpdate == (windowLength-windowOverLap) && bufferFilled
    %Calculate features for classification
    meanAccX = 0; meanAccY = 0; meanAccZ = 0; meanNormAcc = 0; meanVerticalAcc = 0;  meanHorizontalAcc = 0;
    meanAccX2 = 0; meanAccY2 = 0; meanAccZ2 = 0; meanNormAcc2 = 0; meanVerAcc2 = 0;  meanHorAcc2 = 0;
    unitVector = zeros(3,1);
    maxNormAcc = 0; minNormAcc = 10; peakToPeakRange = 0;
    energyWalkingSignal = 0; energyBikingSignal = 0;
    meanFilt1 = 0; meanFilt2 = 0;
    for i=1:windowLength
        meanAccX = meanAccX + AccXBuffer(i);
        meanAccY = meanAccY + AccYBuffer(i);
        meanAccZ = meanAccZ + AccZBuffer(i);
        meanNormAcc = meanNormAcc + currentSignal(i);
        
        meanAccX2 = meanAccX2 + AccXBuffer(i)^2;
        meanAccY2 = meanAccY2 + AccYBuffer(i)^2;
        meanAccZ2 = meanAccZ2 + AccZBuffer(i)^2;
        meanNormAcc2 = meanNormAcc2 + currentSignal(i)^2;
        if maxNormAcc<currentSignal(i)
            maxNormAcc = currentSignal(i);
        end
        if minNormAcc>currentSignal(i)
            minNormAcc = currentSignal(i);
        end
        meanFilt1 = meanFilt1+filtered1Buffer(i);
        meanFilt2 = meanFilt2+filtered2Buffer(i);
        energyWalkingSignal = energyWalkingSignal+filtered1Buffer(i)^2;
        energyBikingSignal = energyBikingSignal+filtered2Buffer(i)^2;
    end
    meanAccX = (meanAccX/windowLength);
    meanAccY = (meanAccY/windowLength);
    meanAccZ = (meanAccZ/windowLength);
    meanAngle = atan(meanAccY/sqrt(meanAccX^2+meanAccZ^2));
    meanAngle2 = atan(abs(meanAccX)/meanAccZ);
    
    meanNormAcc = meanNormAcc/windowLength;
    
    %Store the mean values in long term feature buffer
    currentIndexLTB = longDurationFeatureBufferIndex+1;
    longDurationFeatureBuffer(currentIndexLTB,1) = meanAccX;
    longDurationFeatureBuffer(currentIndexLTB,2) = meanAccY;
    longDurationFeatureBuffer(currentIndexLTB,3) = meanAccZ;
    longDurationFeatureBuffer(currentIndexLTB,4) = meanNormAcc;
    longDurationFeatureBufferIndex = mod(longDurationFeatureBufferIndex+1,8);
    
    longTermMeanXChange = max(longDurationFeatureBuffer(:,1))-min(longDurationFeatureBuffer(:,1));
    longTermMeanYChange = max(longDurationFeatureBuffer(:,2))-min(longDurationFeatureBuffer(:,2));
    longTermMeanZChange = max(longDurationFeatureBuffer(:,3))-min(longDurationFeatureBuffer(:,3));
    longTermMeanNormChange = max(longDurationFeatureBuffer(:,4))-min(longDurationFeatureBuffer(:,4));
    
    peakToPeakRange = sqrt(maxNormAcc) - sqrt(minNormAcc);
    
    meanFilt1 = meanFilt1/windowLength;
    meanFilt2 = meanFilt2/windowLength;
    
    meanMagnitude = sqrt(meanAccX^2+meanAccY^2+meanAccZ^2);
    unitVector(1) = meanAccX/meanMagnitude;
    unitVector(2) = meanAccY/meanMagnitude;
    unitVector(3) = meanAccZ/meanMagnitude;
    
    meanAccX = abs(meanAccX);
    meanAccY = abs(meanAccY);
    meanAccZ = abs(meanAccZ);
    varAccX  = (meanAccX2/windowLength - meanAccX^2)*varScaling;
    varAccY  = (meanAccY2/windowLength - meanAccY^2)*varScaling;
    varAccZ  = (meanAccZ2/windowLength - meanAccZ^2)*varScaling;
    varNormAcc = (meanNormAcc2/windowLength - meanNormAcc^2)*varScaling;
    energySignal = meanNormAcc2;
    
    zeroCrossingsWalking = 0;
    zeroCrossingsBiking = 0;
    for i=2:windowLength
        if (filtered1Buffer(i)-meanFilt1-threshFilt1)*(filtered1Buffer(i-1)-meanFilt1-threshFilt1)<0
            zeroCrossingsWalking = zeroCrossingsWalking+1;
        end
        if (filtered1Buffer(i)-meanFilt1+threshFilt1)*(filtered1Buffer(i-1)-meanFilt1+threshFilt1)<0
            zeroCrossingsWalking = zeroCrossingsWalking+1;
        end
        if (filtered2Buffer(i)-meanFilt2-threshFilt2)*(filtered2Buffer(i-1)-meanFilt2-threshFilt2)<0
            zeroCrossingsBiking = zeroCrossingsBiking+1;
        end
        if (filtered2Buffer(i)-meanFilt2+threshFilt2)*(filtered2Buffer(i-1)-meanFilt2+threshFilt2)<0
            zeroCrossingsBiking = zeroCrossingsBiking+1;
        end
    end
    
    for i=1:windowLength
        verAcc = unitVector(1)*AccXBuffer(i)+unitVector(2)*AccYBuffer(i)+unitVector(3)*AccZBuffer(i);
        horAcc = sqrt(AccXBuffer(i)^2+AccYBuffer(i)^2+AccZBuffer(i)^2-verAcc^2);
        meanVerticalAcc = meanVerticalAcc + abs(verAcc);
        meanHorizontalAcc = meanHorizontalAcc + horAcc;
        meanVerAcc2 = meanVerAcc2 + verAcc^2;
        meanHorAcc2 = meanHorAcc2 + horAcc^2;
    end
    meanVerticalAcc = meanVerticalAcc/windowLength;
    meanHorizontalAcc = meanHorizontalAcc/windowLength;
    
    varVerticalAcc = (meanVerAcc2/windowLength - meanVerticalAcc^2)*varScaling;
    varHorizontalAcc = (meanHorAcc2/windowLength - meanHorizontalAcc^2)*varScaling;
    
    %Get the classified values
    currentActivityCode = DecisionTreeActivity(meanAccX,meanAccY,meanAccZ,meanNormAcc,varAccX,varAccY,varAccZ,varNormAcc,energySignal,energyWalkingSignal,energyBikingSignal,zeroCrossingsWalking,zeroCrossingsBiking,meanVerticalAcc,varVerticalAcc,meanHorizontalAcc,varHorizontalAcc,peakToPeakRange,longTermMeanXChange,longTermMeanYChange,longTermMeanZChange,longTermMeanNormChange,meanAngle,meanAngle2);
    %special case for in hand cases going in biking and driving
    if varNormAcc<4 && meanAccX<0.2%12 degrees
        % STATIONARY
        if meanAccY<0.35 && meanAccZ>0.92%20 degrees
            currentActivityCode = 1;
        end
    end
    if (currentActivityCode == 5 || currentActivityCode == 6) && meanAngle*180/pi>-30 && meanAngle*180/pi<0 && meanAngle2*180/pi>-15 && meanAngle2*180/pi<0 && peakToPeakRange>0.5
        currentActivityCode = 2;
    end
    
    %Filter the classified value using the temporal meta classifier
    currentActivityCode = TemporalMetaClassifier_Activity(currentActivityCode,ifFirst);
    ifFirst = 0;
end
activityCode = currentActivityCode;
end