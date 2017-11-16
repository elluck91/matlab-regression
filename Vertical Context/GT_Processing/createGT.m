function GT = createGT(GTState, GTContext)
    GT = zeros(1, 3);
    GT(1, :) = [GTState(1, 2) GTState(1,1) GTState(1,1)];
    for row = 2:length(GTState)
        if GTState(row, 2) ~= GTState(row-1, 2)
            GT(end, 3) = GTState(row, 1);
            if GT(end, 1) == 0
                GT(end+1, :) = [GTContext GTState(row, 1) GTState(row, 1)];
            elseif GT(end, 1) ~= 0
                GT(end, 3) = GTState(row, 1);
                GT(end+1, :) = [0 GTState(row, 1) GTState(row, 1)];
            end
        else
            GT(end, 3) = GTState(row, 1);
        end
    end
end

