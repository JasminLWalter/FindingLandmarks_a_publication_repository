%% --------------------- step1_condenseRawData_V3.m------------------

% --------------------script written by Jasmin L. Walter----------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description: 
% First script to run in pre-processing pipeline
% Reads in raw Raycast3.0 file and condenses data, so that directly
% consecutive instances of raycast hits on the same collider are merged into 
% one row (hit point clusters). All other columns are moved into arrays 
% into each row accordingly.

% Input: 
% uses raw Raycast3.0.txt file
% Output: 
% condensedColliders_V3.mat     = new data files with each row containing 
%                                 the data of a hit point cluster
% OverviewAnalysis.mat          = summary of number and percentage of data
%                                 rows with noData (= missing data samples)
%                                 for each participant
% Missing_Participant_Files.mat = contains all participant numbers where the
%                                  data file could not be loaded

clear all;

%% adjust the following variables: savepath, current folder and participant list!-----------
savepath = '...\preprocessing\condensedColliders\';

cd '...\preprocessing\Raycast3.0\'

% Participant list of all participants that participated 90 min divided 
% into 3 sessions in the experiment in Seahaven
PartList = {1002 1089 1155 1529 1540 1582 1909 2011 2044 2098 2151 2179 3023 3299 3377 3430 3668 3686 3693 3743 3856 3949 4272 4470 4502 4510 5239 5253 5346 5507 5582 5602 5696 5978 6348 6387 6398 6430 6543 6594 6971 7021 7205 7399 7670 7942 8041 8072 8195 8258 8261 8466 8547 8551 8699 8834 8936 8954 9017 9176 9202 9364 9437 9475 9748 9961};

%% --------------------------------------------------------------------------


Number = length(PartList);
noFilePartList = [Number];
countMissingPart = 0;
missingData = array2table([]);

overviewAnalysis = array2table(zeros(Number,4));
overviewAnalysis.Properties.VariableNames = {'Participant','noData_Rows','total_Rows','percentage'};

% loop code over all participants in participant list
for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat('Raycast3.0_VP',num2str(currentPart),'.txt');
    
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList(countMissingPart,1) = currentPart;
        disp(strcat(file,' does not exist in folder'));
        
       
%% main code    
    elseif exist(file)==2
        
        %load data
        rawData = readtable(file,'Delimiter',',', 'Format','%f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');


        data = rawData;
        
        totalRows = height(data);
        
        %% clean data
               
        colliders= data.Collider;
        distances= data.Distance;
        
     
        % calculate amount of noData rows
        noD = strcmp(colliders(:),'noData');  
        NRnoDataRows = sum(noD);
        
%% create the condensed viewed houses list  

        helperT = table;
        helperT.Samples = 1;
        helperT = [data(1,1:2),helperT,data(1,3:end)];
        condensedData = table2struct(helperT);

        
        % additional variables
        previous = condensedData(1).Collider;
        time = 1000/30;
        index=1;

        
        % condense the data into clusters
      
        for index3= 2: height(data)
            
            % check if same or another house was seen
            % if the same collider occurs in direct succession in the data
            % table
            if strcmp(data.Collider{index3},previous)
                % and it is also the same as listed in the previous row of
                % the new condensed list, add all values to the existing
                % row in the condensed list
                if strcmp(condensedData(index).Collider, data.Collider{index3})
                % update all values
                condensedData(index).TimeStamp= [condensedData(index).TimeStamp,data.TimeStamp(index3)];
                condensedData(index).Samples= condensedData(index).Samples + 1;
                condensedData(index).Distance= [condensedData(index).Distance, data.Distance(index3)];
                condensedData(index).hitPointX= [condensedData(index).hitPointX,data.hitPointX(index3)];
                condensedData(index).hitPointY= [condensedData(index).hitPointY,data.hitPointY(index3)];
                condensedData(index).hitPointZ= [condensedData(index).hitPointZ,data.hitPointZ(index3)];
                condensedData(index).PosX= [condensedData(index).PosX,data.PosX(index3)];
                condensedData(index).PosY= [condensedData(index).PosY,data.PosY(index3)];
                condensedData(index).PosZ= [condensedData(index).PosZ,data.PosZ(index3)];
                condensedData(index).PosRX= [condensedData(index).PosRX,data.PosRX(index3)];
                condensedData(index).PosRY= [condensedData(index).PosRY,data.PosRY(index3)];
                condensedData(index).PosRZ= [condensedData(index).PosRZ,data.PosRZ(index3)];
                condensedData(index).PosTimeStamp= [condensedData(index).PosTimeStamp,data.PosTimeStamp(index3)];
                condensedData(index).PupilLTimeStamp= [condensedData(index).PupilLTimeStamp,data.PupilLTimeStamp(index3)];
                condensedData(index).VectorX= [condensedData(index).VectorX,data.VectorX(index3)];
                condensedData(index).VectorY= [condensedData(index).VectorY,data.VectorY(index3)];
                condensedData(index).VectorZ= [condensedData(index).VectorZ,data.VectorZ(index3)];
                condensedData(index).eye2Dx= [condensedData(index).eye2Dx,data.eye2Dx(index3)];
                condensedData(index).eye2Dy= [condensedData(index).eye2Dy,data.eye2Dy(index3)];
                
                else
                    disp('sth went wrong with the indexessssss');
                end
                
            % if collider in current row is not the same as in the previous row  
            % add a new row into the condensedData struct
            else
                % adjust index
                index = index +1;
                
                % add new row with all the data
                condensedData(index).TimeStamp= data.TimeStamp(index3);
                condensedData(index).Collider= data.Collider{index3};
                condensedData(index).Samples= 1;
                condensedData(index).Distance= data.Distance(index3);
                condensedData(index).hitPointX= data.hitPointX(index3);
                condensedData(index).hitPointY= data.hitPointY(index3);
                condensedData(index).hitPointZ= data.hitPointZ(index3);
                condensedData(index).PosX= data.PosX(index3);
                condensedData(index).PosY= data.PosY(index3);
                condensedData(index).PosZ= data.PosZ(index3);
                condensedData(index).PosRX= data.PosRX(index3);
                condensedData(index).PosRY= data.PosRY(index3);
                condensedData(index).PosRZ= data.PosRZ(index3);
                condensedData(index).PosTimeStamp= data.PosTimeStamp(index3);
                condensedData(index).PupilLTimeStamp= data.PupilLTimeStamp(index3);
                condensedData(index).VectorX= data.VectorX(index3);
                condensedData(index).VectorY= data.VectorY(index3);
                condensedData(index).VectorZ= data.VectorZ(index3);
                condensedData(index).eye2Dx= data.eye2Dx(index3);
                condensedData(index).eye2Dy= data.eye2Dy(index3);
                
%                 
                % update previous element
                previous = data.Collider(index3);
                
            end
            
            
        end
        
            
            % save condensed viewed houses
            
            save([savepath num2str(currentPart) '_condensedColliders_V3.mat'],'condensedData');
            
            % update overview
            
            overviewAnalysis.Participant(ii)= currentPart;
            overviewAnalysis.noData_Rows(ii)= NRnoDataRows;
            overviewAnalysis.total_Rows(ii)= totalRows;
            
            percent = (NRnoDataRows*100)/totalRows;
            
            overviewAnalysis.percentage(ii) = percent;


    else
        disp('something went really wrong with participant list');
    end
    
    
end
 
disp(strcat(num2str(Number), ' of Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

save([savepath 'OverviewAnalysis.mat'],'overviewAnalysis');
disp('saved overview Analysis ');

disp('done');
