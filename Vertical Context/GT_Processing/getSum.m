function max = getSum(GT, start_index, temp_window, gt)
    max = 0;
    end_index = start_index + temp_window;
    if end_index > length(GT)
        end_index = length(GT);
    end
    
    for num = start_index:end_index
        if GT(num, 3) == gt
            max = max + 1;
        end
    end
end