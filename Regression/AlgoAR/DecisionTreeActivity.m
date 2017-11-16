function result = DecisionTreeActivity(meanAccX,meanAccY,meanAccZ,meanNormAcc,varAccX,varAccY,varAccZ,varNormAcc,energySignal,energyWalkingSignal,energyBikingSignal,zeroCrossingsWalking,zeroCrossingsBiking,meanVerticalAcc,varVerticalAcc,meanHorizontalAcc,varHorizontalAcc,peakToPeakRange,longTermMeanXChange,longTermMeanYChange,longTermMeanZChange,longTermMeanNormChange,meanAngle,meanAngle2)
result = 0;
if result == 0
    if varNormAcc <= 0.758347
        result = 1;
    else
        if zeroCrossingsBiking <= 2
            
            if energyWalkingSignal <= 0.005515
                
                if zeroCrossingsBiking <= 0
                    result = 1;
                else
                    if meanHorizontalAcc <= 0.157917
                        result = 0;
                    else
                        result = 1;
                    end
                end
            else
                if energyWalkingSignal <= 0.211101
                    result = 0;
                else
                    if varNormAcc <= 17.633609
                        
                        if peakToPeakRange <= 0.653101
                            result = 0;
                        else
                            result = 1;
                        end
                    else
                        result = 0;
                    end
                end
            end
        else
            result = 0;
        end
    end
end
if result == 0
    if varAccY <= 3.521931
        
        if meanAccZ <= 0.279767
            
            if meanAngle <= 1.096504
                
                if energyBikingSignal <= 47.590172
                    
                    if meanAngle <= -0.859351
                        result = 5;
                    else
                        if meanHorizontalAcc <= 0.070648
                            result = 5;
                        else
                            result = 0;
                        end
                    end
                else
                    if longTermMeanYChange <= 0.368441
                        
                        if meanNormAcc <= 1.003834
                            result = 6;
                        else
                            result = 6;
                        end
                    else
                        result = 5;
                    end
                end
            else
                if longTermMeanZChange <= 0.198557
                    result = 5;
                else
                    if longTermMeanNormChange <= 0.098922
                        
                        if longTermMeanZChange <= 0.534055
                            result = 6;
                        else
                            result = 5;
                        end
                    else
                        result = 5;
                    end
                end
            end
        else
            if meanNormAcc <= 0.929928
                result = 5;
            else
                if varAccZ <= 13.517592
                    result = 6;
                else
                    if meanAngle2 <= -0.003632
                        
                        if meanAccZ <= 0.866224
                            result = 6;
                        else
                            result = 0;
                        end
                    else
                        result = 6;
                    end
                end
            end
        end
    else
        if energyWalkingSignal <= 2.441198
            
            if varVerticalAcc <= 2.612458
                result = 6;
            else
                if meanAccZ <= 0.22704
                    
                    if varAccZ <= 7.82325
                        
                        if meanAccX <= 0.608709
                            
                            if meanAngle <= -0.98411
                                
                                if longTermMeanNormChange <= 0.019736
                                    result = 0;
                                else
                                    result = 6;
                                end
                            else
                                result = 5;
                            end
                        else
                            result = 0;
                        end
                    else
                        if longTermMeanZChange <= 0.496624
                            
                            if varAccZ <= 13.3026
                                
                                if meanAngle2 <= -0.403085
                                    
                                    if meanAccY <= 0.545631
                                        result = 0;
                                    else
                                        if varHorizontalAcc <= 9.32322
                                            
                                            if longTermMeanYChange <= 0.015228
                                                result = 0;
                                            else
                                                result = 5;
                                            end
                                        else
                                            result = 0;
                                        end
                                    end
                                else
                                    result = 0;
                                end
                            else
                                result = 0;
                            end
                        else
                            if longTermMeanNormChange <= 0.080284
                                result = 0;
                            else
                                if meanAccY <= 0.809306
                                    result = 5;
                                else
                                    if varAccZ <= 81.430341
                                        result = 5;
                                    else
                                        result = 5;
                                    end
                                end
                            end
                        end
                    end
                else
                    if meanAccZ <= 0.935855
                        
                        if longTermMeanNormChange <= 0.020532
                            
                            if meanAccX <= 0.609188
                                
                                if longTermMeanXChange <= 0.082273
                                    result = 5;
                                else
                                    result = 6;
                                end
                            else
                                result = 0;
                            end
                        else
                            if meanAccY <= 0.112028
                                
                                if energyWalkingSignal <= 0.579525
                                    
                                    if meanVerticalAcc <= 0.986933
                                        result = 5;
                                    else
                                        result = 6;
                                    end
                                else
                                    if longTermMeanYChange <= 0.191157
                                        result = 0;
                                    else
                                        if meanAccX <= 0.557581
                                            result = 0;
                                        else
                                            result = 6;
                                        end
                                    end
                                end
                            else
                                if meanAngle2 <= 0.537342
                                    result = 5;
                                else
                                    if meanAccZ <= 0.628353
                                        
                                        if meanAccZ <= 0.398789
                                            result = 5;
                                        else
                                            if meanAccX <= 0.408922
                                                result = 5;
                                            else
                                                if varHorizontalAcc <= 9.209564
                                                    
                                                    if longTermMeanNormChange <= 0.226943
                                                        result = 6;
                                                    else
                                                        result = 5;
                                                    end
                                                else
                                                    result = 5;
                                                end
                                            end
                                        end
                                    else
                                        result = 6;
                                    end
                                end
                            end
                        end
                    else
                        if meanAngle2 <= -0.0005
                            
                            if longTermMeanZChange <= 0.096947
                                result = 0;
                            else
                                if meanAccY <= 0.385252
                                    result = 0;
                                else
                                    result = 5;
                                end
                            end
                        else
                            if longTermMeanYChange <= 0.431344
                                
                                if meanAngle <= -0.346982
                                    result = 5;
                                else
                                    result = 6;
                                end
                            else
                                result = 5;
                            end
                        end
                    end
                end
            end
        else
            if meanAccZ <= 0.275891
                
                if varAccZ <= 3.855587
                    
                    if longTermMeanNormChange <= 0.304413
                        result = 5;
                    else
                        result = 0;
                    end
                else
                    if varAccX <= 14.708106
                        
                        if meanAccZ <= 0.171853
                            
                            if varAccZ <= 15.127626
                                result = 5;
                            else
                                if longTermMeanYChange <= 0.456402
                                    result = 0;
                                else
                                    result = 5;
                                end
                            end
                        else
                            result = 5;
                        end
                    else
                        result = 0;
                    end
                end
            else
                if varAccZ <= 28.657587
                    
                    if varAccY <= 28.867583
                        
                        if meanAccY <= 0.69224
                            
                            if meanHorizontalAcc <= 0.065504
                                result = 6;
                            else
                                result = 0;
                            end
                        else
                            result = 5;
                        end
                    else
                        if meanAngle2 <= -0.731078
                            
                            if longTermMeanYChange <= 0.102143
                                result = 0;
                            else
                                result = 5;
                            end
                        else
                            result = 5;
                        end
                    end
                else
                    if meanVerticalAcc <= 0.963329
                        
                        if meanAccY <= 0.461954
                            result = 0;
                        else
                            if meanAccZ <= 0.486254
                                
                                if longTermMeanZChange <= 0.072417
                                    result = 5;
                                else
                                    if energyBikingSignal <= 97.64414
                                        
                                        if meanAngle2 <= -1.029181
                                            result = 5;
                                        else
                                            result = 0;
                                        end
                                    else
                                        result = 5;
                                    end
                                end
                            else
                                result = 5;
                            end
                        end
                    else
                        if meanAngle2 <= 0.016371
                            
                            if meanAngle <= 1.185957
                                result = 0;
                            else
                                if longTermMeanNormChange <= 0.196625
                                    result = 0;
                                else
                                    if longTermMeanZChange <= 0.249176
                                        result = 5;
                                    else
                                        result = 0;
                                    end
                                end
                            end
                        else
                            if meanAngle2 <= 0.60386
                                
                                if meanAccZ <= 0.329706
                                    result = 5;
                                else
                                    result = 5;
                                end
                            else
                                if longTermMeanZChange <= 0.215114
                                    result = 0;
                                else
                                    if longTermMeanZChange <= 0.448884
                                        result = 0;
                                    else
                                        result = 5;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
if result ==0
    if varVerticalAcc <= 923.126351
        
        if energyWalkingSignal <= 2.434787
            
            if meanAccZ <= 0.155824
                
                if varAccZ <= 11.676941
                    
                    if meanAccX <= 0.782504
                        
                        if meanVerticalAcc <= 0.974313
                            
                            if energyBikingSignal <= 45.654807
                                result = 0;
                            else
                                result = 5;
                            end
                        else
                            result = 5;
                        end
                    else
                        result = 0;
                    end
                else
                    result = 0;
                end
            else
                if meanAccX <= 0.941841
                    result = 5;
                else
                    result = 0;
                end
            end
        else
            if varAccX <= 408.281068
                
                if meanAccZ <= 0.275891
                    
                    if varAccX <= 14.708106
                        
                        if meanAccZ <= 0.171853
                            
                            if varAccZ <= 15.126431
                                result = 5;
                            else
                                result = 0;
                            end
                        else
                            result = 5;
                        end
                    else
                        result = 0;
                    end
                else
                    if zeroCrossingsWalking <= 17
                        
                        if meanAccY <= 0.281976
                            
                            if zeroCrossingsBiking <= 8
                                result = 0;
                            else
                                result = 0;
                            end
                        else
                            if meanAccX <= 0.684483
                                
                                if meanHorizontalAcc <= 0.279769
                                    result = 5;
                                else
                                    if meanAccZ <= 0.491124
                                        
                                        if peakToPeakRange <= 5.91579
                                            result = 0;
                                        else
                                            result = 5;
                                        end
                                    else
                                        if meanVerticalAcc <= 0.761172
                                            result = 0;
                                        else
                                            result = 5;
                                        end
                                    end
                                end
                            else
                                result = 0;
                            end
                        end
                    else
                        if varAccY <= 121.643082
                            
                            if zeroCrossingsWalking <= 27
                                result = 0;
                            else
                                if meanHorizontalAcc <= 0.230247
                                    
                                    if meanAccY <= 0.265105
                                        result = 0;
                                    else
                                        if peakToPeakRange <= 3.67648
                                            result = 0;
                                        else
                                            result = 4;
                                        end
                                    end
                                else
                                    if meanAccY <= 0.209874
                                        result = 0;
                                    else
                                        result = 4;
                                    end
                                end
                            end
                        else
                            if varAccX <= 32.026594
                                result = 5;
                            else
                                if meanAccZ <= 0.417865
                                    
                                    if peakToPeakRange <= 7.105589
                                        
                                        if zeroCrossingsWalking <= 18
                                            result = 0;
                                        else
                                            result = 0;
                                        end
                                    else
                                        result = 5;
                                    end
                                else
                                    if meanAccY <= 0.577618
                                        result = 0;
                                    else
                                        result = 5;
                                    end
                                end
                            end
                        end
                    end
                end
            else
                if meanHorizontalAcc <= 0.505566
                    
                    if zeroCrossingsWalking <= 21
                        result = 4;
                    else
                        result = 4;
                    end
                else
                    result = 0;
                end
            end
        end
    else
        if varVerticalAcc <= 1020.17511
            
            if meanAccX <= 0.599837
                result = 0;
            else
                result = 4;
            end
        else
            result = 4;
        end
    end
end
if result == 0
    if varVerticalAcc <= 475.751954
        
        if varAccX <= 426.046801
            
            if meanVerticalAcc <= 1.247621
                
                if energyWalkingSignal <= 24.248848
                    
                    if zeroCrossingsBiking <= 17
                        result = 2;
                    else
                        if energyWalkingSignal <= 20.173936
                            result = 2;
                        else
                            if meanAccX <= 0.689053
                                result = 2;
                            else
                                if zeroCrossingsWalking <= 20
                                    result = 3;
                                else
                                    result = 3;
                                end
                            end
                        end
                    end
                else
                    if meanHorizontalAcc <= 0.352803
                        
                        if meanAccX <= 0.927882
                            
                            if zeroCrossingsWalking <= 22
                                
                                if meanAccZ <= 0.388892
                                    
                                    if meanAccX <= 0.726629
                                        result = 2;
                                    else
                                        if energyWalkingSignal <= 38.551065
                                            
                                            if meanHorizontalAcc <= 0.164832
                                                result = 2;
                                            else
                                                result = 3;
                                            end
                                        else
                                            result = 2;
                                        end
                                    end
                                else
                                    if meanAccY <= 0.761025
                                        result = 3;
                                    else
                                        result = 2;
                                    end
                                end
                            else
                                if energyWalkingSignal <= 30.506659
                                    
                                    if meanAccZ <= 0.293769
                                        
                                        if peakToPeakRange <= 3.228612
                                            
                                            if varAccZ <= 54.830335
                                                result = 2;
                                            else
                                                result = 3;
                                            end
                                        else
                                            result = 2;
                                        end
                                    else
                                        result = 3;
                                    end
                                else
                                    result = 3;
                                end
                            end
                        else
                            result = 2;
                        end
                    else
                        if meanAccZ <= 0.212967
                            result = 2;
                        else
                            if varAccY <= 283.14981
                                result = 3;
                            else
                                result = 2;
                            end
                        end
                    end
                end
            else
                if meanAccY <= 0.940662
                    
                    if zeroCrossingsWalking <= 23
                        
                        if meanAccY <= 0.430198
                            
                            if varAccX <= 184.610213
                                result = 2;
                            else
                                result = 3;
                            end
                        else
                            result = 2;
                        end
                    else
                        if zeroCrossingsBiking <= 10
                            result = 3;
                        else
                            result = 3;
                        end
                    end
                else
                    if varAccY <= 112.834174
                        result = 3;
                    else
                        if varNormAcc <= 1415.504899
                            result = 2;
                        else
                            result = 3;
                        end
                    end
                end
            end
        else
            if energySignal <= 292.61554
                result = 2;
            else
                if varNormAcc <= 3278.45994
                    
                    if varAccZ <= 320.371883
                        result = 3;
                    else
                        if meanAccY <= 0.17922
                            result = 3;
                        else
                            result = 2;
                        end
                    end
                else
                    if varAccY <= 219.562306
                        result = 2;
                    else
                        result = 3;
                    end
                end
            end
        end
    else
        if zeroCrossingsWalking <= 22
            
            if meanAccY <= 0.219305
                
                if varAccY <= 174.788439
                    result = 2;
                else
                    result = 3;
                end
            else
                result = 2;
            end
        else
            if varHorizontalAcc <= 214.882632
                result = 3;
            else
                if meanAccY <= 0.267317
                    
                    if varAccY <= 176.340609
                        result = 2;
                    else
                        result = 3;
                    end
                else
                    result = 2;
                end
            end
        end
    end
end
if result == 5
    if meanAccZ <= 0.943147
        
        if meanAccX <= 0.672971
            
            if meanAccY <= 0.976032
                
                if meanAccX <= 0.60796
                    result = 5;
                else
                    if energySignal <= 49.081104
                        
                        if meanNormAcc <= 0.942147
                            result = 5;
                        else
                            result = 2;
                        end
                    else
                        result = 5;
                    end
                end
            else
                if meanHorizontalAcc <= 0.128572
                    result = 5;
                else
                    if meanVerticalAcc <= 1.02403
                        result = 2;
                    else
                        result = 5;
                    end
                end
            end
        else
            if meanAccY <= 0.376597
                result = 5;
            else
                if meanAccZ <= 0.275695
                    
                    if meanHorizontalAcc <= 0.167351
                        result = 2;
                    else
                        if meanNormAcc <= 1.079967
                            result = 2;
                        else
                            result = 5;
                        end
                    end
                else
                    if meanNormAcc <= 0.986555
                        result = 2;
                    else
                        result = 5;
                    end
                end
            end
        end
    else
        if zeroCrossingsBiking <= 9
            
            if meanVerticalAcc <= 1.027134
                
                if meanAccX <= 0.157055
                    result = 2;
                else
                    result = 5;
                end
            else
                result = 5;
            end
        else
            result = 2;
        end
    end
end
if result == 6
    if meanAccZ <= 0.93913
        
        if energyWalkingSignal <= 0.002502
            
            if energyBikingSignal <= 47.540631
                
                if varAccY <= 0.17582
                    result = 1;
                else
                    result = 6;
                end
            else
                result = 6;
            end
        else
            result = 6;
        end
    else
        if meanNormAcc <= 1.059246
            
            if meanAccX <= 0.147003
                
                if varAccY <= 0.638057
                    
                    if zeroCrossingsBiking <= 2
                        result = 1;
                    else
                        if meanAccY <= 0.357713
                            result = 1;
                        else
                            if meanAccZ <= 0.95056
                                result = 6;
                            else
                                result = 1;
                            end
                        end
                    end
                else
                    if meanAccY <= 0.277696
                        
                        if energyBikingSignal <= 48.06703
                            result = 1;
                        else
                            if meanAccZ <= 0.99501
                                result = 6;
                            else
                                result = 1;
                            end
                        end
                    else
                        if meanNormAcc <= 1.053218
                            result = 6;
                        else
                            if meanAccX <= 0.025546
                                result = 1;
                            else
                                result = 6;
                            end
                        end
                    end
                end
            else
                if meanNormAcc <= 0.995085
                    result = 1;
                else
                    result = 6;
                end
            end
        else
            result = 6;
        end
    end
end
end

