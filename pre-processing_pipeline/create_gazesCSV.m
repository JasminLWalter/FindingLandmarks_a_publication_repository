%%---------------------create_gazesCSV--------------------------------------
% script written by Jasmin Walter

% uses gazes_vs_noise files to create csv files for all gazes
% removes the remaining noData rows

clear all;

savepath = 'E:\SeahavenEyeTrackingData\csv_preprocessedData\';

cd 'E:\SeahavenEyeTrackingData\duringProcessOfCleaning\gazes_vs_noise\'

% participant list of 90 min VR - only with participants who have lost less than 30% of
% their data (after running script cleanParticipants_V2)
% PartList = {1909 3668 8466 2151 4502 7670 8258 3377 9364 6387 2179 4470 6971 5507 8834 5978 7399 9202 8551 1540 8041 3693 5696 3299 1582 6430 9176 5602 3856 7942 6594 4510 3949 3686 6543 7205 5582 9437 1155 8547 8261 3023 7021 9961 9017 2044 8195 4272 5346 8072 6398 3743 5253 9475 8954 8699 3593};

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;
countAnalysedPart= 0;

for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat('gazes_data_',num2str(currentPart),'.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2
        countAnalysedPart = countAnalysedPart +1;

        % load data
        gazedObjects = load(file);
        gazedObjects = gazedObjects.gazedObjects;
        
%         % remove noData rows
%         noData = strcmp(gazedObjects.House,'noData');
%         gazes = gazedObjects;
%         gazes(noData,:) = [];
        
        writetable(gazedObjects,strcat(savepath,'gazes_',num2str(currentPart),'.csv'));
        
    else
        disp('something went really wrong with participant list');
    end

end
disp(strcat(num2str(Number), ' Participants in List'));
disp(strcat(num2str(countAnalysedPart), ' Participants analyzed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

% overviewGazes = load('Overview_Gazes.mat');
% overviewGazes = overviewGazes.overviewGazes;
% 
% writetable(overviewGazes,strcat(savepath,'overview_gazes_noise.csv'));

disp('saved Overview Gazes');

disp('done');