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

