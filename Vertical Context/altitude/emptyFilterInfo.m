function [z] = emptyFilterInfo()
z = struct('v', 0, ...  %BOOL
    'slope', 0, ...     %FLOAT
    'c', 0, ...         %FLOAT
    'sE',0, ...         %FLoat
    'sC', 0, ...        %float
    'isStationary', 0); %Bool
end