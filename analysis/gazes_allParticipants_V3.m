%% ------------------ gazes_allParticipants_V3.m---------------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description:
% Script combines all gazes data from all participants into one file.
% Script also combines all interpolated data files from all participants
% into one file. 

% Input:
% gazes_data_V3.mat = gaze data files
% interpolatedColliders_3Sessions_V3.mat = interpolated data files

% Output:
% gazes_allParticipants = combined gaze files from all participants
% interpolData_allParticipants = combined interpolated data files from all participants            

% Missing_Participant_Files.mat    = contains all participant numbers where the
%                                    data file could not be loaded
%                                   NOTE: only checks the gazes files


clear all;

%% adjust the following variables: 
% savepath, gazePath, interpolPath, and PartList---------------------------

savepath= '...\analysis\all_participants\';

gazePath = '...\preprocessing\gazes_vs_noise\';

interpolPath = '...\preprocessing\interpolatedColliders\';

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

%---------------------------------------------------------------------------

Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;


for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    
    file = strcat(gazePath, num2str(currentPart),'_gazes_data_V3.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2
      
        %% gazes
        % load gaze data
        gazedObjects = load(file);
        gazedObjects = gazedObjects.gazedObjects;
        % create table with necessary fields
        
        if (ii ==1)
        
            gazes_allParticipants = gazedObjects;
        else
            
            gazes_allParticipants = [gazes_allParticipants, gazedObjects];
        end
        
       clear gazedObjects

       
       %% interpolated data
    
       % load interpolated data
        file2 = strcat(interpolPath,num2str(currentPart),'_interpolatedColliders_3Sessions_V3.mat');
        interpolatedData = load(file2);
        interpolatedData = interpolatedData.interpolatedData;
        % create table with necessary fields
        
        if (ii ==1)
        
            interpolData_allParticipants = interpolatedData;
        else
            
            interpolData_allParticipants = [interpolData_allParticipants, interpolatedData];
        end
        
       clear interpolatedObjects

        
    else
        disp('something went really wrong with participant list');
    end

end


save(strcat(savepath,'gazes_allParticipants'),'gazes_allParticipants');
save(strcat(savepath,'interpolData_allParticipants'),'interpolData_allParticipants');            

disp(strcat(num2str(Number), ' Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

 csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
 disp('saved missing participant file list');

disp('done');