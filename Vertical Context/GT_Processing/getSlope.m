function slope = getSlope(valley_index, window, peak_index)
    time_elapsed = (window(2, peak_index) - window(2, valley_index)) / 1000;
    if time_elapsed > 0
        slope = (window(1, peak_index) - window(1, valley_index)) / (time_elapsed);
    else
        slope = 0;
    end
end