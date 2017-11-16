%Final Carry Positions
% Unknown        = 0
% On Desk        = 1
% In Hand        = 2
% Near Head      = 3
% Shirt Pocket   = 4
% Trouser Pocket = 5
% Arm Swing      = 6
% Jacket Pocket  = 7

%Intermediate Carry Positions
% Not Walking    = 11
% Walking        = 12
% Fixed w Torso  = 13

function carryPosition = CarryPositionDecisionTree(features)
Band1 = features(1);
Band2 = features(2);
Band3 = features(3);
Band4 = features(4);
Band5 = features(5);
Band1Norm = features(6);
Band2Norm = features(7);
Band3Norm = features(8);
Band4Norm = features(9);
Band5Norm = features(10);
meanAccX = features(11);
meanAccY = features(12);
meanAccZ = features(13);
meanRoll = features(14);
meanPitch = features(15);
pTopVal = features(16);
variance = features(17);

%Tree 1:
carryPosition = DecisionTree1(pTopVal,meanRoll,meanPitch);

if carryPosition == 11
    %Tree 2
    carryPosition = DecisionTree2(meanRoll,meanPitch);
end

if carryPosition == 12
    %Tree 3
    carryPosition = DecisionTree3(meanAccZ,pTopVal,Band1,meanAccX,Band1Norm,Band3Norm,meanPitch,Band2,Band5Norm,Band4Norm,variance,Band4,meanRoll,meanAccY,Band3,Band5);
    %carryPosition = DecisionTree3(meanAccZ,pTopVal,Band1,meanAccX,Band1Norm,Band4,meanAccY,Band3Norm,meanPitch,Band4Norm,Band2,Band3,Band5,Band5Norm,meanRoll,variance);
    if carryPosition == 13
        %Tree 4
        carryPosition = DecisionTree4(meanRoll,meanPitch);
    end
end
end

function carryPosition = DecisionTree1(pTopVal,meanRoll,meanPitch)
if pTopVal <= 0.96 %0.96
    if pTopVal <= 0.08 %0.04
        if abs(meanRoll)>50 && abs(meanRoll)<90 && meanPitch>-60 && meanPitch<5
            carryPosition = 3;
        else
            carryPosition = 1;
        end
    else
        carryPosition = 11;
    end
else
    carryPosition = 12;
end
end

function carryPosition = DecisionTree2(meanRoll,meanPitch)
carryPosition = 0;
if abs(meanRoll)<45 && meanPitch>-78 && meanPitch<35%-1
    carryPosition = 2;
else
    if abs(meanRoll)>50 && abs(meanRoll)<90 && meanPitch>-60 && meanPitch<5
        carryPosition = 3;
    else
        if abs(meanPitch)>55
            carryPosition = 4;
        end
    end
end
end


function carryPosition = DecisionTree3(meanAccZ,pTopVal,Band1,meanAccX,Band1Norm,Band3Norm,meanPitch,Band2,Band5Norm,Band4Norm,variance,Band4,meanRoll,meanAccY,Band3,Band5)
if meanAccZ <= -0.810893
    carryPosition = 13;
else
    if pTopVal <= 3.70119
        
        if Band1 <= 2.225693
            
            if meanAccX <= -0.72875
                
                if Band1Norm <= 0.221174
                    carryPosition = 7;
                else
                    if pTopVal <= 2.226444
                        carryPosition = 6;
                    else
                        carryPosition = 7;
                    end
                end
            else
                if Band3Norm <= 0.067635
                    
                    if meanPitch <= -84.354292
                        
                        if Band2 <= 30.840164
                            
                            if Band1Norm <= 0.009763
                                carryPosition = 13;
                            else
                                carryPosition = 7;
                            end
                        else
                            carryPosition = 7;
                        end
                    else
                        if Band5Norm <= 0.037571
                            
                            if Band4Norm <= 0.206304
                                carryPosition = 13;
                            else
                                if variance <= 0.276125
                                    carryPosition = 13;
                                else
                                    if Band4 <= 6.025863
                                        carryPosition = 13;
                                    else
                                        carryPosition = 7;
                                    end
                                end
                            end
                        else
                            if pTopVal <= 2.577856
                                
                                if Band1Norm <= 0.151003
                                    carryPosition = 13;
                                else
                                    carryPosition = 6;
                                end
                            else
                                if meanPitch <= -77.063301
                                    
                                    if meanRoll <= 14.586718
                                        carryPosition = 13;
                                    else
                                        carryPosition = 5;
                                    end
                                else
                                    if meanAccY <= 0.860923
                                        
                                        if meanRoll <= 43.30103
                                            carryPosition = 7;
                                        else
                                            carryPosition = 5;
                                        end
                                    else
                                        if Band4 <= 1.851119
                                            carryPosition = 5;
                                        else
                                            carryPosition = 13;
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if meanPitch <= -74.64929
                        
                        if pTopVal <= 2.913619
                            carryPosition = 13;
                        else
                            if meanRoll <= 9.128362
                                carryPosition = 13;
                            else
                                carryPosition = 5;
                            end
                        end
                    else
                        carryPosition = 5;
                    end
                end
            end
        else
            if meanPitch <= -71.517779
                
                if Band5Norm <= 0.045146
                    carryPosition = 7;
                else
                    carryPosition = 13;
                end
            else
                if Band4 <= 1.786095
                    
                    if meanPitch <= 66.239606
                        
                        if Band1 <= 69.877519
                            carryPosition = 6;
                        else
                            if Band3 <= 2.493593
                                carryPosition = 6;
                            else
                                carryPosition = 7;
                            end
                        end
                    else
                        if meanPitch <= 69.250235
                            carryPosition = 6;
                        else
                            carryPosition = 5;
                        end
                    end
                else
                    if meanPitch <= 11.818962
                        
                        if meanPitch <= -24.1626
                            carryPosition = 5;
                        else
                            carryPosition = 7;
                        end
                    else
                        if meanAccX <= -0.456757
                            
                            if Band1 <= 4.317747
                                carryPosition = 7;
                            else
                                carryPosition = 6;
                            end
                        else
                            carryPosition = 5;
                        end
                    end
                end
            end
        end
    else
        if meanAccX <= -0.691395
            
            if Band4 <= 28.69895
                
                if meanAccY <= 0.374742
                    
                    if Band1 <= 10.895677
                        
                        if Band3Norm <= 0.374734
                            carryPosition = 7;
                        else
                            if Band4Norm <= 0.055909
                                carryPosition = 5;
                            else
                                carryPosition = 7;
                            end
                        end
                    else
                        if Band1 <= 36.544331
                            carryPosition = 6;
                        else
                            carryPosition = 5;
                        end
                    end
                else
                    carryPosition = 6;
                end
            else
                if Band3 <= 22.302615
                    carryPosition = 6;
                else
                    carryPosition = 5;
                end
            end
        else
            if meanAccZ <= 0.257179
                
                if Band1Norm <= 0.019074
                    
                    if Band2 <= 32.303926
                        
                        if meanAccX <= -0.307999
                            carryPosition = 7;
                        else
                            if Band4Norm <= 0.236999
                                carryPosition = 5;
                            else
                                carryPosition = 7;
                            end
                        end
                    else
                        if Band3 <= 7.730038
                            
                            if meanAccX <= -0.209756
                                carryPosition = 13;
                            else
                                if Band3Norm <= 0.059357
                                    
                                    if meanAccY <= -0.285018
                                        
                                        if meanRoll <= 41.553197
                                            
                                            if meanAccX <= -0.030968
                                                carryPosition = 13;
                                            else
                                                carryPosition = 7;
                                            end
                                        else
                                            carryPosition = 13;
                                        end
                                    else
                                        if Band4 <= 1.081531
                                            carryPosition = 7;
                                        else
                                            carryPosition = 7;
                                        end
                                    end
                                else
                                    if Band4 <= 4.174732
                                        carryPosition = 5;
                                    else
                                        carryPosition = 7;
                                    end
                                end
                            end
                        else
                            if Band4 <= 16.913345
                                carryPosition = 5;
                            else
                                carryPosition = 7;
                            end
                        end
                    end
                else
                    if meanPitch <= 15.978521
                        
                        if meanAccX <= 0.768476
                            
                            if Band3Norm <= 0.059456
                                
                                if Band2 <= 33.108507
                                    
                                    if meanAccX <= 0.134805
                                        
                                        if meanAccZ <= 0.216057
                                            
                                            if meanRoll <= -84.488366
                                                
                                                if meanAccY <= -0.984452
                                                    carryPosition = 5;
                                                else
                                                    carryPosition = 7;
                                                end
                                            else
                                                carryPosition = 5;
                                            end
                                        else
                                            carryPosition = 7;
                                        end
                                    else
                                        carryPosition = 7;
                                    end
                                else
                                    if Band3Norm <= 0.056637
                                        carryPosition = 7;
                                    else
                                        carryPosition = 7;
                                    end
                                end
                            else
                                if Band3 <= 0.26503
                                    
                                    if meanAccZ <= -0.074378
                                        carryPosition = 5;
                                    else
                                        carryPosition = 7;
                                    end
                                else
                                    if meanRoll <= 78.007048
                                        carryPosition = 5;
                                    else
                                        if Band5 <= 0.861674
                                            
                                            if Band3Norm <= 0.173491
                                                carryPosition = 7;
                                            else
                                                carryPosition = 5;
                                            end
                                        else
                                            if Band2 <= 2.417466
                                                carryPosition = 7;
                                            else
                                                carryPosition = 5;
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            carryPosition = 7;
                        end
                    else
                        if Band1Norm <= 0.057536
                            
                            if Band3Norm <= 0.094122
                                
                                if Band4Norm <= 0.075786
                                    carryPosition = 5;
                                else
                                    if meanAccX <= 0.163783
                                        
                                        if Band5Norm <= 0.095043
                                            carryPosition = 7;
                                        else
                                            carryPosition = 5;
                                        end
                                    else
                                        carryPosition = 5;
                                    end
                                end
                            else
                                carryPosition = 5;
                            end
                        else
                            if Band2 <= 8.243972
                                
                                if meanAccX <= 0.1052
                                    carryPosition = 5;
                                else
                                    if meanPitch <= 75.250371
                                        carryPosition = 5;
                                    else
                                        if meanRoll <= -42.269137
                                            carryPosition = 7;
                                        else
                                            carryPosition = 5;
                                        end
                                    end
                                end
                            else
                                carryPosition = 5;
                            end
                        end
                    end
                end
            else
                if Band1Norm <= 0.016647
                    carryPosition = 13;
                else
                    if meanAccY <= 0.979149
                        carryPosition = 7;
                    else
                        carryPosition = 5;
                    end
                end
            end
        end
    end
end
end
                                      
function carryPosition = DecisionTree4(meanRoll,meanPitch)
carryPosition = 0;
if abs(meanRoll)<45 && meanPitch>-78 && meanPitch<35
    carryPosition = 2;
else
    if abs(meanRoll)>50 && abs(meanRoll)<90 && meanPitch>-55 && meanPitch<5
        carryPosition = 3;
    else
        if abs(meanPitch)>55
            carryPosition = 4;
        end
    end
end
end