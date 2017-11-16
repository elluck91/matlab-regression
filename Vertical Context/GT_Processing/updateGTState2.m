function [new_GTState, new_window] = updateGTState2(GTState, window_alt, stateAlt)
% 1. Find peak in the window
% 2. Find valley in the window
% 3. Mark Peak with 1 at the same index
% 4. Mark Valley with -1 at the same index
if length(stateAlt.dbg.t) > 1
    [window_alt, valley_index] = updateWindow(window_alt, stateAlt.dbg.h(end), stateAlt.dbg.t(end));
    [dH, peak_index] = measure_dH(valley_index, window_alt);
    slope = getSlope(valley_index, window_alt, peak_index);
    num_steps = getStepCount(stateAlt, window_alt(2, valley_index), window_alt(2, peak_index));
    time_elapsed = (window_alt(2, peak_index) - window_alt(2, valley_index)) / 1000;
    avg_step = num_steps/time_elapsed;
    window_length = length(window_alt) - valley_index; 

    % beginning of window on ascend
    if slope >= 80 && slope <= 110 && dH > 150 && avg_step <= 0.1
        %close all;
        %plotyy(stateAlt.dbg.h, [stateAlt.dbg.steps(:).Nsteps]);
        window_alt(3, peak_index) = 1;
        GTState(end-window_length+1:end, 2) = 4;
        GTState(end+1, :) =  [stateAlt.dbg.t(end), 4, stateAlt.dbg.h(end)];
    elseif slope > 10 && slope < 45 &&  dH > 150
        if avg_step > 1
            window_alt(3, peak_index) = 1;
            GTState(end-window_length+1:end, 2) = 3;
            GTState(end+1, :) =  [stateAlt.dbg.t(end), 3, stateAlt.dbg.h(end)];
        elseif avg_step < 0.1
            window_alt(3, peak_index) = 1;
            GTState(end-window_length+1:end, 2) = 5;
            GTState(end+1, :) =  [stateAlt.dbg.t(end), 5, stateAlt.dbg.h(end)];
        else
            GTState(end+1, :) = [stateAlt.dbg.t(end), 0, stateAlt.dbg.h(end)];
        end
    else
        GTState(end+1, :) = [stateAlt.dbg.t(end), 0, stateAlt.dbg.h(end)];
    end
elseif length(stateAlt.dbg.t) == 1
    [window_alt, ~] = updateWindow(window_alt, stateAlt.dbg.h(end), stateAlt.dbg.t(end));
end
    new_GTState = GTState;
    new_window = window_alt;
    
end
