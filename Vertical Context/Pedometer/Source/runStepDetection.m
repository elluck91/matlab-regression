function [state, results] =  runStepDetection(state, data,logging, t0)
results = emptyStepRes();
%Better to call I16 data here 
accdata = data;
for n=1:accdata.N
    %check the data validity here
    if(accdata.valid(n)==1)
        state.sampleCount = state.sampleCount+1;
        
        %Calculating acc norm
        normAcc = sqrt(accdata.x(n)^2+accdata.y(n)^2+accdata.z(n)^2);
        
        %Update auto covariance buffer
        state.normAccAutoCovWindow(1:stepConsts.normAccAutoCovWinSize-1) = state.normAccAutoCovWindow(2:stepConsts.normAccAutoCovWinSize);
        state.normAccAutoCovWindow(stepConsts.normAccAutoCovWinSize) = normAcc;
        
        %Update norm acc energy buffer and if it is overlap energy, then
        %calculate energy
        state.normAccEnergyBuffer(mod(state.sampleCount-1,stepConsts.windowLength)+1) = normAcc-1;
        if mod(state.sampleCount,stepConsts.overlap)==0 && state.sampleCount>stepConsts.windowLength
            state.energyInNorm = mean((state.normAccEnergyBuffer).^2);
        end
        
        %Filter the data for each filter
        [state,filteredValueDef] = FilterData(state,normAcc,stepConsts.bFiltDefault,stepConsts.aFiltDefault,stepConsts.DEFAULT);
        [state,filteredValueA] = FilterData(state,normAcc,stepConsts.bFiltA,stepConsts.aFiltA,stepConsts.FILTER_A);
        [state,filteredValueB] = FilterData(state,normAcc,stepConsts.bFiltB,stepConsts.aFiltB,stepConsts.FILTER_B);
        [state,filteredValueC] = FilterData(state,normAcc,stepConsts.bFiltC,stepConsts.aFiltC,stepConsts.FILTER_C);
        [state,filteredValueD] = FilterData(state,normAcc,stepConsts.bFiltD,stepConsts.aFiltD,stepConsts.FILTER_D);
        state.filterBufferLocation = mod(state.filterBufferLocation+1,stepConsts.filterBufferSize);
                    
        %Filter the data using averaging
        [state,avgFilterOutput] = ApplyAveragingFilter(state,normAcc);        
        
        %Determine using energy if person can be walking
        if state.energyInNorm>stepConsts.minWalkingEnergy
            state.ifWalking = stepConsts.TRUE;
        else
            state.ifWalking = stepConsts.FALSE;
        end
        
        %If the person is walking, update walking duration and reset not
        %walking duration. Otherwise vice versa
        if state.ifWalking == stepConsts.TRUE
            state.notWalkingDuration = 0;
            state.walkingStartedDuration = min(state.walkingStartedDuration+1,stepConsts.upperLimitOnWalkingDuration);
        else
            state.walkingStartedDuration = 0;
            state.notWalkingDuration = min(state.notWalkingDuration+1,stepConsts.upperLimitOnNotWalkingDuration);
        end
        
        if state.ifWalking == stepConsts.TRUE
            
            %Estimate if the current filtered data has peaks
            [state,ifPeakDetected] = GetPeaksInFilteredData(state,state.currentlySelectedFilter);
            
            %If a negative peak is detected, check if it is a step. If yes,
            %then update the step frequency
            if ifPeakDetected == stepConsts.NEGATIVE_PEAK
                if CheckForStep(state,state.currentlySelectedFilter) == stepConsts.TRUE
                    state.samplesSinceLastStep = stepConsts.STEP_EVENT_TO_BE_UPDATED;
                    state = UpdateStepFrequencyWhenStepFound(state);
                end
            end
            
            %Time of step event estimation
            if state.samplesSinceLastStep~=stepConsts.STEP_EVENT_UPDATED
                if ifPeakDetected == stepConsts.POSITIVE_PEAK
                   state.samplesSinceLastStep = stepConsts.STEP_EVENT_UPDATED;
                   lastStepEventDetected = state.lastStepEpoch;
                   if (state.sampleCount-lastStepEventDetected)+ stepConsts.searchDelaySinceLastStep >= stepConsts.averagingFilteredSearchWindow
                       startTag = 1;
                   else
                       startTag = stepConsts.averagingFilteredSearchWindow-(state.sampleCount-(lastStepEventDetected+stepConsts.searchDelaySinceLastStep));
                   end
                   [localNegPeaks,localPosPeaks] = GetAllPeaksInSignal(state.averagingFilteredOutput(startTag:stepConsts.averagingFilteredSearchWindow),stepConsts.searchWindowForAvgFilteredPeak,stepConsts.threshNegPeak,stepConsts.threshPosPeak);
                   
                   %check for special case
                   if state.sampleCount-lastStepEventDetected > 2*stepConsts.samplingRate
                       [~,index] = min(localNegPeaks(:,2));
                       lastStepEventDetected = state.sampleCount-stepConsts.averagingFilteredSearchWindow + startTag + localNegPeaks(index,1)-stepConsts.correctionDueToAveraging;
                   else
                       possibleStepEvents = state.sampleCount-stepConsts.averagingFilteredSearchWindow + startTag + localNegPeaks(:,1);
                       possibleStepDurations = possibleStepEvents-lastStepEventDetected;
                       expectedStepDuration = stepConsts.samplingRate/state.stepFrequency.value;
                       [~,index] = min(abs(possibleStepDurations-expectedStepDuration));
                       %fine tune the detection. if nearby peaks are far less than
                       %current peak value, then declare that peak as the latest
                       %peak.
                       if length(localNegPeaks(:,1))>1
                           %check with previous peak
                           if index>1
                               previousPeakValue = localNegPeaks(index-1,2);
                               currentPeakValue = localNegPeaks(index,2);
                               durationDifference = localNegPeaks(index,1)-localNegPeaks(index-1,1);
                               if durationDifference<stepConsts.maxDurationDifferenceBetweenClosePeaks && currentPeakValue-previousPeakValue>stepConsts.minValueDifferenceBetweenClosePeaks
                                   index = index-1;
                               end
                           end
                           %check with next peak
                           if index+1<=length(localNegPeaks(:,1))
                               nextPeakValue = localNegPeaks(index+1,2);
                               currentPeakValue = localNegPeaks(index,2);
                               durationDifference = localNegPeaks(index+1,1)-localNegPeaks(index,1);
                               if durationDifference<stepConsts.maxDurationDifferenceBetweenClosePeaks && currentPeakValue-nextPeakValue>stepConsts.minValueDifferenceBetweenClosePeaks
                                   index = index+1;
                               end
                           end
                       end
                       lastStepEventDetected = state.sampleCount-stepConsts.averagingFilteredSearchWindow + startTag + localNegPeaks(index,1)-stepConsts.correctionDueToAveraging;
                   end
                   
				   samplesFromStartOfWindow = n-(state.sampleCount-lastStepEventDetected);
                   results.nSteps = results.nSteps+1;
                   results.time = [results.time,t0 + samplesFromStartOfWindow*1000/stepConsts.samplingRate];
                   results.stepFreq =  [results.stepFreq,state.stepFrequency.value];
                   results.stepFreqConf = [results.stepFreqConf,state.stepFrequency.confidence];
                   
                   state.lastStepEpoch = lastStepEventDetected;
                end
            end
            
            %if walking has happned for last stable walking session and
            %confidence is still less, turn on autocorrelation function to get
            %step frequency
            if 0 && state.walkingStartedDuration == stepConsts.upperLimitOnWalkingDuration && state.stepFrequency.confidence<stepConsts.leastConfidenceToKeepCurrentFilter
                
                %Calculate autocorrelation and identify peaks in pattern
                autoCov = xcov(state.normAccAutoCovWindow,state.normAccAutoCovWindow);
                [peaks,signs] = GetPeaks(autoCov(stepConsts.normAccAutoCovWinSize+1:end),stepConsts.searchWindowForAutoCovPeak,autoCov(stepConsts.normAccAutoCovWinSize+1)*stepConsts.centerPeakRatioForNextPeak);
                
                currentEnergy = sqrt(state.energyInNorm);
                state.stepFreqIdentified = stepConsts.FALSE;
                
                %If peak are idenfied
                if ~isempty(peaks)
                    
                    %If energy of system is less than the maximum limit of
                    %energy on which model is build
                    if currentEnergy<stepConsts.maxModelEnergy
                        possibleStepFreq = [];
                        possiblePeaks = [];
                        for j=1:length(peaks)
                            stepFreq = stepConsts.minSample_ms/peaks(j)*2;
                            if signs(j)== stepConsts.POSITIVE_PEAK && stepFreq<stepConsts.maxModelStepFreq && stepFreq>stepConsts.minModelStepFreq
                                possibleStepFreq = [possibleStepFreq;stepFreq];
                                possiblePeaks = [possiblePeaks;peaks(j)];
                            end
                        end
                        if ~isempty(possibleStepFreq)
                            currentEnergyBasedStepFreq = ...
                                stepConsts.p1*currentEnergy^4 + stepConsts.p2*currentEnergy^3 +...
                                stepConsts.p3*currentEnergy^2 + stepConsts.p4*currentEnergy   + stepConsts.p5;
                            [error,index] = min(abs(currentEnergyBasedStepFreq * ones(length(possibleStepFreq),1) -possibleStepFreq));
                            if error<stepConsts.maxAllowedErrorFromModel
                                state.stepFreqIdentified = possibleStepFreq(index);
                            else
                                peakValues = autoCov(possiblePeaks+stepConsts.normAccAutoCovWinSize);
                                [~,index] = max(peakValues);
                                if abs(possibleStepFreq(index)-currentEnergyBasedStepFreq)<stepConsts.maxAllowedErrorFromAutoCovPeak
                                    state.stepFreqIdentified = possibleStepFreq(index);
                                end
                            end
                        end
                    else
                        possibleStepFreq = [];
                        possiblePeaks = [];
                        for j=1:length(peaks)
                            stepFreq = stepConsts.minSample_ms/peaks(j)*2;
                            if signs(j)== stepConsts.POSITIVE_PEAK && stepFreq>stepConsts.outOfModelMinStepFreq
                                possibleStepFreq = [possibleStepFreq;stepFreq];
                                possiblePeaks = [possiblePeaks;peaks(j)];
                            end
                        end
                        if ~isempty(possibleStepFreq)
                            peakValues = autoCov(possiblePeaks+stepConsts.normAccAutoCovWinSize+1);
                            [~,index] = max(peakValues);
                            state.stepFreqIdentified = possibleStepFreq(index);
                            if (state.stepFreqIdentified)>stepConsts.outOfModelMaxStepFreq || ( state.stepFreqIdentified<stepConsts.outOfModelMinStepFreq)
                                state.stepFreqIdentified = stepConsts.FALSE;
                            end
                        end
                    end
                end
                
                %if step frequncy identified is non zero, depending on the
                %frequency range select the right filter and reset walking
                %started duration
                if state.stepFreqIdentified~=stepConsts.FALSE                
                    if state.stepFreqIdentified < stepConsts.maxFilterAStepFreq
                        state.currentlySelectedFilter = stepConsts.FILTER_A;
                    elseif state.stepFreqIdentified <stepConsts.maxFilterBStepFreq
                        state.currentlySelectedFilter = stepConsts.FILTER_B;
                    elseif state.stepFreqIdentified < stepConsts.maxFilterCStepFreq
                        state.currentlySelectedFilter = stepConsts.FILTER_C;
                    else
                        state.currentlySelectedFilter = stepConsts.FILTER_D;
                    end
                    state.walkingStartedDuration = 0;
                end
            end
        end
        
        %Reset to default filter person is not walking for some time
        if state.notWalkingDuration == stepConsts.upperLimitOnNotWalkingDuration
            state.currentlySelectedFilter = stepConsts.DEFAULT;
        end
        
        %Update step frequency
        state = UpdateStepFrequency(state);
    end
end


%Logging debugging output
if(logging.dbgLogging.stepDetection>0)
    if(isempty(state.dbg))
        state.dbg = [results];
    else
        L = length(state.dbg);
        state.dbg(L+1,:) = [results];
    end
end
if(accdata.N>0)
   state.stepResults.Time = t0 + (accdata.N-1)*1000/stepConsts.samplingRate;
end
end


%-------------------
%Function to filter data for a given transfer function
%Inputs
%--State for step detection
%--x or Input data
%--bFilt,aFilt filter coefficients for transfer function
%--filter Index - Filter index defines which filter from the filter array
%Outputs
%--Updated state
%-------------------
function [state,filteredValue] = FilterData(state,inputData,bFilt,aFilt,filterIndex)
filterBufferSize = stepConsts.filterBufferSize;
currentIndex = mod(state.filterBufferLocation,filterBufferSize)+1;
state.filterX(currentIndex) = inputData;
state.filterY(currentIndex,filterIndex) = 0;
for j=0:filterBufferSize-1
    n1 = j+1;
    n2 = mod(filterBufferSize+state.filterBufferLocation-j,filterBufferSize)+1;
    state.filterY(currentIndex,filterIndex) = state.filterY(currentIndex,filterIndex) + bFilt(n1)*state.filterX(n2);
    if j>0
        state.filterY(currentIndex,filterIndex) = state.filterY(currentIndex,filterIndex) - aFilt(n1)*state.filterY(n2,filterIndex);
    end
end
filteredValue = state.filterY(currentIndex,filterIndex);
end


%-------------------
%Function to filter data for an averaging filter
%Inputs
%--State for step detection
%--x or Input data
%Outputs
%--Updated state
%-------------------
function [state,avgFilterOutput] = ApplyAveragingFilter(state,inputData)
state.dataForAveragingFiltered(1:stepConsts.averagingFilteredWindow-1) = state.dataForAveragingFiltered(2:stepConsts.averagingFilteredWindow);
state.dataForAveragingFiltered(stepConsts.averagingFilteredWindow) = inputData;
state.averagingFilteredOutput(1:stepConsts.averagingFilteredSearchWindow-1) = state.averagingFilteredOutput(2:stepConsts.averagingFilteredSearchWindow);
state.averagingFilteredOutput(stepConsts.averagingFilteredSearchWindow) = mean(state.dataForAveragingFiltered);
avgFilterOutput = state.averagingFilteredOutput(stepConsts.averagingFilteredSearchWindow);
end


%-------------------
%General Function to identify peaks in a signal
%Inputs
%--signal
%--win : window in which derivative is checked
%--thresh: peak value should be below of above this thresh
%Outputs
%--peak: list of peaks in the signal
%--signs: signs of the peaks in the signal
%-------------------
function [peaks,signs] = GetPeaks(signal,win,thresh)
diffSignal = diff(signal);

peaks = [];signs=[];
inZone = 0;
zoneValue = 0;
for i=win+1:length(diffSignal)
    peakFound = 0;
    if max(diffSignal(i-win:i-win/2))<0 && min(diffSignal(i-win/2+1:i))>0 && signal(i)<-thresh
        peakFound = -1;
    end
    if min(diffSignal(i-win:i-win/2))>0 && max(diffSignal(i-win/2+1:i))<0 && signal(i)>thresh
        peakFound = 1;
    end
    if peakFound~=0
        if inZone ==0
            peaks = [peaks;i-win/2+1];
            signs = [signs;peakFound];
            zoneValue = signal(i-win/2);
        end
        inZone = 1;
    else
        if abs(signal(i)-zoneValue)>stepConsts.minZoneDiffValue
            inZone = 0;
        end
    end
end
end

%-------------------
%General Function to get all peaks in a signal
%Inputs
%--signal
%--win : window in which derivative is checked
%--threshNegPeak: peak value should be below this thresh to detect a
%negatie peak
%--threshPosPeak: peak value should be above this thresh to detect a
%negatie peak
%Outputs
%--localNegPeaks: list of negative in the signal
%--localPosPeaks: list of positive peaks in the signal
%-------------------
function [localNegPeaks,localPosPeaks] = GetAllPeaksInSignal(signal,win,threshNegPeak,threshPosPeak)
localNegPeaks = [];
localPosPeaks = [];
diffSignal = diff(signal);
for i=0:length(diffSignal)-win
    if max(diffSignal(i+1:i+win/2))<0 && min(diffSignal(i+win/2+1:i+win))>0 && signal(i+win/2+1)<threshNegPeak
        localNegPeaks = [localNegPeaks;i+win/2+1,signal(i+win/2+1)];
    end
    if min(diffSignal(i+1:i+win/2))>0 && max(diffSignal(i+win/2+1:i+win))<0 && signal(i+win/2+1)>threshPosPeak
        localPosPeaks = [localPosPeaks;i+win/2+1,signal(i+win/2+1)];
    end
end
if isempty(localNegPeaks)
    [minValue,index] = min(signal);
    localNegPeaks = [index,minValue];
end
if isempty(localPosPeaks)
    [maxValue,index] = max(signal);
    localPosPeaks = [index,maxValue];
end
end

%-------------------
%Function to get peaks in filtered data
%Inputs
%--State for step detection
%--filter Index - Filter index defines which filter from the filter array
%Outputs
%--Updated state
%--Flag if peak is detected
%-------------------
function [state,ifPeakDetected] = GetPeaksInFilteredData(state,filterIndex)
filterBufferSize = stepConsts.filterBufferSize;
diffSignalBufferSize = stepConsts.diffSignalBufferSize;
currentIndex = mod(filterBufferSize+state.filterBufferLocation-1,filterBufferSize)+1;
lastIndex = mod(filterBufferSize+state.filterBufferLocation-2,filterBufferSize)+1;
state.diffSignal(1:diffSignalBufferSize-1,filterIndex) = state.diffSignal(2:diffSignalBufferSize,filterIndex);
state.diffSignal(diffSignalBufferSize,filterIndex) = state.filterY(currentIndex,filterIndex) - state.filterY(lastIndex,filterIndex);

win = diffSignalBufferSize;
peakFound = 0;
diffSignal = state.diffSignal(:,filterIndex);
if max(diffSignal(1:win/2))<0 && min(diffSignal(win/2+1:win))>0
    peakFound = -1;
end
if min(diffSignal(1:win/2))>0 && max(diffSignal(win/2+1:win))<0
    peakFound = 1;
end
ifPeakDetected = 0;
if peakFound~=0
    if state.peakInZone(filterIndex)==0
        ifPeakDetected = peakFound;
        peakIndex = mod(filterBufferSize+state.filterBufferLocation-win/2,filterBufferSize)+1;
        state.peakZoneValueAndLocationLast(filterIndex,1) = state.peakZoneValueAndLocation(filterIndex,1);
        state.peakZoneValueAndLocationLast(filterIndex,2) = state.peakZoneValueAndLocation(filterIndex,2);
        state.peakZoneValueAndLocation(filterIndex,1) = state.filterY(peakIndex,filterIndex);
        state.peakZoneValueAndLocation(filterIndex,2) = state.sampleCount-diffSignalBufferSize/2;
    end
    state.peakInZone(filterIndex) = 1;
else
    if abs(state.filterY(currentIndex,filterIndex)-state.peakZoneValueAndLocation(filterIndex,1))>stepConsts.minZoneDiffValue
        state.peakInZone(filterIndex) = 0;
    end
end
end



%-------------------
%Function to identify if step is there in pattern
%Inputs
%--State for step detection
%--filter Index - Filter index defines which filter from the filter array
%Outputs
%--Updated state
%--Flag if step is detected
%-------------------
function ifStepFound = CheckForStep(state,filterIndex)
p2pThresh = stepConsts.p2pThresh;
durationMinThresh = stepConsts.durationMinThresh;
durationMaxThresh = stepConsts.durationMaxThresh;
filterSettlingDuration = stepConsts.filterSettlingDuration;

p2pValue = state.peakZoneValueAndLocationLast(filterIndex,1)-state.peakZoneValueAndLocation(filterIndex,1);
duration = state.peakZoneValueAndLocation(filterIndex,2)-state.peakZoneValueAndLocationLast(filterIndex,2);
ifStepFound = 0;
if p2pValue>p2pThresh && duration<durationMaxThresh && duration>durationMinThresh && state.sampleCount>filterSettlingDuration
    ifStepFound = 1;
end
end


%-------------------
%Function to Update Step Frequency When Step is Found
%Inputs
%--State for step detection
%Outputs
%--Updated state
%-------------------
function state = UpdateStepFrequencyWhenStepFound(state)
if state.stepFrequency.lastStepDetected == 0
    state.stepFrequency.lastStepDetected = state.sampleCount;
else
    stepFrequencyValue = stepConsts.stepFrequencySamplingRate/(state.sampleCount-state.stepFrequency.lastStepDetected);
    state.stepFrequency.lastStepDetected =  state.sampleCount;
    state.stepFrequency.confidence = min([state.stepFrequency.confidence+1,stepConsts.stepFrequencyMaxConfidence]);
    state.stepFrequency.lastStepsIncluded = min([state.stepFrequency.lastStepsIncluded+1,stepConsts.stepFrequencyMaxNoOfSteps]);
    state.stepFrequency.currentValue = stepFrequencyValue;
    if state.stepFrequency.lastStepsIncluded < stepConsts.stepFrequencyMaxNoOfSteps
        state.stepFrequency.lastStepFrequencyBuffer(state.stepFrequency.lastStepsIncluded) = stepFrequencyValue;
        state.stepFrequency.value = sum(state.stepFrequency.lastStepFrequencyBuffer(1:state.stepFrequency.lastStepsIncluded))/state.stepFrequency.lastStepsIncluded;
    else
        state.stepFrequency.lastStepFrequencyBuffer(1:stepConsts.stepFrequencyMaxNoOfSteps-1) = state.stepFrequency.lastStepFrequencyBuffer(2:stepConsts.stepFrequencyMaxNoOfSteps);
        state.stepFrequency.lastStepFrequencyBuffer(stepConsts.stepFrequencyMaxNoOfSteps) = stepFrequencyValue;
        state.stepFrequency.value = sum(state.stepFrequency.lastStepFrequencyBuffer)/stepConsts.stepFrequencyMaxNoOfSteps;
    end
    state.stepFrequency.confidence = state.stepFrequency.confidence-floor(abs(state.stepFrequency.value-state.stepFrequency.currentValue)/stepConsts.minFreqThresh);
    if state.stepFrequency.confidence<0
        state.stepFrequency.confidence = 0;
    end
    state.stepFrequency.lastTimeConfidenceUpdated = state.sampleCount;
end
end


%-------------------
%Function to Update Step Frequency for every sample
%Inputs
%--State for step detection
%Outputs
%--Updated state
%-------------------
function state = UpdateStepFrequency(state)
if state.sampleCount-state.stepFrequency.lastTimeConfidenceUpdated> stepConsts.stepFrequencyResetDuration
    state.stepFrequency.confidence = max([0,state.stepFrequency.confidence-1]);
    state.stepFrequency.lastTimeConfidenceUpdated = state.sampleCount;
end
end
