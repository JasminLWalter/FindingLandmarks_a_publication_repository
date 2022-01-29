%% ------------------------- drawGraphMap_V3.m ----------------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description: 
% Creates a visualization of the graph objects on top of the map of
% Seahaven for each participant

% Input: 
% Graph_V3.mat           = the gaze graph object for every participant
% Map_Houses_SW2.png     = image of the map of Seahaven in black and white
% CoordinateListNew.txt  = csv list of the house names and x,y coordinates
%                          corresponding to the map of Seahaven

% Output: 
% graphVisualizationSeahaven.png = image of the graph visualization on
%                                    top of the map for each participant
% Missing_Participant_Files.mat    = contains all participant numbers where the
%                                    data file could not be loaded

clear all;

%% adjust the following variables: 
% savepath, imagepath, clistpath, current folder and participant list!-----

savepath = '...\analysis\graphs\visualizations\';
imagepath = '...\additional_files\'; % path to the map image location
clistpath = '...\additional_files\'; % path to the coordinate list location

cd '...\preprocessing\graphs\';

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};
%--------------------------------------------------------------------------


Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;

% load map

map = imread (strcat(imagepath,'\Map_Houses_SW2.png'));

% load house list with coordinates

listname = strcat(clistpath,'CoordinateListNew.txt');
coordinateList = readtable(listname,'delimiter',{':',';'},'Format','%s%f%f','ReadVariableNames',false);
coordinateList.Properties.VariableNames = {'House','X','Y'};





for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat(num2str(currentPart),'_Graph_V3.mat');
 
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
        alpha(0.2)
        hold on;
        
%         % to plot all houses on map use this code
%         plotty = scatter(coordinateList.X,coordinateList.Y,60,'filled','b');
        
        % mark node houses
        node = ismember(coordinateList.House,nodeTable.Name);
        x = coordinateList{node,2};
        y = coordinateList{node,3};


        plotty = scatter(x,y,60,'filled','b');
        title(strcat('Visualization of graph - projection on map - participant:',' ',num2str(currentPart)));
    
%% add edges into map-------------------------------------------------------
        
        for ee = 1:length(edgeCell)
            [Xhouse,Xindex] = ismember(edgeCell(ee,1),coordinateList.House);
            
            [Yhouse,Yindex] = ismember(edgeCell(ee,2),coordinateList.House);
            
            x1 = (coordinateList{Xindex,2});
            y1 = coordinateList{Xindex,3};
            
            x2 = coordinateList{Yindex,2};
            y2 = coordinateList{Yindex,3};
            
            line([x1,x2],[y1,y2],'Color','k');
                
            
       end
%---------comment code until here to only show nodes without edges---------
        
      saveas(gcf,strcat(savepath,num2str(currentPart),'_graphVisualizationSeahaven.png'),'png');
  
    
    else
        disp('something went really wrong with participant list');
    end

end
disp(strcat(num2str(Number), ' Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

disp('done');