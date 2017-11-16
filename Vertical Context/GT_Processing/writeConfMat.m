function writeConfMat(GTMatrix, topdir, GTverticalContext)
    confMatFile = fopen([topdir '/ConfusionMatrixAltitude.csv'], 'w');
    fprintf(confMatFile, 'GTValue, Unknown, OnFloor, Up/Down, Stairs, Elevator, Excalator,\n');
    gt = '';
    switch GTverticalContext
        case 0
            gt = 'Unknown';
        case 1
            gt = 'OnFloor';
        case 2
            gt = 'Up/Down';
        case 3
            gt = 'Stairs';
        case 4
            gt = 'Elevator';
        case 5
            gt = 'Escalator';
    end
    str = [gt ', ' num2str(GTMatrix(1)) ', ' num2str(GTMatrix(2)) ', ' num2str(GTMatrix(3)) ', ' num2str(GTMatrix(4)) ', ' num2str(GTMatrix(5)) ', ' num2str(GTMatrix(6))];
    fprintf(confMatFile, '%s,\n', str);
    fclose(confMatFile);
end

