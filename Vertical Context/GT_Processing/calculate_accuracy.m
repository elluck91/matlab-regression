function [result, GTmatrix] = calculate_accuracy(GT)
    total_activities = 0;
    temp_window = 0;
    start_index = 1;
    interval_max = 1;
    GTmatrix = zeros(1, 6);
    
    for d = 1:length(GT)
        if GT(d, 2) ~= 0
            if temp_window == 0
                start_index = d;
            end
            temp_window = temp_window + 1;
        elseif temp_window
            max = 0;
            endTime = start_index;
            % find best shift up to 3 seconds forward
            for t = start_index:length(GT)
                endTime = t;
                if (GT(t, 1) - GT(start_index, 1)) / 1000 >= 3
                    break;
                end
            end
      
            for interval = start_index:endTime
                new_sum = getSum(GT, interval, temp_window-1, GT(start_index, 2));
                if new_sum > max
                    interval_max = interval;
                    max = new_sum;
                end
            end
            if ~max
                interval_max = start_index;
            end
            shift = ( GT(interval_max, 1) - GT(start_index, 1) ) / 1000;
            fprintf('GT shifted by %.2f seconds \n', shift);
            for x = interval_max :(interval_max + temp_window - 1)
                GTmatrix(GT(x, 3) + 1) = GTmatrix(GT(x, 3)+1) + 1;
            end
            
            total_activities = total_activities + max;
            temp_window = 0;
        end
    end
    
    gt_total = sum(GT(:, 2) > 0);
    if total_activities
        result = total_activities/gt_total;
    else
        result = 0;
    end
    
    % make it a percentage value
    result = result * 100;
    
end

