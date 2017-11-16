function [mergedData, stateAlt] = vertical_context(settings, index)
% Vertical Context:
% 2. Call plotSensorData to extract sensor data for further use
% 3. Combine pressure and accelerometer data into one set
% 4. Run step detection based on the accelerometer data
%    and once it gets 50 accel datapoints it runs Altitude Filter
% 5. Run Altitude filter to detect height
% 6. Altitude Filter implements floor count as well as vertical context, returning its value in stateAlt
% 7. Generate Ground Truth while processessing altitude data, detecting Stairs Up,
%    Escalator Up, and Elevator Up.
% 8. Compare GT output vs. Altitude Filter output and return values as a percetage accuracy.
    
    % combinedMatrix has to be a global variable because we cannot pass
    % arguments to publish dunctions, such as Report.m
    global combinedMatrix;

    % Initialize GTState for GroundTruth vs. Algo Comparison
    GTState = [];

    % READ FROM GT FILES
    [parent, ~, ~] = fileparts(settings.pathList{index});
    [~, foldername, ~] = fileparts(parent);
    basePath = [settings.HOME '/PreviouslyProcessedFiles/' settings.algo '/' foldername '_flipped/'];
    mergedDataFile = [basePath 'mergedData.csv'];
    mergedData = load(mergedDataFile, '-mat');
    mergedData = mergedData.mergedData;
    floorCountFile = [basePath 'floorCount.csv'];
    floorCount = load(floorCountFile);
    floorCount = floorCount(end, end);
    verticalContextFile = [basePath 'verticalContext.csv'];
    verticalContext = load(verticalContextFile);
    verticalContextGT = verticalContext(end, end);
    if verticalContextGT > 5
        error(['Ground Truth is invalid. Possible GT for Vertical Context is 1-5, yours is ' num2str(verticalContextGT)]);
    end
    topdir = [settings.output 'Result_Processing'];
    
    % stepState hold the stepDetection values
    stepState = emptyStepDetection();
    % baroData hold pressure sensor data used by Altitude Filter
    baroData = emptyBaroState();
    % stateAlt holds altitude filter output
    stateAlt = emptyAltitude;

    % number of pressure data points stored in the baroData structure
    pressureCounter = 1;

    % shouldProcess is a flag used by Altitude Filter
    % Altitude Filter runs when RunStepDetectionmodule changes the flag to 1
    shouldProcess = 0;

    % All important information is stored in stateAlt.dbg, therefore
    % logging.dbgLogging.altitude should be always 1
    logging.dbgLogging.altitude = 1;

    % plotting for debugging purposes
    logging.plotting = 0;

    % initial value for pressure
    % we only run GT processing when value of pressure changes (saves time)
    previous_hPa = -1;

    % GTState holds outputs of GT Processing
    % Column 1 stores timestampt
    GTState(1, 1) = 0;
    % Column 2 stores the actual GT value: Stairs up: 3 / Elevator Up: 4 / Escalator Up: 5
    GTState(1, 2) = 0;

    % Column 3 stores the height (NOT USED NOW)
    GTState(1, 3) = 0;

    % window_alt (altitude window) is where the magic happens
    % It's a rolling window that allows us for detecting context in GT_Processing

    % window_alt row 1 stores height in cm
    % window_alt row 2 stores timestamp
    % window_alt row 3 stores indicator for a valley and when updating context last peak becomes a valley
    window_alt = zeros(3, 100);
    
    for i = 1:length(mergedData)
        % Merged Data column 1 stores a code (1 or 2)
        % Code 1 indicates Accelerometer Data
        % Code 2 indicates Pressure Data
        if mergedData(i, 1) == 1
            % Accelerometer Data
            AccX = mergedData(i, 3);
            AccY = mergedData(i, 4);
            AccZ = mergedData(i, 5);
            timestamp = mergedData(i, 2);
            % Step Detection Module calculates steps
            [stepState, ifResultUpdated] = RunStepDetectionModule(stepState, AccX, AccY, AccZ, timestamp);
            % If RunStepDetectionModule has received 50 accelerometer data points it will update results
            % and change ifResultUpdated to 1, allowing Altitude Filter to run.
            if ifResultUpdated
                shouldProcess = 1;
            end
        else
            if (pressureCounter == 1)
                baroData.t0 = mergedData(i, 2);
            end

            % runAlt requires to know how many pressure Data Point we are passing
            % and what is the startTime of the data
            baroData.N = pressureCounter;

            % pressure (in hPa) is stored in field "x"
            baroData.x(pressureCounter) = mergedData(i, 3);

            % I am not sure why we have it, but runAlt needs to know it.
            baroData.valid(pressureCounter) = 1;
            % Extract the steps data needed for Altitude Filter
            steps = getStep(stepState);

            if (shouldProcess)
                [stateAlt, results] = runAlt(stateAlt, baroData, steps, logging);
                stateAlt = updateAltState(stateAlt, results);
                pressureCounter = 1;
                shouldProcess = 0;
            else
                pressureCounter = pressureCounter + 1;
            end

            % Check for change in pressure Data
            % If change detected, do GT_Processing, otherwise just run Altitude filter (ifShouldProcess == 1)
            hPa = mergedData(i, 3);

            if hPa - previous_hPa > 0
                [new_GTState, new_window] = updateGTState2(GTState, window_alt, stateAlt);
                window_alt = new_window;
                GTState = new_GTState;

            end
            previous_hPa = hPa;
        end
    end
    %plotyy(GTState(2:end, 1), GTState(2:end,2), GTState(2:end, 1), GTState(2:end, 3));

    % Combines GT-generated-output with Altitude Filter Vertical Context output
    GTvsAlgo = compare(stateAlt, GTState);

    % Calculates the resulting accuracy of the Altitude Filter
    [result_percent, GTmatrix] = calculate_accuracy(GTvsAlgo);

    % We store the ouput of the Altitude Filter in a Confusion Matrix Format
    writeConfMat(GTmatrix, topdir, verticalContextGT);

    % If passing multiple files we also combine the results and store them in Combined Confusion Matrix
    combinedMatrix = writeCombinedConfMat(GTmatrix, topdir, verticalContextGT);


    fprintf('Accuracy is: %.2f%% \n', result_percent);
    fprintf('Floots expected: %.2f \n', floorCount);
    floorsCounted = stateAlt.dbg.floor.Nfloors;
    fprintf('Floors counted: %.2f \n', floorsCounted);
    
    

    %VCResultProcess(settings, index, result_percent, floorCount, floorsCounted, verticalContextGT, GTmatrix);


    
    figure;
    plotyy(stateAlt.dbg.t, stateAlt.dbg.context, stateAlt.dbg.t, stateAlt.dbg.h);
    title('Height vs. Context');
    legend('Context','Height');
    
    figure;
    plotyy(GTvsAlgo(:, 1), GTvsAlgo(:, 2), GTvsAlgo(:, 1),GTvsAlgo(:, 3));
    title('GT vs. Context');
    legend('GT','Context');
    
    figure;
    plotyy(GTvsAlgo(:, 1), GTvsAlgo(:, 2), stateAlt.dbg.t, stateAlt.dbg.h / 100);
    title('GT vs. Height');
    legend('GT','Height');
    
    figure;
    plotyy(GTvsAlgo(:, 1), GTvsAlgo(:, 2), stateAlt.dbg.t, [stateAlt.dbg.steps(:).Nsteps]);
    title('GT vs. Step Count');
    legend('GT','Step Count');
    figure;
    plotyy(stateAlt.dbg.t, stateAlt.dbg.h, stateAlt.dbg.t, stateAlt.dbg.Nfloors);
    title('Height vs. Floor Count');
    legend('Height','Floor Count');

    figure;
    plotyy(stateAlt.dbg.t, stateAlt.dbg.h, stateAlt.dbg.t, [stateAlt.dbg.steps(:).Nsteps]);
    title('Height vs. Step Count');
    legend('Height','Step Count');        
    %{
    figure;
    plotyy(GTvsAlgo(:, 1), GTvsAlgo(:, 2), (data.pressure.t - data.pressure.t(1)) / 1000, data.pressure.x);
    title('GT vs. Pressure');
    legend('GT','Pressure');
    %}
        
end


