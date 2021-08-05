%% ------------------ step1_condense Raw Data Version 3.0--------------------------------
% script written by Jasmin Walter

% takes raw Raycast3.0 file and condenses them, so that several
% instances of colliders merged into one row. All other columns are moved into an array 
% accordingly
% renames some aspects for more intuitive understanding of the data

% uses raw Raycast3.0.txt file
% output: condensedColliders_V3.mat file 
clear all;
% adjust savepath, current folder and participant list!
savepath = 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\preprocessing\condensedColliders\';

cd 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\preprocessing\Raycast3.0\'


% Participant list of all participants that participated at least 3
% sessions in the experiment in Seahaven - 90min (no belt participants)
PartList = {1909 3668 8466 3430 6348 2151 4502 7670 8258 3377 1529 9364 6387 2179 4470 6971 5507 8834 5978 1002 7399 9202 8551 1540 8041 3693 5696 3299 1582 6430 9176 5602 2011 2098 3856 7942 6594 4510 3949 9748 3686 6543 7205 5582 9437 1155 8547 8261 3023 7021 5239 8936 9961 9017 1089 2044 8195 4272 5346 8072 6398 3743 5253 9475 8954 8699 3593 9848};



Number = length(PartList);
noFilePartList = [Number];
countMissingPart = 0;
missingData = array2table([]);

overviewAnalysis = array2table(zeros(Number,4));
overviewAnalysis.Properties.VariableNames = {'Participant','noData_Rows','total_Rows','percentage'};


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
        
        % rename NH to sky if they looked into the sky
        
        colliders= data.Collider;
        distances= data.Distance;
%         skyHouse = strcmp(colliders(:),'NH') & (distances(:)==200);
%          
%         store the renamed rows for checking
%         skyRows= data(skyHouse,:);
%         
%         rename rows to sky
%         data.Collider(skyHouse)= cellstr('sky');
        
     
        % rename rows when pupils were detected with probability lower than 0,5
        noD = strcmp(colliders(:),'noData');  
%         % old code renaming NH + distance 0 to noData
%         noD = strcmp(colliders(:),'NH') & eq(distances(:),0);     
%         %rename rows
%          data.Collider(noD)= cellstr('noData');
%          data.Distance(noD) = NaN;
%          data.VectorX(noD) = NaN;
%          data.VectorY(noD) = NaN;
%          data.VectorZ(noD) = NaN;
%          data.eye2Dx(noD) = NaN;
%          data.eye2Dy(noD) = NaN;
         
        % calculate amount of noData rows
        NRnoDataRows = sum(noD);
        
%% create the condensed viewed houses list  
%         % create AllData Table
%         NumArray = array2table(zeros(height(data),3));
%         SeenHouses = cell(height(data),1);
%         AllData= [SeenHouses NumArray];
%         AllData.Properties.VariableNames = {'House','Time','Samples','Distances'};
        
        % create struct for all data with only one row (the others will be
        % added according to the condensation process
        helperT = table;
        helperT.Samples = 1;
        helperT = [data(1,1:2),helperT,data(1,3:end)];
        condensedData = table2struct(helperT);

        

        % additional variables
        previous = condensedData(1).Collider;
        time = 1000/30;
        index=1;

        
        % condenses the data
      
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
                
%                 AllData.Samples(index)= AllData.Samples(index) +1;
%                 AllData.Distances(index) = AllData.Distances(index) + data.Distance(index3);
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
        
%         % adjust distances (so far they are only sums, now average them)
%         AllData.Distances= AllData.Distances ./ AllData.Samples;
%         
%             % remove all empty lines of AllData
%             uncutAllData = AllData;
%             AllData = head(AllData, index);
%             
%             
            
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
