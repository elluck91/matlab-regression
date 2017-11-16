function [ state,ifResultedUpdated ] = RunStepDetectionModuleRegression( state, AccX, AccY, AccZ )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

state.accdata.N = state.accdata.N + 1;
state.accdata.x(state.accdata.N) = AccX;
state.accdata.y(state.accdata.N) = AccY;
state.accdata.z(state.accdata.N) = AccZ;
state.accdata.valid(state.accdata.N) = stepConsts.TRUE;
ifResultedUpdated = 0;

if state.accdata.N == stepConsts.samplingRate;
    data = state.accdata;
    logging.unitTestLogging.stepDetection = -1;
    logging.dbgLogging.stepDetection = -1;
    state = updateStepDetectionRegression(state, data, logging);
    ifResultedUpdated = 1;
    state.accdata.N = 0;
end

end

