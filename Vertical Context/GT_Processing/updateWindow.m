function [new_window, valley_index] = updateWindow(window, new_h, new_t)
    new_window = window;
    new_window(1, :) = [new_window(1, 2:end) new_h];
    %row 2 is for time
    new_window(2, :) = [new_window(2, 2:end) new_t];
    % row 3 is for GT code
    new_window(3, :) = [new_window(3, 2:end) 0];
    
    [valley_index] = getValley(new_window);
end
