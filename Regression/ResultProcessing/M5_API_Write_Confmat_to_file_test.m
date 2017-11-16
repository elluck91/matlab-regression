% This function writes the combined confusion matrix data onto a file with the respective Column Headings included
% Input: i) Computed combined confusion matrix including current dataset ii) Algorithm iii) Address of the combined confusion matrix
% Output: Success or failure of writing confusion matrix to file

function M5_API_Write_Confmat_to_file_test(combined_confmat_overall,M5_API_RCAlgorithm,M5_API_Combined_Conf_Matrix_Address)
confmattable=array2table(combined_confmat_overall);
% writetable(array2table(combined_confmat_overall),M5_API_Combined_Conf_Matrix_Address);

if strcmp(M5_API_RCAlgorithm,'AR')
    GTValue={'Unknown-Active' 'Unknown-Inactive' 'Stationary-Active' 'Stationary-Inactive' 'Walking-Active' 'Walking-Inactive' 'Fastwalking-Active' 'Fastwalking-Inactive' 'Jogging-Active' 'Jogging-Inactive' 'Biking-Active' 'Biking-Inactive' 'Driving-Active' 'Driving-Inactive'};
    AlgoValue={'Unknown' 'Stationary' 'Walking' 'Fastwalking' 'Jogging' 'Biking' 'Driving'};
    
elseif strcmp(M5_API_RCAlgorithm,'CP')
    GTValue={'Unknown-Active' 'Unknown-Inactive' 'OnDesk-Active' 'OnDesk-Inactive' 'Inhand-Active' 'Inhand-Inactive' 'Nearhead-Active' 'Nearhead-Inactive' 'ShirtPocket-Active' 'ShirtPocket-Inactive' 'TrouserPocket-Active' 'TrouserPocket-Inactive' 'ArmSwing-Active' 'ArmSwing-Inactive' 'JacketPocket-Active' 'JacketPocket-Inactive'};
    AlgoValue={'Unknown' 'OnDesk' 'Inhand' 'Nearhead' 'ShirtPocket' 'TrouserPocket' 'ArmSwing' 'JacketPocket'};
end
confmattable.Properties.RowNames=GTValue;
confmattable.Properties.VariableNames=AlgoValue;
writetable(confmattable,M5_API_Combined_Conf_Matrix_Address,'WriteRowNames',true);



    


