function M5_API_SmartActivityCode_Data_Address=M5_API_Algorithm_Smart_GroundTruth_Comparison(M5_API_Algorithm_Decision_Timestamp_Data_Address,M5_API_Smart_GT_Data_Address,M5_API_Folder_Address)

%COMPARING REGRESSION ALGO(PART I), SMART START STOP TAG(PART II) TIMESTAMPS
falgo=fopen(M5_API_Algorithm_Decision_Timestamp_Data_Address);
ftag=fopen(M5_API_Smart_GT_Data_Address);
M5_API_SmartActivityCode_Data_Address=[M5_API_Folder_Address '/SmartActivitycodeprocessed.csv'];

fsmartalgo=fopen([M5_API_Folder_Address '/SmartActivitycodeprocessed.csv'],'w');
fprintf(fsmartalgo,'Timestamp, Algo activity code, Smart GroundTruth\n');
algoline=fgetl(falgo);
%Exclude first line as it has column heading information
tagline=fgetl(ftag);

% Copy start stop tag contents to an array
Taglineno=1;
tagline=fgetl(ftag);
starttag = 0;
stoptag = 0;

while ischar(tagline)
    t=strfind(tagline,',');
    smartgroundtruth(Taglineno)=str2num(tagline(t(1)+2:t(2)-1));
    starttag(Taglineno)=str2num(tagline(t(2)+2:t(3)-1));
    stoptag(Taglineno)=str2num(tagline(t(3)+2:t(4)-1));
    Taglineno=Taglineno+1;
    tagline=fgetl(ftag);
end
starttaglength=length(starttag);

% Traverse through activity code lines and compare with start stop tag timestamp
Taglineno=1;activitycodeend=0;
while ischar(algoline)
    a=strfind(algoline,',');
    algotimestamp=str2num(algoline(1:a(1)-1));
    activitycode=str2num(algoline(a(1)+1:a(2)-1));
    if algotimestamp>=starttag(Taglineno) && algotimestamp<stoptag(Taglineno)
        fprintf(fsmartalgo,'%.1f, %d, %d\n',algotimestamp,activitycode,smartgroundtruth(Taglineno));
    else
        if Taglineno<starttaglength
            if algotimestamp>starttag(Taglineno+1)
                Taglineno=Taglineno+1;
                fprintf(fsmartalgo,'%.1f, %d, %d\n',algotimestamp,activitycode,smartgroundtruth(Taglineno));
            end
        elseif Taglineno==starttaglength
            fprintf(fsmartalgo,'%.1f, %d, %d\n',algotimestamp,activitycode,activitycodeend);
        end
    end
    algoline=fgetl(falgo);
end

fclose('all');
end