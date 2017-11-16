function [matrix, combinedMatrix]= CPMetricsGen(smartActivity, results, gt, settings)

    combinedCurrentMatrix=[results '/Combined_ConfusionMatrix.csv'];
    combinedMatrix=[fileparts(settings.output) '/Combined_Confusion_Matrix_CarryPosition_PDR_Data.csv'];

    smartalgo=importdata(smartActivity,'-mat');
    algoactivitycode=smartalgo(:,2);
    smartgtactivitycode=smartalgo(:,3);
    Noofsamples=length(smartalgo(:,2));

    confmat = zeros(2,8);
    % Combined_ConfusionMatrix.csv
    combined_confmat_current = zeros(16,8);

    if ~exist(combinedMatrix,'file')
        combined_confmat_overall = zeros(16,8);
    else 
        combined_confmat_overall = dlmread(combinedMatrix,',', 1, 1);
    end

    %Confusion Matrix & combined_confmat_current calculation
    %Creating index to create conf_mat
    %For activityrecognition: combined_confmat has only active regions
    %For carryposition: combined_confmat has both active & nonactive regions
    for SampleNo=1:Noofsamples
        if smartgtactivitycode(SampleNo)==0
            confmat(2, (floor(algoactivitycode(SampleNo)) + 1)) = confmat(2, floor(algoactivitycode(SampleNo)) + 1) + 1;
        else
            confmat(1, floor(algoactivitycode(SampleNo)) + 1) = confmat(1, floor(algoactivitycode(SampleNo)) + 1) + 1;
        end    
    end

    %Updating the combined confmat current from confmat
    combined_confmat_current(2*(floor(gt))+1:2*(floor(gt))+2,:) = confmat;

    %Updating the combined_confmat_overall from combined_confmat_current
    combined_confmat_overall = combined_confmat_overall + combined_confmat_current;

    %Writing Individual Confusion Matrix into file
    fid=fopen([results '/ConfusionMatrix.csv'],'w');
    fprintf(fid,'Source, Unknown, On Desk, In Hand, Near Head, Shirt Pocket, Trouser Pocket, Arm Swing, Jacket Pocket\n');
    fprintf(fid,'Algorithm,');
    fclose(fid);

    dlmwrite([results '/ConfusionMatrix.csv'], num2cell(confmat(1,:)),'-append');
    fid2=fopen([results '/ConfusionMatrix.csv'],'a');

    %Print same as stationary for activity & carry position algo's since we are evaluating algo's during activity duration
    fprintf(fid2,'Stationary,');
    dlmwrite([results '/ConfusionMatrix.csv'], num2cell(confmat(2,:)),'-append');
    matrix=[results '/ConfusionMatrix.csv'];
    fclose('all');

    %Write combined confusion matrix contribution by this dataset to a file
    dlmwrite(combinedCurrentMatrix, combined_confmat_current);

    %Writing Combined Confusion Matrix into file
    M5_API_Write_Confmat_to_file_test(combined_confmat_overall, settings.algo, combinedMatrix)

end