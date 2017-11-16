function combinedMatrix_addr = writeCombinedConfMat(GTmatrix, topdir, GTverticalContext)
    combinedMatrix_addr = [topdir '/CombinedConfMatrix.csv'];
    if ~exist(combinedMatrix_addr,'file')
         combinedConfMat = zeros(6, 6);
    else
        combinedConfMat = dlmread(combinedMatrix_addr,',', 1, 1);
    end
    
    combinedConfMat(GTverticalContext + 1, :) =  combinedConfMat(GTverticalContext + 1, :) + GTmatrix;
    T = array2table(combinedConfMat);
    GTValue={'Unknown' 'OnFloor' 'UpDown' 'Stairs' 'Elevator' 'Escalator'};
    AlgoValue={'Unknown' 'OnFloor' 'UpDown' 'Stairs' 'Elevator' 'Escalator'};
    T.Properties.RowNames = GTValue;
    T.Properties.VariableNames = AlgoValue;
    
    writetable(T, [topdir '/CombinedConfMatrix.csv'], 'WriteRowNames', true, 'WriteVariableNames', true);
end
