function [smartActivity, gt] = CPGTCheck(algoDecisionOutput, smartGt, results)

%COMPARING REGRESSION ALGO(PART I), SMART START STOP TAG(PART II) TIMESTAMPS
%algo = load(algoDecisionOutput);
algo = load(algoDecisionOutput, '-mat');
algo = algo.dataToWrite;
smartGT = load(smartGt);
gt = max(smartGT(:, 2));
smartActivity = [results '/SmartActivitycodeprocessed.csv'];
algoSize = length(algo);
algoIndex = 1;
gtIndex = 1;
gtSize = size(smartGT);
gtSize = gtSize(1);

while (algoIndex <= algoSize)
    if (gtIndex <= gtSize)
       if (algo(algoIndex, 1) < smartGT(gtIndex, 3))
           algo(algoIndex, 3) = 0;
           algoIndex = algoIndex + 1;
       elseif (algo(algoIndex, 1) >= smartGT(gtIndex, 3) && algo(algoIndex, 1) < smartGT(gtIndex, 4))
           algo(algoIndex, 3) = smartGT(gtIndex, 2);
           algoIndex = algoIndex + 1;
       else
           gtIndex = gtIndex + 1;
       end
    else
        algo(algoIndex, 3) = 0;
        algoIndex = algoIndex + 1;
    end
end

save(smartActivity, 'algo');





end