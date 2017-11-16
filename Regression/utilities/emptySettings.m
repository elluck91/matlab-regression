function emptySettings = emptySettings()
    emptySettings = struct('HOME', '', ...
        'output', '', ...
        'algo', '', ...
        'pathList', [], ...
        'userName', '', ...
        'uniqueId', '');
end

function emptyPaths = emptyPaths()
    emptyPaths = struct('paths', []);
end