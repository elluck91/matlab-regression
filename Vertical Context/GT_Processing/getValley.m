function [valley_index] = getValley(window_alt)
    % find first non-zero element in the array
    first_nonzero_element = find(window_alt(1, :) ~= 0, 1, 'first');
    
    % find last window valley
    % I THINK we can eliminate it because it will be checked each time and
    % moved forward if no significant change has been found in the next
    % second...
    %valley_index = find(window(3, :) == -2, 1, 'last');
    marked_valley = find(window_alt(3, :) == 1, 1, 'last');
    if isempty(marked_valley)
        valley_h = min(window_alt(1, first_nonzero_element:end));
    else
        valley_h = min(window_alt(1, marked_valley:end));
    end
    
    valley_index = find(window_alt(1, :) == valley_h, 1, 'last');
    
    for i = 0:length(window_alt)-valley_index
        [slope, time_elapsed] = measureSlope(length(window_alt)-i, valley_index,window_alt);
        if slope < 10 && time_elapsed > 1
            valley_index  = length(window_alt)-i;
            break;
        end
    end
    
end

function [slope, time_elapsed] = measureSlope(i, valley_index, window_alt)
    % difference is elevation / difference in time
    time_elapsed = (window_alt(2, i) - window_alt(2, valley_index)) / 1000;
    if time_elapsed > 0
        slope = (window_alt(1, i) - window_alt(1, valley_index)) / (time_elapsed);
    else
        slope = 0;
    end
end