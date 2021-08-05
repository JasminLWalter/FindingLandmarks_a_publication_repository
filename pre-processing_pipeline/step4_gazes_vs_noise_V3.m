%% ------------------step 4: gazes_vs_noise Version 3----------------------------------------
% script written by Jasmin Walter

% divides condensed Collider list based on a set min sample value into 
% gazes and noisy samples
% in other words: devides condensed viewed houses list into gazes
% and noise

% uses condensedCollider files as input
% output: list with glanced houses per subject -> objects that were gazed at
%         list with noisy sample objects per subject -> objects that were
%         not gazed on
%         overall overview with percentage of gazed/noisy object list


clear all;

savepath = 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\preprocessing\gazes_vs_noise\';

cd 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\preprocessing\interpolatedColliders\';

% participant list of 90 min VR - only with participants who have lost less than 30% of
% their data (after running script cleanParticipants_V2)
%PartList = {1909 3668 8466 2151 4502 7670 8258 3377 9364 6387 2179 4470 6971 5507 8834 5978 7399 9202 8551 1540 8041 3693 5696 3299 1582 6430 9176 5602 3856 7942 6594 4510 3949 3686 6543 7205 5582 9437 1155 8547 8261 3023 7021 9961 9017 2044 8195 4272 5346 8072 6398 3743 5253 9475 8954 8699 3593};

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};



Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;
countAnalysedPart= 0;

overviewGazes = array2table(zeros(Number,4));
overviewGazes.Properties.VariableNames = {'Participant','totalAmount','gazes','noise'};


for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat(num2str(currentPart),'_interpolatedColliders_3Sessions_V3.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2
        countAnalysedPart = countAnalysedPart +1;
        % load data
        interpolatedData = load(file);
        interpolatedData = interpolatedData.interpolatedData;
        
        % something was fixated when having more than 7 samples
        

        gazes = [interpolatedData.Samples] > 7 | strcmp({interpolatedData.Collider}, 'newSession');
        
        

        
        gazedObjects = interpolatedData(gazes);
        
        noisyObjects = interpolatedData(not(gazes));
              
        
        
        % save both tables
        save([savepath num2str(currentPart) '_gazes_data_V3.mat'],'gazedObjects');
        save([savepath num2str(currentPart) '_noisy_data_V3.mat'],'noisyObjects');
        
        % update overview with values
        
        overviewGazes.Participant(countAnalysedPart)= currentPart;
        overviewGazes.totalAmount(countAnalysedPart)= length(interpolatedData);
        overviewGazes.gazes(countAnalysedPart)= length(gazedObjects);
        overviewGazes.noise(countAnalysedPart) = length(noisyObjects);
        
     
  

        
    else
        disp('something went really wrong with participant list');
    end

end
disp(strcat(num2str(Number), ' Participants in List'));
disp(strcat(num2str(countAnalysedPart), ' Participants analyzed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

save([savepath 'Overview_Gazes.mat'],'overviewGazes');
disp('saved Overview Gazes');

disp('done');