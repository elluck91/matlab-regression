function [accDataAddr, gt] = M2_API_Sensor_Data_Extraction(stPdr,outputDir, algo)
gt = M2_API_ExtractAccelMagAndGyroMsgs(stPdr,outputDir, algo);
accDataAddr = OptimizedExtractionForApp(outputDir);
end