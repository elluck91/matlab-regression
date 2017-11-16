function state = updateAlt(state, data, steps, logging)
if(logging.unitTestLogging.altitude>-1)
    writeLine(logging.unitTestLogging.altitude, createMsg(data.pressure.procBuffer,0,memsUnitTestIDs.uDataPressure_procBuffer));
    %writeLine(logging.unitTestLogging.attitude, createMsg(steps,0,memsUnitTestIDs.steps));
    writeLine(logging.unitTestLogging.attitude, createMsg(state,0,memsUnitTestIDs.uAlt_state));
end
%check the data interval validity here
interval = getDataInterval(state.schedule, data, logging.verbose);
if(interval.valid==0)
    return;
end
%run main processing
[state, results] =  runAlt(state, data, steps, interval,logging);
%update the results
state = updateAltState(state, results);

%update schedule here
state.schedule.lastTime = interval.endTime;
end

%fucntion to update the state with results
function state = updateAltState(state, results)
if(results.valid==0 || state.res.t==results.t);return;end

if(state.hist.filt1d.v==1)
    state.contextHist = updateContextHist(state.contextHist,state.hist.filt1d, results.context);
end

cRefContext = results.context;
%use slope if dHMax is not avaialbe
% %refine the context if it is nt onFloor and dHMax > 50
% if(cRefContext ~= memsConsts.altContextOnFloor && abs(dHMax) > altConsts.minMove_cm)
%     %get the max vote in last 4 sec for nonUnknow or onFloor
%     nLift = 0; nStairs = 0;
%     for n = 1:4
%         indx = mod(contextHist.lastIndx - n, contextHist.Nmax)+1;
%         if(contextHist.v(indx)==1)
%             if(contextHist.context(indx)== memsConsts.altContextStairs)
%                 nStairs = nStairs+1;%            
%             elseif(contextHist.context(indx)== memsConsts.altContextElevator)
%                 nLift = nLift+1;
%             elseif(contextHist.context(indx)== memsConsts.altContextOnFloor)
%                 break;
%             end
%         end
%     end
%     if((nLift == 4 && isUp==1) || ((nLift) > (nStairs) && nLift >0 && cRefContext == memsConsts.altContextUpDown))
%         cRefContext = memsConsts.altContextElevator;
%     elseif((nStairs == 4 && isUp==1) || ((nLift) < (nStairs)  && nStairs > 0 && cRefContext == memsConsts.altContextUpDown))
%         cRefContext = memsConsts.altContextStairs;
%     end
% end

if(cRefContext==memsConsts.altContextUnknown)
    cRefContext = state.res.context;
    if(state.res.contextConf==memsConsts.confidenceHigh)
        results.contextConf = memsConsts.confidenceMed;
    elseif(state.res.contextConf==memsConsts.confidenceMed)
        results.contextConf = memsConsts.confidencePoor;
    end
end

state.res = results;
state.res.context = cRefContext;
end

function contextH = updateContextHist(contextH,filt1d, context)
%update contextHist with latest slope etc
contextH.lastIndx = contextH.lastIndx+1;
if(contextH.lastIndx > contextH.Nmax)
    contextH.lastIndx = 1;
end

%contextHist.H_cm(contextHist.lastIndx) = hBaro_cm;
contextH.v(contextH.lastIndx) = filt1d.v;
contextH.slope(contextH.lastIndx) = filt1d.slope;
contextH.context(contextH.lastIndx) = context;
contextH.N = min(contextH.N+1,contextH.Nmax);
end