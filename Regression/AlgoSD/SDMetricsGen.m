function [gt, stepCount] = SDMetricsGen(smartActivity)
    smartData = load(smartActivity);
    gt = smartData(1, 2);
    stepCount = smartData(1,3);
end