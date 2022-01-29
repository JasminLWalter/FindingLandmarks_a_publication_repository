%% -------------------step3_interpolateLostData_V3.m-----------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description: 
% Third script to run in pre-processing pipeline
% applies the interpolation of lost data samples (noData) if the
% interpolation conditions apply: interpolation of clusters only iff: 
% noData clusters are < 8 samples big and occur between the same collider

% Input: 
% condensedColliders_3Sessions_V3.mat = the condesedColliders file after
%                                       combining all 3 session in the
%                                       script
%                                       "step2_optional_join3SessionsVR_V3"
% Output: 
% interpolatedColliders_3Sessions_V3.mat = the newly interpolated data file

% Missing_Participant_Files.mat = contains all participant numbers where the
%                                  data file could not be loaded


clear all;

%% adjust the following variables: savepath, current folder and participant list!-----------

savepath = '...\preprocessing\interpolatedColliders\';

cd '...\preprocessing\combined3sessions\'


% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

% --------------------------------------------------------------------------

Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;

checkInterpolation = [];


for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat(num2str(currentPart),'condensedColliders_3Sessions_V3.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2
        
        % load data
        condensedColliders = load(file);
        condensedColliders = condensedColliders.condensedColliders3S;
        rawSave = condensedColliders;
        
        interpolatedData = condensedColliders;
      
        
        firstSum = sum([condensedColliders.Samples]);
        firstSumCHeck = sum([interpolatedData.Samples]);
        removeRows = false(length(condensedColliders),1);
        testi = zeros(length(condensedColliders),1);
        problem = 0;
        rowTest = 0;
        exceptions = 0;

        % go through all rows
        for index = 1:length(condensedColliders)

            % if the row is a noData row
            if strcmp(condensedColliders(index).Collider,'noData')
  
                cNrSample = condensedColliders(index).Samples;
                
            % if number of missing samples if small enough, they get
            % interpolated
            if (cNrSample < 8)
                
                ibefore = index -1;
                iafter = index+1;
                % catch exceptions
                if index ==1 % if it is the first row - no interpolation
                    exceptions = exceptions +1;
                    
                elseif index == length(condensedColliders) % if it is the last row, no interpolation
                    exceptions = exceptions +1;
                    
              
                %% differentiating if seen houses before and after missing
                % if colliders are identical
                elseif strcmp(condensedColliders(index-1).Collider,condensedColliders(index+1).Collider)
                    
                    % and if the line before was not already marked for removal
                    if (removeRows(index-1) == false)
                        % combine all samples falling on the same house into
                        % one row
                        % note that clusters between sessions cant be
                        % interpolated, therefore the session variable does
                        % not need to be updated in case of interpolation

%                         
                        
                        
                        interpolatedData(index-1).TimeStamp= [interpolatedData(index-1).TimeStamp,interpolatedData(index).TimeStamp, interpolatedData(index+1).TimeStamp];
                        interpolatedData(index-1).Samples= interpolatedData(index-1).Samples + interpolatedData(index).Samples + interpolatedData(index+1).Samples;
                        interpolatedData(index-1).Distance= [interpolatedData(index-1).Distance, interpolatedData(index).Distance, interpolatedData(index+1).Distance];
                        interpolatedData(index-1).hitPointX= [interpolatedData(index-1).hitPointX, interpolatedData(index).hitPointX, interpolatedData(index+1).hitPointX];
                        interpolatedData(index-1).hitPointY= [interpolatedData(index-1).hitPointY, interpolatedData(index).hitPointY, interpolatedData(index+1).hitPointY];
                        interpolatedData(index-1).hitPointZ= [interpolatedData(index-1).hitPointZ, interpolatedData(index).hitPointZ, interpolatedData(index+1).hitPointZ];
                        interpolatedData(index-1).PosX= [interpolatedData(index-1).PosX, interpolatedData(index).PosX, interpolatedData(index+1).PosX];
                        interpolatedData(index-1).PosY= [interpolatedData(index-1).PosY,interpolatedData(index).PosY,interpolatedData(index+1).PosY];
                        interpolatedData(index-1).PosZ= [interpolatedData(index-1).PosZ,interpolatedData(index).PosZ,interpolatedData(index+1).PosZ];
                        interpolatedData(index-1).PosRX= [interpolatedData(index-1).PosRX,interpolatedData(index).PosRX,interpolatedData(index+1).PosRX];
                        interpolatedData(index-1).PosRY= [interpolatedData(index-1).PosRY, interpolatedData(index).PosRY, interpolatedData(index+1).PosRY];
                        interpolatedData(index-1).PosRZ= [interpolatedData(index-1).PosRZ, interpolatedData(index).PosRZ, interpolatedData(index+1).PosRZ];
                        interpolatedData(index-1).PosTimeStamp= [interpolatedData(index-1).PosTimeStamp,interpolatedData(index).PosTimeStamp,interpolatedData(index+1).PosTimeStamp];
                        interpolatedData(index-1).PupilLTimeStamp= [interpolatedData(index-1).PupilLTimeStamp,interpolatedData(index).PupilLTimeStamp,interpolatedData(index+1).PupilLTimeStamp];
                        interpolatedData(index-1).VectorX= [interpolatedData(index-1).VectorX,interpolatedData(index).VectorX,interpolatedData(index+1).VectorX];
                        interpolatedData(index-1).VectorY= [interpolatedData(index-1).VectorY,interpolatedData(index).VectorY,interpolatedData(index+1).VectorY];
                        interpolatedData(index-1).VectorZ= [interpolatedData(index-1).VectorZ,interpolatedData(index).VectorZ,interpolatedData(index+1).VectorZ];
                        interpolatedData(index-1).eye2Dx= [interpolatedData(index-1).eye2Dx,interpolatedData(index).eye2Dx,interpolatedData(index+1).eye2Dx];
                        interpolatedData(index-1).eye2Dy= [interpolatedData(index-1).eye2Dy,interpolatedData(index).eye2Dy,interpolatedData(index+1).eye2Dy];
                        
                        
                        
                        
                        
                    elseif (removeRows(index-1) == true)
                        % if row before was already marked for removal
                        % backtracking to find last unmarked house
                        rowTest = index-1;

                        while removeRows(rowTest)

                            
                            rowTest = rowTest -1;

                            if rowTest < 1
                                break
                            end

                        end
                        % then update the row that combines all of the
                        % interpolated data
                        
                        % note that clusters between sessions cant be
                        % interpolated, therefore the session variable does
                        % not need to be updated in case of interpolation

% 
%                         
                        interpolatedData(rowTest).TimeStamp= [interpolatedData(rowTest).TimeStamp,interpolatedData(index).TimeStamp, interpolatedData(index+1).TimeStamp];
                        interpolatedData(rowTest).Samples= interpolatedData(rowTest).Samples + interpolatedData(index).Samples + interpolatedData(index+1).Samples;
                        interpolatedData(rowTest).Distance= [interpolatedData(rowTest).Distance, interpolatedData(index).Distance, interpolatedData(index+1).Distance];
                        interpolatedData(rowTest).hitPointX= [interpolatedData(rowTest).hitPointX, interpolatedData(index).hitPointX, interpolatedData(index+1).hitPointX];
                        interpolatedData(rowTest).hitPointY= [interpolatedData(rowTest).hitPointY, interpolatedData(index).hitPointY, interpolatedData(index+1).hitPointY];
                        interpolatedData(rowTest).hitPointZ= [interpolatedData(rowTest).hitPointZ, interpolatedData(index).hitPointZ, interpolatedData(index+1).hitPointZ];
                        interpolatedData(rowTest).PosX= [interpolatedData(rowTest).PosX, interpolatedData(index).PosX, interpolatedData(index+1).PosX];
                        interpolatedData(rowTest).PosY= [interpolatedData(rowTest).PosY,interpolatedData(index).PosY,interpolatedData(index+1).PosY];
                        interpolatedData(rowTest).PosZ= [interpolatedData(rowTest).PosZ,interpolatedData(index).PosZ,interpolatedData(index+1).PosZ];
                        interpolatedData(rowTest).PosRX= [interpolatedData(rowTest).PosRX,interpolatedData(index).PosRX,interpolatedData(index+1).PosRX];
                        interpolatedData(rowTest).PosRY= [interpolatedData(rowTest).PosRY, interpolatedData(index).PosRY, interpolatedData(index+1).PosRY];
                        interpolatedData(rowTest).PosRZ= [interpolatedData(rowTest).PosRZ, interpolatedData(index).PosRZ, interpolatedData(index+1).PosRZ];
                        interpolatedData(rowTest).PosTimeStamp= [interpolatedData(rowTest).PosTimeStamp,interpolatedData(index).PosTimeStamp,interpolatedData(index+1).PosTimeStamp];
                        interpolatedData(rowTest).PupilLTimeStamp= [interpolatedData(rowTest).PupilLTimeStamp,interpolatedData(index).PupilLTimeStamp,interpolatedData(index+1).PupilLTimeStamp];
                        interpolatedData(rowTest).VectorX= [interpolatedData(rowTest).VectorX,interpolatedData(index).VectorX,interpolatedData(index+1).VectorX];
                        interpolatedData(rowTest).VectorY= [interpolatedData(rowTest).VectorY,interpolatedData(index).VectorY,interpolatedData(index+1).VectorY];
                        interpolatedData(rowTest).VectorZ= [interpolatedData(rowTest).VectorZ,interpolatedData(index).VectorZ,interpolatedData(index+1).VectorZ];
                        interpolatedData(rowTest).eye2Dx= [interpolatedData(rowTest).eye2Dx,interpolatedData(index).eye2Dx,interpolatedData(index+1).eye2Dx];
                        interpolatedData(rowTest).eye2Dy= [interpolatedData(rowTest).eye2Dy,interpolatedData(index).eye2Dy,interpolatedData(index+1).eye2Dy];
                        
                        
                        
                        
                    else
                        problem = problem +1;
                        disp('there is a problem' + problem);
                    end

                    
                    % mark the lines for removal.
                    
                    removeRows(index) = 1; 
                    removeRows(index+1) = 1;

                %% if houses are different - do nothing
                
                

                    
                end   

            end
          
            end
          
            
        end
        
        %% remove all marked rows from interpolatedData and save them into
        % interpolatedCollider files
        

        interpolatedData(removeRows) = [];
        
        save([savepath num2str(currentPart) '_interpolatedColliders_3Sessions_V3.mat'],'interpolatedData');
           
        % doublecheck cleaning: 
         
        secondSum = sum([interpolatedData.Samples]);
        checkInterpolation = [checkInterpolation; currentPart, firstSum, secondSum ];
        
        
        
    else
        disp('something went really wrong with participant list');
    end

end

checkInterpolation = [checkInterpolation; 0, sum(checkInterpolation(:,2)), sum(checkInterpolation(:,3))];

disp(strcat(num2str(Number), ' Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

disp('done');