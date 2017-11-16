function comparedGT = compare(stateAlt, GT)
    current_row = 1;
    lastGTTime = GT(end, 1);
    index = 1;
    altTime = stateAlt.dbg.t;
    
    while index <= length(altTime) && altTime(index) <= lastGTTime
        if altTime(index) <= GT(current_row, 1)
            comparedGT(index, :) = [altTime(index) GT(current_row, 2) stateAlt.dbg.context(index)];
            index = index + 1;
        else
            current_row = current_row + 1;
        end
    end
    
end
