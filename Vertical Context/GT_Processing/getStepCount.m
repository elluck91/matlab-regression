function step_count = getStepCount(stateAlt, valley_t, peak_t)
    step_index = find([stateAlt.dbg.steps(:).Time] >= valley_t, 1, 'first');
    peak_index = find([stateAlt.dbg.steps(:).Time] <= peak_t, 1, 'last');
    if isempty(step_index)
        step_count = 0;
    else
        step_count = (stateAlt.dbg.steps(peak_index).Nsteps - stateAlt.dbg.steps(step_index).Nsteps);
    end
end