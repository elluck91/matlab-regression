function [ filteredState ] = TemporalMetaClassifier_Carry(currentState,ifFirst)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
persistent onDeskTimeMap inHandTimeMap nearHeadTimeMap shirtPocketTimeMap trouserPocketTimeMap armSwingTimeMap jacketPocketTimeMap
persistent confidentState

if ifFirst
    onDeskTimeMap = 0;
    inHandTimeMap = 0;
    nearHeadTimeMap = 0;
    shirtPocketTimeMap = 0;
    trouserPocketTimeMap = 0; 
    armSwingTimeMap = 0;
    jacketPocketTimeMap = 0;
    
    confidentState = 0;
end

%Shift with time all time maps and remove the not required bits
onDeskTimeMap = onDeskTimeMap*2^1;               onDeskTimeMap = mod(onDeskTimeMap,2^7);
inHandTimeMap = inHandTimeMap*2^1;               inHandTimeMap = mod(inHandTimeMap,2^7);
nearHeadTimeMap = nearHeadTimeMap*2^1;           nearHeadTimeMap = mod(nearHeadTimeMap,2^7);
shirtPocketTimeMap = shirtPocketTimeMap*2^1;     shirtPocketTimeMap = mod(shirtPocketTimeMap,2^7);
trouserPocketTimeMap = trouserPocketTimeMap*2^1; trouserPocketTimeMap = mod(trouserPocketTimeMap,2^7);
armSwingTimeMap = armSwingTimeMap*2^1;           armSwingTimeMap = mod(armSwingTimeMap,2^7);
jacketPocketTimeMap = jacketPocketTimeMap*2^1;   jacketPocketTimeMap = mod(jacketPocketTimeMap,2^7);

%Update the time maps
switch currentState
    case 1
        onDeskTimeMap = onDeskTimeMap+1;
    case 2
        inHandTimeMap = inHandTimeMap+1;
    case 3
        nearHeadTimeMap = nearHeadTimeMap+1;
    case 4
        shirtPocketTimeMap = shirtPocketTimeMap+1;
    case 5
        trouserPocketTimeMap = trouserPocketTimeMap+1;
    case 6
        armSwingTimeMap = armSwingTimeMap+1;
    case 7
        jacketPocketTimeMap = jacketPocketTimeMap+1;
end

%Get last 5 instances and see if all 5 are onDesk
onDeskVotes = GetSumOfBits_Carry(onDeskTimeMap,5);
if onDeskVotes == 5
    confidentState = 1;
end

%Get last 5 instances and see if all 5 are inHand
inHandVotes = GetSumOfBits_Carry(inHandTimeMap,5);
if inHandVotes == 5
    confidentState = 2;
end

%Get last 5 instances and see if all 5 are NearHead
nearHeadVotes = GetSumOfBits_Carry(nearHeadTimeMap,5);
if nearHeadVotes == 5
    confidentState = 3;
end

%Get last 5 instances and see if all 5 are Shirt Pocket
shirtPocketVotes = GetSumOfBits_Carry(shirtPocketTimeMap,5);
if shirtPocketVotes == 5
    confidentState = 4;
end

%Get last 5 instances and see if all 5 are Trouser Pocket
trouserPocketVotes = GetSumOfBits_Carry(trouserPocketTimeMap,5);
if trouserPocketVotes == 5
    confidentState = 5;
end

%Get last 5 instances and see if all 5 are Arm Swing
armSwingVotes = GetSumOfBits_Carry(armSwingTimeMap,5);
if armSwingVotes  == 5;
    confidentState = 6;
end

%Get last 5 instances and see if all 5 are Jacket Pocket
jacketPocketVotes = GetSumOfBits_Carry(jacketPocketTimeMap,5);
if jacketPocketVotes == 5
    confidentState = 7;
end

%Current state is unknown, make the output as unknown
if currentState == 0
    confidentState = 0;
end
filteredState = confidentState;
end

