%% -----------------------step4_gazes_vs_noise_V3.m------------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description:
% Fourth step in the preprocessing pipeline.
% Script divides the interpolated Collider data based on the gaze threshold 
% into gazes and noisy samples (excluded data), i.e. it identifies the gaze events


% Input: 
% interpolatedColliders_3Sessions_V3.mat = the interpolated data file

% Output: 
% gazes_data_V3.mat = a new data file containing all gazes

% noisy_data_V3.mat = all excluded data

% Overview_Gazes.mat = overview of the amount of gazes and excluded data 
%                      for each participant
        
% Missing_Participant_Files.mat = contains all participant numbers where the
%                                  data file could not be loaded

clear all;

%% adjust the following variables: savepath, current folder and participant list!-----------

savepath = '...\preprocessing\gazes_vs_noise\';

cd '...\preprocessing\interpolatedColliders\';

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

%----------------------------------------------------------------------------

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