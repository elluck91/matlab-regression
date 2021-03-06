function [ z ] = emptyStepDetection()
%EMPTYACCCAL Summary of this function goes here
%   Detailed explanation goes here
z = struct('accdata', emptyAccData, ....
    'stepsRes', emptyStepRes, ... %to hold ouput, u can hold hist as well
    'sampleCount',0,...
    'filterX',zeros(stepConsts.filterBufferSize,1),...
    'filterY',zeros(stepConsts.filterBufferSize,stepConsts.noOfFilters),...
    'filterBufferLocation',0,...
    'diffSignal',zeros(stepConsts.diffSignalBufferSize,stepConsts.noOfFilters),...
    'peakInZone',zeros(stepConsts.noOfFilters,1),...
    'peakZoneValueAndLocation',zeros(stepConsts.noOfFilters,2),...
    'peakZoneValueAndLocationLast',zeros(stepConsts.noOfFilters,2),...
    'dataForAveragingFiltered',zeros(stepConsts.averagingFilteredWindow,1),...
    'averagingFilteredOutput',zeros(stepConsts.averagingFilteredSearchWindow,1),...
    'samplesSinceLastStep',-1,...
    'lastStepEpoch',0,...
	'stepFrequency',emptyStepFrequency,...
    'stepResults',emptyStepResultsForState,...
    'currentlySelectedFilter',stepConsts.DEFAULT,...
    'normAccEnergyBuffer',zeros(stepConsts.windowLength,1),...
    'energyInNorm',0,....
    'notWalkingDuration',0,...
    'normAccAutoCovWindow',zeros(stepConsts.normAccAutoCovWinSize,1), ...
    'ifWalking',0,...
    'walkingStartedDuration',0,...
    'stepFreqIdentified',stepConsts.FALSE,...
	'dbg', emptyStepDebug);
end

function [ z ] = emptyStepDebug()
%EMPTYACCCAL Summary of this function goes here
%   Detailed explanation goes here
z = struct('');
end
