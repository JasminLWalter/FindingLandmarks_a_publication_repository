%% ------------------ create_Graphs Version 3-------------------------------------
% script written by Jasmin Walter

% 5th and last step of prepreocessing pipeline to create graphs from VR
% data
% step unnecessary if analysis does not involve graphs
% creates graph objects using gazesObject files
% removes all repetition and self references from graphs
% removes noData node after creation of graph
% output: graph objects for every participant

clear all;


savepath= 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\preprocessing\graphs\';


cd 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\preprocessing\gazes_vs_noise\'

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};


Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;



for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    
    file = strcat(num2str(currentPart),'_gazes_data_V3.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2
        
        % load data
        gazedObjects = load(file);
        gazedObjects = gazedObjects.gazedObjects;
        % create table with necessary fields
        
        gazedTable = table;
        gazedTable.Collider = {gazedObjects.Collider}';
        gazedTable.Samples = [gazedObjects.Samples]';
        
        currentPartName= strcat('Participant_',num2str(currentPart));
        
        % remove all NH and sky elements
        nohouse=strcmp(gazedTable.Collider(:),cellstr('NH')) | strcmp(gazedTable.Collider(:),cellstr('sky'));
        housesTable = gazedTable;
        housesTable(nohouse,:)=[];
        
        % create nodetable
        uniqueHouses= unique(housesTable.Collider);
        NodeTable= cell2table(uniqueHouses, 'VariableNames',{'Name'});
        
        % create edge table
        
        fullEdgeT= cell2table(housesTable.Collider,'VariableNames',{'Column1'});
        
        % prepare second column to add to specify edges
        secondColumn = fullEdgeT.Column1;
        % remove first element of 2nd column
        secondColumn(1,:)=[];  
        % remove last element of 1st column
        fullEdgeT(end,:)= [];
        
        % add second column to table
        fullEdgeT.Column2 = secondColumn;
 
        
        % remove all repetitions
        % 1st round- using unique
        
        uniqueTable= unique(fullEdgeT);

        % 2nd round using for loop
        
        %check if first entry is a self-reference
        %create edgetable
        
        if (strcmp(uniqueTable{1,1},uniqueTable{1,2}))
            % if self-reference start noRepsTable with second entry
             noRepsTable= uniqueTable(2,:);
             noRepsTable.Properties.VariableNames = {'Column1','Column2'};
             
             repetitions={};
             selfReferences={};
             start = 3;
        else

             noRepsTable= uniqueTable(1,:);
             noRepsTable.Properties.VariableNames = {'Column1','Column2'};
             
             repetitions={};
             selfReferences={};
             start = 2;
        end
        
     for n=start:height(uniqueTable)

            node1=uniqueTable{n,1};
            node2=uniqueTable{n,2};
            combi2= cell2table([node2,node1],'VariableNames',{'Column1','Column2'});
            
            % check if there is a self-reference and don't add it
            if strcmp(node1,node2)
                selfReferences=[selfReferences;[node1,node2]];
            
            % check if node is already in edgetable (should not be the case
            % if unique worked correctly)                    
            elseif sum(ismember(noRepsTable,uniqueTable(n,:),'rows')) == 0
                
                % check if other combination of node is in edgetable
                % if it is not as well, add first combination of node to edgetable 
                % else, add it to repetition list
               
                if sum(ismember(noRepsTable,combi2,'rows')) == 0          
                   noRepsTable=[noRepsTable;uniqueTable(n,:)]; 
                   
                else    
                    repetitions=[repetitions;uniqueTable(n,:)];
                    
                end
            else
                disp('something went wrong with unique');
            end
        
               
            
     end
    
      
        % create edgetable in merging column 1 and 2 into one variable EndNodes
        EdgeTable= mergevars(noRepsTable,{'Column1','Column2'},'NewVariableName','EndNodes');
                
  %% create graph
        
        
        graphyNoData = graph(EdgeTable,NodeTable);
        
        
        
%% remove node noData and newSession from graph

    
        graphy = rmnode(graphyNoData, 'noData');
        graphy = rmnode(graphy, 'newSession');
        
%% save graph
        save([savepath num2str(currentPart) '_Graph_V3.mat'],'graphy');
        
    else
        disp('something went really wrong with participant list');
    end

end


disp(strcat(num2str(Number), ' Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

 csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
 disp('saved missing participant file list');

disp('done');