function [new_GTState, previous_hPa, new_mean_hPa] = updateGTState(hPa, GTState, window_hPa, stateAlt)
    %fprintf(['Iteration #: ' num2str(length(GTState)) '\n']);
    max_hPa = max(window_hPa(2, :));
    min_hPa = min(window_hPa(2, :));

    window_hPa(2, :) = [window_hPa(2, 2:end), hPa(2)];
    window_hPa(1, :) = [window_hPa(1, 2:end), hPa(1)];
    window_hPa(3, :) = [window_hPa(3, 2:end), 0];
    window_hPa(4, :) = [window_hPa(4, 2:end), 0];
    
    
    if hPa(2) > max_hPa
        window_hPa(3, end) = 1;
    elseif hPa(2) < min_hPa
        window_hPa(3, end) = -1;
    else
        window_hPa(3, end) = 0;
    end    
    
    I = window_hPa(2, :) == 0;
    
    if sum(I) > 0
        value = 0;
        for d=1:30
            if ~I(d)
                value = value + window_hPa(2, d);
            end
        end
        mean_hPa = value / (length(window_hPa) - sum(I));
    else
        mean_hPa = mean(window_hPa(2, :));
    end

    if hPa(2) > mean_hPa
        window_hPa(4, end) = 1;
    elseif hPa(2) < mean_hPa
        window_hPa(4, end) = -1;
    else
        window_hPa(4, end) = 0;
    end
    
    Max = window_hPa(3, :) == 1;
    above_avg = window_hPa(4, 1:end) == 1;
    Min = window_hPa(3, :) == -1;
    below_avg = window_hPa(4, 1:end) == -1;
    max_count = sum(Max(end-length(Max) + 1:end));
    above_count = sum(above_avg);
    min_count = sum(Min(end-length(Min) + 1:end));
    below_count = sum(below_avg);
    
    if max_count > 7 || (above_count >= 40 && max_count >= 5)
        medianAltitude = median(window_hPa(2,:));
        valley_time_index = find(window_hPa(2,:) == medianAltitude & window_hPa(2,:) ~= 0, 1, 'last');
        distance = length(Min) - valley_time_index;
        if isempty(valley_time_index)
            distance = 0;
        end
        for d = length(GTState)-distance:length(GTState)+1
            GTState(d, 2) = 1;
        end
    elseif (min_count > 7) || (below_count >= 40 || min_count >= 5)
        medianAltitude = median(window_hPa(2,:));
        peak_time_index = find(window_hPa(2,:) == medianAltitude & window_hPa(2,:) ~= 0, 1, 'last');
        distance = length(Max) - peak_time_index;
        if isempty(peak_time_index)
            distance = 0;
        end
        for d = length(GTState)-distance:length(GTState)+1
            GTState(d, 2) = -1;
        end
    else
        if GTState(end, 2) == 1
            medianAltitude = median(window_hPa(2,:));
            peak_time_index = find(window_hPa(2,:) == medianAltitude & window_hPa(2,:) ~= 0, 1, 'first');
            distance = length(Max) - peak_time_index;
            if isempty(peak_time_index)
                distance = 0;
            end
            for d = length(GTState)-distance:length(GTState)+1
                GTState(d, 2) = 0;
            end
        elseif GTState(end, 2) == -1
            medianAltitude = median(window_hPa(2,:));
            valley_time_index = find(window_hPa(2,:) == medianAltitude & window_hPa(2,:) ~= 0, 1, 'first');
            distance = length(Min) - valley_time_index;
            if isempty(valley_time_index)
                distance = 0;
            end
            for d = length(GTState)-distance:length(GTState)+1
                GTState(d, 2) = 0;
            end
        else
            GTState(end + 1, 2) = 0;
        end 
    end
    
    GTState(end, 1) = hPa(1);
    
    new_GTState = GTState;
    new_mean_hPa = window_hPa;
    previous_hPa = hPa;
    %close all;
    
    %{
    close all
    if ~isempty(pressureData.t)
        figure;
        plotyy((pressureData.t-pressureData.t(1)) / 1000, pressureData.x, GTState(:,1), GTState(:, 2));
        set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    end
%}
end
