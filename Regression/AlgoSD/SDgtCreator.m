function smartGT = SDgtCreator(gt, ouputDir)
    smartGT=[ouputDir '/Smart_GroundTruth_Tag_Data.csv'];
    fgttag=fopen(smartGT,'w');
    %fprintf(fgttag,'MessageID,GT Step Count\n');
    fprintf(fgttag,'10505, %s,',gt);
    fclose(fgttag);
end