function [dH, peak_index] = measure_dH(valley_index, window)
    peak = max(window(1, valley_index:end));
    peak_index = find(window(1, :) == peak, 1, 'last');
    dH = window(1, peak_index) - window(1, valley_index);
end