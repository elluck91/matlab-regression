function [ sumOfBits ] = GetSumOfBits( data,instances )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
sumOfBits = 0;
for i=1:instances
    if mod(data,2) == 1
        sumOfBits = sumOfBits+1;
        data = data-1;
    end
    data = floor(data/2);
end
end

