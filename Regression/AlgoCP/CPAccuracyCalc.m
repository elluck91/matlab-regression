function accuracy = CPAccuracyCalc(matrix, gt)
    confMatrix = importdata(matrix);
    confMatrixData = confMatrix.data;
    stationary = 0;
    if strcmp(confMatrix.textdata(2,1),'Stationary')
        stationary = 1;
    end

    %Access 1st row of confusion matrix if active data or 2nd row if stationary data
    activitySum = sum(confMatrixData(stationary + 1,:));
    correctSum = confMatrixData(stationary + 1, floor(gt) + 1);
    accuracy = correctSum / activitySum * 100;
    fid = fopen(matrix,'a');
    fprintf(fid, 'Algorithm Accuracy is %f', accuracy);
    fclose(fid);
end