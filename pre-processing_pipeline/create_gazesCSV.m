%% ---------------------create_gazesCSV.m----------------------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description:
% The script creates csv versions of the Matlab gaze data files, created
% during running the script step4_gazes_vs_noise of the preprocessing pipeline.

% Input:
% gazes_data_V3.mat = the data file containing all gazes

% Output:
% gazes_data.csv = the same file in csv format

clear all;

%% adjust the following variables: savepath, current folder and participant list!-----------

savepath = '...preprocessing\csv_preprocessedData\gaze_data\';

cd '...preprocessing\gazes_vs_noise\'

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

%--------------------------------------------------------------------------


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
        
%         % remove noData rows if desired
%         noData = strcmp(gazedObjects.House,'noData');
%         gazes = gazedObjects;
%         gazes(noData,:) = [];
        
        writetable(gazedObjects,strcat(savepath,num2str(currentPart),'_gazes_data.csv'));
        
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