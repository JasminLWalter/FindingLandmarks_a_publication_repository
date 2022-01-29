%%---------------------create_noisyCSV-------------------------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description:
% The script creates csv versions of the Matlab noisy data files 
% (excluded data), created during running the script step4_gazes_vs_noise
% of the preprocessing pipeline.

% Input:
% noisy_data_V3.mat = the data file containing all excluded / noisy data

% Output:
% noisy_data.csv = the same file in csv format

clear all;

%% adjust the following variables: savepath, current folder and participant list!-----------

savepath = '...\preprocessing\csv_preprocessedData\(excluded)noisy_data\';

cd '...\preprocessing\gazes_vs_noise\'

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
    
    file = strcat('noisy_data_',num2str(currentPart),'.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2
        countAnalysedPart = countAnalysedPart +1;

        % load data
        noisyObjects = load(file);
        noisyObjects = noisyObjects.noisyObjects;
        
%         % remove noData rows if desired
%         noData = strcmp(gazedObjects.House,'noData');
%         gazes = gazedObjects;
%         gazes(noData,:) = [];
        
        writetable(noisyObjects,strcat(savepath,num2str(currentPart),'noisy_data.csv'));
        
    else
        disp('something went really wrong with participant list');
    end

end
disp(strcat(num2str(Number), ' Participants in List'));
disp(strcat(num2str(countAnalysedPart), ' Participants analyzed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');


disp('saved Overview Gazes');

disp('done');