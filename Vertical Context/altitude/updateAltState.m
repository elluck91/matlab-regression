function state = updateAltState(state, results)
    if(results.valid==0 || state.res.t==results.t);return;end

    if(state.hist.filt1d.v==1)
        state.contextHist = updateContextHist(state.contextHist,state.hist.filt1d, results.context);
    end

    cRefContext = results.context;

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
