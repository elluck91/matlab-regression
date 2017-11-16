function mergedData = mergeSort(accData, pressureData)
    accCounter = 1;
    pressCounter = 1;
    totalCounter = 1;
    arrayLength = length(accData.t) + length(pressureData.t);
    mergedData = zeros(arrayLength, 5);
    while (accCounter <= length(accData.t) && pressCounter <= length(pressureData.t))
        if accData.t(accCounter) <= pressureData.t(pressCounter)
            mergedData(totalCounter, :) = [1, accData.t(accCounter), accData.x(accCounter), accData.y(accCounter), accData.z(accCounter)];
            accCounter = accCounter + 1;
            totalCounter = totalCounter + 1;
        else
            mergedData(totalCounter, :) = [2, pressureData.t(pressCounter), pressureData.x(pressCounter), 0, 0];
            pressCounter = pressCounter + 1;
            totalCounter = totalCounter + 1;            
        end
    end
    
    if accCounter <= length(accData.t)
        mergedData(totalCounter:end, :) = [ones(length(accData.t) - accCounter + 1,1), accData.t(accCounter:end)', accData.x(accCounter:end)', accData.y(accCounter:end)', accData.z(accCounter:end)'];
    else
        
        mergedData(totalCounter:end, :) = [ones(length(pressureData.t)-pressCounter + 1,1) * 2, pressureData.t(pressCounter:end)', pressureData.x(pressCounter:end)', zeros(length(pressureData.t)-pressCounter + 1,1), zeros(length(pressureData.t)-pressCounter + 1,1)];
    end
end

