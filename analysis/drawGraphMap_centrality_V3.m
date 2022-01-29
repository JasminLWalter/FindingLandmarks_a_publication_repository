%% ------------------- drawGraphMap_centrality_V3.m------------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description: 
% Creates a visualization of the graph on top of the map of Seahaven 
% while color coding the nodes according to their node degree value

% Input: 
% Graph_V3.mat           = the gaze graph object for every participant
% Map_Houses_New.png     = image of the map of Seahaven 
% CoordinateListNew.txt  = csv list of the house names and x,y coordinates
%                          corresponding to the map of Seahaven

% Output: 
% Graph_nodeDegree_visualizationMap.png = image of the graph visualization 
%                                         with nodes color coded according
%                                         to their node degree centrality
%                                         on top of the map for each participant
% Missing_Participant_Files.mat    = contains all participant numbers where the
%                                    data file could not be loaded


clear all;


%% adjust the following variables: 
% savepath, imagepath, clistpath, current folder and participant list!-----

savepath = '...\analysis\graphs\node_degree\visualization\';
imagepath = '...\additional_files\'; % path to the map image location
clistpath = '...\additional_files\'; % path to the coordinate list location

cd '...\preprocessing\graphs\';

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {35};%21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

% can be also adjusted to change the color map for the node degree
% visualization
nodecolor = parula; % colormap parula

%--------------------------------------------------------------------------

Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;


% load map

map = imread (strcat(imagepath,'Map_Houses_New.png'));

% load house list with coordinates

listname = strcat(clistpath,'CoordinateListNew.txt');
coordinateList = readtable(listname,'delimiter',{':',';'},'Format','%s%f%f','ReadVariableNames',false);
coordinateList.Properties.VariableNames = {'House','X','Y'};


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

        % load graph      
        graphy = load(file);
        graphy= graphy.graphy;
        
        nodeTable = graphy.Nodes;
        edgeTable = graphy.Edges;
        edgeCell = edgeTable.EndNodes;
                
        % display map
        figure(1)
        imshow(map);
        alpha(0.1)
        hold on;
            
        title(strcat('Graph & degree centrality values - participant: ',num2str(currentPart)));
    
        % add edges into map-----------------------------------------------
        
        for ee = 1:length(edgeCell)
            [Xhouse,Xindex] = ismember(edgeCell(ee,1),coordinateList.House);
            
            [Yhouse,Yindex] = ismember(edgeCell(ee,2),coordinateList.House);
            
            x1 = (coordinateList{Xindex,2});
            y1 = coordinateList{Xindex,3};
            
            x2 = coordinateList{Yindex,2};
            y2 = coordinateList{Yindex,3};
            
            line([x1,x2],[y1,y2],'Color','k','LineWidth',0.02);%,'LineStyle',':');             
            
        end
 %---------comment code until here to only show nodes without edges--------
  %% visualize nodes color coded according to the node degree values
  
        node = ismember(coordinateList.House,nodeTable.Name);
        x = coordinateList{node,2};
        y = coordinateList{node,3};
        
        % calculate node degree centrality values here
        % this markerND variable will manage the color coding of the nodes
        % it is possible to modify the script here, to visualize other
        % graph theoretical analysis where color coding of the nodes is
        % helpful for the visualization. For example, we like the map
        % visualization of the Rich Club analysis (Fig. 8b in the paper)
        
         markerND = centrality(graphy,'degree')';
         
         % plot visualization
         plotty = scatter(x,y,40,markerND,'filled');
         colormap(nodecolor);
         colorbar
        
        
        saveas(gcf,strcat(savepath,num2str(currentPart),'_Graph_nodeDegree_visualizationMap.png'),'png');
  
    
    else
        disp('something went really wrong with participant list');
    end

end
disp(strcat(num2str(Number), ' Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

disp('done');