function [state, results] = runAlt(state, baroData, steps, logging)
results = emptyAltRes;

[state.pbData, state.hist] = updateHist(state.pbData, state.hist, baroData, altConsts.sample_ms);

if(state.hist.tRef<=0 || state.hist.N <=0); return;end

state.stanNoise_iir = updateStanNoise(state.stanNoise_iir, state.hist.filt1d, state.hist.tRef);

[results, state.dbg] = DetectContext(state.res, state.stanNoise_iir, state.hist, state.contextHist, steps, state.dbg, logging);
end
% x = state.hist.lastIndx;
% if(x > state.hist.Nmax)
%     x = 1;
% end
% if(logging.dbgLogging.alt>0)
% state.dbg.h = [state.dbg.h state.hist.H_cm(x)];

function [pbData, hist] = updateHist(pbData, hist, baroData, dT)
curTime = baroData.t0 + (baroData.N-1)*dT;

if(pbData.data.t>= curTime);return;end

for n = 1:baroData.N
    curTime = baroData.t0 + (n-1)*dT;
    if(pbData.data.t>= curTime);continue;end
    [pbData, nValid] = runMeanFilter(pbData,baroData.x(n), curTime ,baroData.valid(n));
    if(2*pbData.data.N < pbData.data.Nmax || pbData.data.t < hist.tRef + altConsts.hist_deltaT); continue;end
    if(pbData.meanX + pbData.deltaMx < 0); continue;end
    h_cm = round(4433076*(1 - power((pbData.meanX + pbData.deltaMx)/altConsts.p0, 0.190263)));
    %dbg.h = [dbg.h h_cm];
    hist = updateHistBuffer(hist, h_cm, pbData.data.t, nValid>0);
end

hist.filt1d = simpleLinearReg(hist,altConsts.hist_deltaT*1E-3);
if(hist.filt1d.v ==0); return;end
if(hist.N==hist.Nmax)
    firstIndx = mod(hist.lastIndx, hist.Nmax)+1;
else
    firstIndx = 1;
end

hMax = -1E5; hMin = 1E5;
for n = 1:hist.Nmax
    indx = mod(firstIndx + n-2, hist.Nmax)+1;
    if(hist.v(indx)==0);continue;end
    if(hMax< hist.H_cm(indx))
        hMax = hist.H_cm(indx);
    end
    if(hMin > hist.H_cm(indx))
        hMin = hist.H_cm(indx);
    end
end
%check if we are stationary or moving up/down
hist.filt1d.isStationary = abs(hist.filt1d.slope) < 10 && ...
    (3*hist.filt1d.sE > hist.filt1d.sC || hist.filt1d.sC < altConsts.min_sigValue) && ...
    hist.filt1d.sE+hist.filt1d.sC < 1.5*altConsts.max_sigValue && ...
    hist.filt1d.sC < altConsts.max_sigValue && hMax-hMin < altConsts.minMove_cm; %cm
end

function [pbData, tValid] = runMeanFilter(pbData, x, t, v)
pbData.data.lastIndx = pbData.data.lastIndx+1;
if(pbData.data.lastIndx > pbData.data.Nmax)
    pbData.data.lastIndx = 1;
end

pbData.data.x(pbData.data.lastIndx) = x;
pbData.data.valid(pbData.data.lastIndx) = v;
pbData.data.N = min(pbData.data.N+1,pbData.data.Nmax);

%compute mean
tValid = 0; meanX = 0;
for n = 1:pbData.data.N
    if(pbData.data.valid(n)==0); continue;end
    meanX = meanX + pbData.data.x(n);
    tValid = tValid+1;
end

if(tValid==0);return;end

meanX = meanX/tValid;

if(pbData.data.N < pbData.data.Nmax || (t-pbData.data.t) > altConsts.pbBufferLength_ms)
    xFilt = meanX;
else
    alpha = altConsts.minSample_ms/altConsts.pb_iir_timeConst; %(1- exp(-dt/tau))~ dt/tau
    alpha = min(1, alpha);
    xFilt = pbData.meanX + pbData.deltaMx;
    xFilt = alpha*meanX + (1-alpha)*xFilt;
end
pbData.data.t = t;
pbData.meanX = meanX;
pbData.deltaMx = (xFilt - pbData.meanX);

%something went wrong
if(abs(pbData.deltaMx) > 100)
    pbData.deltaMx = 0;
end
end

function hist = updateHistBuffer(hist, h_cm, t, isValid)
hist.lastIndx = hist.lastIndx+1;
if(hist.lastIndx > hist.Nmax)
    hist.lastIndx = 1;
end

hist.H_cm(hist.lastIndx) = h_cm;
hist.v(hist.lastIndx) = isValid;
hist.tRef = t;
hist.N = min(hist.N+1,hist.Nmax);
end

function filt1d = simpleLinearReg(data,dt)
filt1d = emptyFilterInfo;
%check number of valid points
filt1d.v = 0;
filt1d.slope = 0; filt1d.c = 0;
filt1d.sE = 0; filt1d.sC = 0;

minNpoint = max(ceil(altConsts.histLength_ms / altConsts.hist_deltaT)/3, 5);

if(data.N < minNpoint); return; end

nValid = 0;
for n = 1:data.Nmax
    if(data.v(n)==0);continue;end
    nValid = nValid+1;
end

if(nValid< minNpoint); return;end

filt1d.v = 1;

if(data.N==data.Nmax)
    firstIndx = mod(data.lastIndx, data.Nmax)+1;
else
    firstIndx = 1;
end

x = 0; y = 0; xy = 0; xx = 0; yy =0;
for n = 1:data.Nmax
    indx = mod(firstIndx + n-2, data.Nmax)+1;
    if(data.v(indx)==0);continue;end
    t = dt*(n);
    x = x + t;
    xx = xx+ t*t;
    y = y + data.H_cm(indx);
    xy = xy + data.H_cm(indx)*t;
    yy = yy + data.H_cm(indx)*data.H_cm(indx);
end

filt1d.slope = (xy*nValid- x*y)/(xx*nValid- x*x);
filt1d.c = (y - filt1d.slope*x)/nValid;

filt1d.sE = (nValid*yy - y*y - filt1d.slope*filt1d.slope*(nValid*xx-x*x))/(nValid*(nValid-1)); % error with line slope
%sB = nValid*sE/(nValid*xx- x*x);
%sC = sB*xx/nValid;
filt1d.sC = (yy*nValid - y*y)/(nValid*(nValid-1)); % error without slope
%sC2 = (nL*yy - y*y + slope*slope*x*x)/(nL*(nL-2));
end

function stanNoise_iir = updateStanNoise(stanNoise_iir, filt1d, time)
if(filt1d.v==0); return; end

if(filt1d.isStationary==1)
    sErr = filt1d.sC;
else
    sErr= filt1d.sE;
end

sErr = min(sErr, altConsts.max_sigValue);
sErr = max(sErr, altConsts.min_sigValue);

if(stanNoise_iir.tRef<=0)
    stanNoise_iir.cSigma = min(sErr, altConsts.max_sigValue);
elseif(filt1d.isStationary==1)
    alpha = (time-stanNoise_iir.tRef)/altConsts.sig_iir_timeConst;
    if(alpha>1); alpha =1;end
    stanNoise_iir.cSigma = (1-alpha)*stanNoise_iir.cSigma + alpha*sErr;
end
stanNoise_iir.tRef = time;
end

function [res, dbg] = DetectContext(contextState, stanNoise_iir, hist, contextHist, steps, dbg, logging)
res = emptyAltRes;
time = hist.tRef;

if(logging.dbgLogging.altitude == 1 && logging.plotting==1)
    %debug, no need to implments in C
    if(hist.Nmax==hist.N && hist.lastIndx==hist.Nmax)
        figure(2);plot(hist.H_cm(1:hist.Nmax)/100)
    elseif(hist.Nmax==hist.N)
        i = [mod(hist.lastIndx,hist.Nmax)+1:hist.Nmax 1:hist.lastIndx];
        figure(2);plot(hist.H_cm(i)/100)
    else
        figure(2);plot(hist.H_cm(1:hist.N)/100)
    end
    % figure(1);xlim([time-5000 time+3000])
    % yL = get(gca,'YLim');
    % hnD = line([time-500 time-500],yL,'LineStyle', '--', 'Color', 'k', 'DisplayName', 'tCal');
    %
end

prevState = contextState;
if(prevState.t == time); return; end

%get the latest h
lastIndx = hist.lastIndx;
%search latest valid h
for n = 1:hist.Nmax
    indx = mod(lastIndx - n, hist.Nmax)+1;
    if(hist.v(indx)==1)
        refIndx = indx;
        refH = hist.H_cm(indx);
        break;
    end
end

%find largest diff from refH and latest change
dH = -1;
prevIndx = 0;
for n = 1:hist.Nmax
    indx = mod(lastIndx - n-1, hist.Nmax)+1;
    if(hist.v(indx)==1)
        dH = abs(refH - hist.H_cm(indx));
        prevIndx = indx;
        break;
    end
end

if(prevIndx==0)
    return;
end

dHfull = dH;
n = mod(refIndx- prevIndx, hist.Nmax);
if(n>0)
    dH = dH/n;
end

prev2Indx = prevIndx;
for n = 1:2
    indx = mod(prevIndx - n-1, hist.Nmax)+1;
    if(hist.v(indx)==1)
        dHfull = abs(refH - hist.H_cm(indx));
        prev2Indx = indx;
        break;
    end
end
n = mod(refIndx- prev2Indx, hist.Nmax);
if(n<=3 && n>1)
    dHfull = dHfull/n;
    if(dHfull > dH)
        dH = dHfull;
    end
end

%find max delta
dHMax = dH; fullIndx = prevIndx;
for n = 1:hist.Nmax
    indx = mod(lastIndx - n-1, hist.Nmax)+1;
    if(hist.v(indx)==1)
        x = abs(refH - hist.H_cm(indx));
        if(dHMax < x)
            dHMax = x;
            fullIndx = indx;
        end
    end
end

%compute maximum slope with Href
maxRawSlope = 0;
for n = 1:hist.Nmax
    indx = mod(lastIndx - n-1, hist.Nmax)+1;
    if(hist.v(indx)==1)
        x = abs(refH - hist.H_cm(indx));
        if(maxRawSlope*n < x)
            maxRawSlope = x/n;
        end
    end
end
maxRawSlope = maxRawSlope*1E3/altConsts.hist_deltaT;

%get max slope in last 4 sec
maxFiltSlope = 0;
for n = 1:contextHist.Nmax
    if(contextHist.v(n)==1)
        if(maxFiltSlope < abs(contextHist.slope(n)))
            maxFiltSlope = abs(contextHist.slope(n));
        end
    end
end

curSlope = maxFiltSlope;
if(hist.filt1d.v==1)
    curSlope = abs(hist.filt1d.slope);
    if(maxFiltSlope < (curSlope))
        maxFiltSlope = (curSlope);
    end
end

%use slope as well for detecting context
%maxFiltSlope<20 &&
%check if we are recently moving or staionary
isRecentlyMoving = 0;
if(contextHist.lastIndx > 0 && contextHist.v(contextHist.lastIndx)==1)
    if(contextHist.context(contextHist.lastIndx)==memsConsts.altContextOnFloor)
        isRecentlyMoving = 0;
    else
        isRecentlyMoving = 1;
    end
end

%sigma
stanSigma = 2*sqrt(altConsts.min_sigValue);
if(stanNoise_iir.tRef>0 && stanNoise_iir.tRef + 30E3 > time)
    stanSigma = sqrt(stanNoise_iir.cSigma);
end
%increSE the threshold if we are stationary for a while,
if(isRecentlyMoving==0)
    thresh_scale = altConsts.sigmaStanScale*stanSigma*altConsts.hist_deltaT*1E-3;
else
    thresh_scale = altConsts.sigmaMoveScale*stanSigma*altConsts.hist_deltaT*1E-3;
end

isStationary = (curSlope) <20 && (maxRawSlope) <25 && (dHMax) < altConsts.minMove_cm;
isStationary = isStationary || ((curSlope) <15 && (maxRawSlope) < altConsts.minRawSlope_mve ...
    && (dH) < thresh_scale && (dHMax) < altConsts.minFloorH_cm);

%detect if we are moving up direction or down
%first check slope
% if(dH < 0 && dHMax < 0)
%     isUp = -1;
% elseif(dH > 0 && dHMax > 0)
%     isUp = 1;
% elseif(hist.filt1d.v==1)
%     isUp = sign(hist.filt1d.slope);
% elseif(isStationary==0 && abs(dH) > max(10, thresh))
%     isUp = sign(dH);
% else
%     isUp = sign(dHMax);
% end

normDHMax = (dHMax)/mod(refIndx-fullIndx,hist.Nmax)*1E3/altConsts.hist_deltaT;
    
curContext = memsConsts.altContextUnknown;
if(isStationary)
    curContext = memsConsts.altContextOnFloor;
elseif((dHMax) > altConsts.minMove_cm && ((maxRawSlope) > altConsts.minRawSlope_mve || (maxFiltSlope)>20))
    if((maxFiltSlope> altConsts.minFiltSlope_lft || maxRawSlope > altConsts.minRawSlope_lft || normDHMax > 50) ...
            && (dHMax) > altConsts.minFloorH_cm) && normDHMax > 20
        curContext = memsConsts.altContextElevator;
        
    elseif((maxRawSlope > altConsts.minRawSlope_Esx || curSlope > 15 || normDHMax > 20) && (dHMax) > altConsts.minFloorH_cm)
        curContext = memsConsts.altContextStairs;
        
    else
        curContext = memsConsts.altContextUpDown;
    end
    
elseif((dHMax) > 30 && (dH) > thresh_scale)
    curContext = memsConsts.altContextUpDown;
    
elseif((dH) > 2*stanSigma*altConsts.hist_deltaT*1E-3)
    curContext = memsConsts.altContextUpDown;
elseif((dH) < 0.5*stanSigma*altConsts.hist_deltaT*1E-3)
    curContext = memsConsts.altContextOnFloor;
end

%check if there is steps for lift
% if(curContext == memsConsts.altContextElevator)
%     nSteps = checkIsWalking(steps, time-altConsts.stepTimeDelta_ms, time);
%     if(nSteps >= altConsts.maxStepsLft)
%         curContext = memsConsts.altContextStairs;
%     end
%get further refine
%get the index for non floor and get steps count
if(curContext == memsConsts.altContextElevator || curContext == memsConsts.altContextStairs)
    nPast = 0;
    for n = 1:5
        indx = mod(contextHist.lastIndx - n, contextHist.Nmax)+1;
        if(contextHist.v(indx)==1)
            if(contextHist.context(indx)== memsConsts.altContextOnFloor)
                break;
            else
                nPast = nPast + 1;
            end
        end
    end
    tPast = nPast*1000;
    tPast = max(tPast, altConsts.stepTimeDelta_ms);
    nSteps = checkIsWalking(steps, time-tPast-200, time); % 200 to account delay or catch nearted steps
    stepThesh = max(nPast-1, altConsts.maxStepsLft);
    if(nSteps >= stepThesh && curContext == memsConsts.altContextElevator && normDHMax < 100)
        curContext = memsConsts.altContextStairs;
    elseif(nSteps < stepThesh && curContext == memsConsts.altContextStairs)
        curContext = memsConsts.altContextEscalator;
    end
end

cRefContext =  curContext;

%compute confidence
nContext = getContextInstance(contextHist, cRefContext, 5);

if(nContext>2)
    res.contextConf =  memsConsts.confidenceHigh;
elseif(nContext>0)
    res.contextConf =  memsConsts.confidenceMed;
else
    res.contextConf =  memsConsts.confidencePoor;
end

if(hist.filt1d.v==1)
    res.context = cRefContext;
else
    res.context = memsConsts.altContextUnknown;
    res.contextConf = memsConsts.confidenceUnknown;
end

% %update contextHist with latest slope etc
% contextHist = updateContextHist(contextHist,hist.filt1d, curContext);

%%
hFilt = hist.H_cm(refIndx);
%if we are stationary, compute filtered height, this will help if we have
%some motion but didnt detect as motion
if(cRefContext == memsConsts.altContextOnFloor && abs(dHMax) < altConsts.minMove_cm)
    %apply simple filter
    tAlpha = 1;
    for n = 1:hist.Nmax-1
        indx = mod(lastIndx - n-1, hist.Nmax)+1;
        if(hist.v(indx) == 1)
            alpha = 0.5/n;
            hFilt = hFilt + hist.H_cm(indx)*alpha;
            tAlpha = tAlpha + alpha;
        end
    end
    hFilt = round(hFilt/tAlpha);
end

res.valid = 1;
res.hBaro_cm = hFilt;
res.hCal_cm = contextState.hCal_cm;
timeElapsed = time - prevState.t;

%set the height
if(prevState.t <= 0 || timeElapsed > 30E3)
    res.t = time;
    res.hCal_cm = res.hBaro_cm;
    res.uVel.speed_cm = 0;
    res.uVel.speed_conf = max(3*altConsts.minConf_cm, 2*abs(dH)*1E3/altConsts.hist_deltaT); %some min value
    return;
end

res.t = time;
hVel = res.hBaro_cm - prevState.hBaro_cm;

hVel_conf = altConsts.minConf_cm;
if(abs(hVel)*1000 > altConsts.maxVel_cmps*timeElapsed)
    disp(['runAlt- high vertical vel ' num2str(hVel) 'at T = ' num2str(time)]);
    hVel = sign(hVel)*altConsts.maxVel_cmps*timeElapsed*1E-3;
    hVel_conf = abs(hVel)/2;
end

if(abs(dH) > 2*thresh_scale)
    hVel_conf = 1*hVel_conf;
elseif(abs(dH) > 1.5*thresh_scale)
    hVel_conf = 1.5*hVel_conf;
else
    hVel_conf = 2*hVel_conf;
end

if(cRefContext ~= memsConsts.altContextOnFloor || ...
        timeElapsed > 2500)
    res.hCal_cm = contextState.hCal_cm + hVel;
    res.uVel.speed_cm = hVel;
    res.uVel.speed_conf = hVel_conf;
else
    res.uVel.speed_cm = 0;
    res.uVel.speed_conf = min(abs(dH)*1E3/altConsts.hist_deltaT,stanSigma);
end

% update floor state
floor = dbg.floor;
if floor.current_t == 0
    floor.last_valley_t = time;
    floor.last_valley_h_cm = hist.H_cm(hist.lastIndx);
    floor.last_peak_h_cm = hist.H_cm(hist.lastIndx);
    floor.last_peak_t = time;
    
end

floor.current_steps = steps.Nsteps(end);
floor.current_t = time;
floor.current_h_cm = hist.H_cm(hist.lastIndx);

if length(dbg.t) >= 2
    change_since_last = (dbg.h(end) - dbg.h(end-1)) / ((dbg.t(end) - dbg.t(end-1)) / 1000);
else
    change_since_last = 10;
end

if floor.current_h_cm <= floor.last_valley_h_cm && change_since_last < 75
    floor.last_valley_h_cm = floor.current_h_cm;
    floor.last_valley_steps = steps.Nsteps(end);
    floor.last_valley_t = time;
    floor.last_peak_h_cm = floor.current_h_cm;
    floor.last_peak_steps = steps.Nsteps(end);
    floor.last_peak_t = time;
elseif floor.current_h_cm > floor.last_peak_h_cm && change_since_last < 75
    floor.last_peak_h_cm = floor.current_h_cm;
    floor.last_peak_steps = steps.Nsteps(end);
    floor.last_peak_t = time;
elseif floor.last_peak_h_cm - floor.current_h_cm > 50
    floor.last_valley_h_cm = floor.current_h_cm;
    floor.last_valley_steps = steps.Nsteps(end);
    floor.last_valley_t = time;
elseif curContext == 4 || curContext == 5 %(time - floor.last_peak_t) / 1000 > 3 && (floor.last_peak_h_cm - floor.current_h_cm) > 35 || change_since_last >= 75
    floor.last_valley_h_cm = floor.current_h_cm;
    floor.last_valley_steps = steps.Nsteps(end);
    floor.last_valley_t = time;
end


vertical_distance = floor.last_peak_h_cm - floor.last_valley_h_cm;
if floor.last_peak_t < floor.last_valley_t
    vertical_distance = -vertical_distance;
end

steps_changed = (floor.last_peak_steps - floor.last_valley_steps) / (vertical_distance / 100) > 5;
time_elapsed = (floor.last_peak_t-floor.last_valley_t)/1000;
vertical_speed = vertical_distance / time_elapsed;

if (vertical_distance > 150 && steps_changed && vertical_speed < 40 && vertical_speed > 15)
    floor.Nfloors = floor.Nfloors + round((vertical_distance/305), 1);
    
    floor.last_valley_h_cm = floor.current_h_cm;
    floor.last_valley_t = floor.current_t;
    floor.last_valley_steps = floor.current_steps;
end

if(logging.dbgLogging.altitude==1)
    dbg.t = [dbg.t,time];
    dbg.slope = [dbg.slope,abs(curSlope)];
    dbg.h = [dbg.h,hist.H_cm(hist.lastIndx)];
    dbg.dH = [dbg.dH,abs(dH)];
    dbg.hMax = [dbg.hMax,abs(dHMax)];
    dbg.maxSlope = [dbg.maxSlope,abs(maxFiltSlope)];
    dbg.maxRawSlope = [dbg.maxRawSlope,abs(maxRawSlope)];
    dbg.maxdHRate = [dbg.maxdHRate, normDHMax];
    dbg.context = [dbg.context,curContext];
    dbg.steps = [dbg.steps,steps];
    dbg.hCal_cm = [dbg.hCal_cm, res.hCal_cm];
    dbg.floor = floor;
    dbg.Nfloors = [dbg.Nfloors floor.Nfloors];
    % hCal print out for debugging
    %debug
end
%delete(hnD);
end

function nContext = getContextInstance(contextHist, refContext, nTotal)
nContext = 0;
if(contextHist.N==0);return;end
if(nTotal > contextHist.Nmax)
    nTotal = contextHist.Nmax;
end
for n = 1:nTotal
    indx = mod(contextHist.lastIndx - n, contextHist.Nmax)+1;
    if(contextHist.v(indx)==1 && refContext== contextHist.context(indx))
        nContext = nContext+1;
    end
end
end

%check number of steps walked between tStart and tEnd
function nSteps = checkIsWalking(steps, tStart, tEnd)
nSteps = 0;
for n = 1:steps.NHist
    indX = mod(steps.bufferIndex - steps.NHist + n-1,steps.NHistMax)+1;
    tRef = steps.steps(indX).time;
    if(tRef>=tStart && tRef<=tEnd)
        nSteps = nSteps+1;
    end
end
end