%% ------------------ nodeDegree_createOverview_V3.m-----------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description: 
% Creates the node degree overview file used in other analysis scripts. It
% reads in the graphs from all participants, calculates the node degree
% centrality values for every house and saves it in the overview

% Input: 
% Graph_V3.mat = the gaze graph object for every participant
% CoordinateListNew.txt = csv list of the house names and x,y coordinates 
%                         corresponding to the map of Seahaven


% Output: 
% Overview_NodeDegree.mat = table consisting of all node degree values for
%                           all participants
% Missing_Participant_Files.mat =contains all participant numbers where
%                                the data file could not be loaded



clear all;

%% adjust the following variables: 
% savepath, clistpath, current folder and participant list!----------------


savepath = '...\analysis\graphs\node_degree\';
clistpath = '...\additional_files\'; % path to the coordinate list location

cd '...\preprocessing\graphs\';
%--------------------------------------------------------------------------

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};


Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;

%load coordinate list

listname = strcat(clistpath,'...\additional_files\CoordinateListNew.txt');
coordinateList = readtable(listname,'delimiter',{':',';'},'Format','%s%f%f','ReadVariableNames',false);
coordinateList.Properties.VariableNames = {'House','X','Y'};

overviewNodeDegree = cell2table(coordinateList.House);



for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat(num2str(currentPart),'_Graph.mat');
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2

        %load graph
        graphy = load(file);
        graphy= graphy.graphy;
        
        % save degree nodes, edge nodes
        
        % create table with houses and node degree info
        degreeG= degree(graphy);
        
        nodeDegreeTable = graphy.Nodes;
        nodeDegreeTable.Edges = degreeG;
        
        % update overview NodeDegree
        
        currentPartName= strcat('Part_',num2str(currentPart));
        extraVar= array2table(zeros(height(overviewNodeDegree),1),'VariableNames',{currentPartName});

        
       for n= 1: height(nodeDegreeTable)
           changer = strcmp(overviewNodeDegree.houseList(:),nodeDegreeTable{n,1});
           
           extraVar(changer,1)= nodeDegreeTable(n,2);        
            
       end
        
        % concatinage extraVar and overview
        overviewNodeDegree= [overviewNodeDegree extraVar];
             
        
        
    else
        disp('something went really wrong with participant list');
    end

end


% save nodedegree overview
save([savepath 'Overview_NodeDegree.mat'],'overviewNodeDegree');


disp(strcat(num2str(Number), ' Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

disp('done');