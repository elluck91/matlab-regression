function altContext = getAltContext(state, logging)
if(nargin < 2)
    logging.unitTestLogging.alt = -1;
end
altContext = state.res;
end