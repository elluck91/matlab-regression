function z = emptyAttKnobs()
z = struct('modX', uint8(attConsts.default_modX), ...
    'gbias_mode', uint8(attConsts.gbias_mode_static), ...
    'stopActionFilter', single(1), ... %U8
    'dynamic_accel_mode',uint8(attConsts.dynamic_accel_mode_off), ...
    'sensorFlags', [1 1 1], ... %MAG, default always on 
    'gyro_time_constant', single(1), ...
    'gbias_thresh', single(attConsts.defaultGbias_thresh), ...
    'gbias_mag_th_sc', single(attConsts.defaultGbias_mag_th_sc), ...  %gbias_thresh*single(6.6e-4); % for SP2
    'gbias_acc_th_sc', single(attConsts.defaultGbias_acc_th_sc), ...  %gbias_thresh*single(25e-4);
    'gbias_gyro_th_sc', single(attConsts.defaultGbias_gyro_th_sc), ... %gbias_thresh*single(0.5);
    'gbias_process', single(attConsts.defaultGbias_process), ...
    'ATime',single(attConsts.defaultATime), ...
    'MTime',single(attConsts.defaultMTime), ...
    'PTime',single(attConsts.defaultPTime), ...
    'FrTime',single(attConsts.defaultFrTime));
end