classdef altConsts
    % all the constants used but not internals onces
    
    properties (Constant)
        minSensors = 2^(memsConsts.sensPressureType-1);
        minSample_ms = 100;   %minimum rate to run
        interval_ms = 1000; %schedule to run
        border_ms = 100;    %delay in execution
        sample_ms  = 100; % default frequency of 10Hz
        pbBufferLength_ms = 1000;
        pb_iir_timeConst = 500;
        
        histLength_ms = 8000; % for 8 sec, every 0.5 sec
        hist_deltaT = 500; %store after every deltaT
        
		contextHistLen = 8; % for 8 sec,
		
        minN4Slope_ms = 4000;
        
        %noise update
        sig_iir_timeConst = 1000;
        max_sigValue = 300; %in cm2
        min_sigValue = 50; %in cm2
        sigmaMoveScale = 1.5;
        sigmaStanScale  = 2;
        
        %max vel
        maxVel_cmps = 500;
        minMove_cm = 50; % if height is change more than this then there is possible movement
        minFloorH_cm = 95; % minimum change in height before start declaring stairs or lift
        minConf_cm = 5;
        
        minRawSlope_mve = 20;
        
        %lift detect
        minRawSlope_lft = 65;
        minFiltSlope_lft = 40;
        stepTimeDelta_ms = 3000;
        maxStepsLft = 3;
        
        %escalaor or stairs case
        minRawSlope_Esx = 25;
        
        p0 = 101325; % sea level pressure, 44330.7*(1-(p/p0)^(1/5.255));
        
        %vertContextUnknown = 0;
        %vertContextOnFloor = 1;
        %vertContextUp = 2;
        %vertContextDown = -2;
        %vertContextStairsUp = 3;
        %vertContextStairsDown = -3;
        %vertContextLiftUp = 4;
        %vertContextLiftDown = -4;
    end
end