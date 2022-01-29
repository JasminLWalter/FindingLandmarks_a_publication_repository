%% ------------------ triangulation_analysis_V3----------------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description:
% Script analyses how many gaze-graph-defined landmarks were viewed from 
% each location participants visited in the city. In addition, it analyses
% how much of the total experiment time participants spend in these areas 
% where the theoretical basis for triangulation would be given. 
% The analysis is performed with a spatial resolution of 4x4m and an 
% additional smoothing with a 3x3 unity kernel. 


% Input: 
% gazes_allParticipants.mat        = data file containing all gazes from all
%                                    participants
%                                    - created when running script...

% interpolData_allParticipants.mat = data file containing all interpolated
%                                    data from all participants
%                                    - created when running script

% Overview_NodeDegree.mat  =  table consisting of all node degree values
%                             for all participants (alternatively the list
%                             of the rich club count for all houses)
%                          
% Map_Houses_New.png       = image of the map of Seahaven 
% CoordinateListNew.txt    = csv list of the house names and x,y coordinates
%                            corresponding to the map of Seahaven


% Output: 
% Figure 1: visibility of top 10 houses - rich club and node degree
% = map plot color coded for all top 10 houses

% Figure 2: Visibility of top 10 houses - rich club & node degree'
% = like figure 1, but here the map is only color coded to differentiate
% areas where 0 top 10 houses, 1 top 10 house, and 2 or more top 10 houses
% were viewed (Fig. 9 of the paper)

% Figure 3: grid size_vibility plots.png
% = visualization of the 4x4 grid dividing the city

% Figure 20: Percentage of possibility to triangulate in walked area
% = pie plot of the percentages of the different city areas participants 
% were located in

% Figure 21: Percentage of times triangulation was possible
% = pie plot of the percentages of experiment time participants spend in
% triangulation areas (same visualization as Figure 20, but different data)

% table_percentage_triangulation.mat
% = table listing the percentages of the areas in the city where participants
% viewed 0, 1, 2 or more houses

% table_times_triangulation_possible.mat
% = table listing the percentage of experiment time participants spend in
% areas where 0, 1, 2 or more houses where visible

clear all;

%% adjust the following variables: 
% savepath, imagepath, clistpath, overviewNDpath and current folder-----------------------

savepath= '...\analysis\triangulation\';

imagepath = '...\additional_files\'; % path to the map image location
clistpath = '...\additional_files\'; % path to the coordinate list location

%  path to the overviewNodeDegree file created when running script nodeDegree_createOverview_V3
overviewNDpath = '...\analysis\graphs\node_degree\';

% location of file containing all gaze data and all interpolated of all participants
cd '...\analysis\all_participants\'

%------------------------------------------------------------------------

disp('load gazes data')
% load gazes data

gazes_allParts = load('gazes_allParticipants.mat');
gazes_allParts = gazes_allParts.gazes_allParticipants;

disp('data loaded')

% load map

map = imread (strcat(imagepath,'Map_Houses_SW2.png'));
% load house list with coordinates

listname = strcat(clistpath,'CoordinateListNew.txt');
coordinateList = readtable(listname,'delimiter',{':',';'},'Format','%s%f%f','ReadVariableNames',false);
coordinateList.Properties.VariableNames = {'House','X','Y'};


%%  transformation of position coordinates so they match the map image
%   consists of 2 factors (mulitply and additive factor)
xT = 6.05;
zT = 6.1;
xA = -1100;
zA = -3290;


%% load the data of the top 10 gaze graph defined houses
% using top 10 mean node degree houses
% alternatively, it is possible to use the top 10 houses of the mean rich
% club count (created when running the rich club script)
overviewNodeDegree = load(strcat(overviewNDpath,'Overview_NodeDegree.mat'));

overviewNodeDegree = overviewNodeDegree.overviewNodeDegree;

meanNDtable = table;
meanNDtable.houseList = overviewNodeDegree.houseList;
meanNDtable.meanND = mean(overviewNodeDegree{:,2:end},2);

meanNDtableS = sortrows(meanNDtable,2,'descend');

housesTop10 = meanNDtableS.houseList(1:10);

% using the rich club list here named RC_HouseList.csv
% RCHouseList = readtable("...\RC_HouseList.csv");
% 
% sortedRCL = sortrows(RCHouseList,'RCCount','ascend');
% 
% housesTop10 = sortedRCL{end-9:end,1};
% 

%% identify the locations of the top 10 houses
houseIndex10 = ismember({gazes_allParts.Collider}, housesTop10);
positions10 = table;
positions10.X = [gazes_allParts(houseIndex10).PosX]'*xT+xA;
positions10.Z = [gazes_allParts(houseIndex10).PosZ]'*zT+zA;


%% define grid and do hist count
[rows, columns, numberOfColorChannels] = size(map);

% % ca 5m x 5m
% edgesRows = linspace(1,rows,100);
% edgesCol = linspace(1,columns,90);

% ca 4m x 4m
edgesRows = linspace(1,rows,125);
edgesCol = linspace(1,columns,112);

[countMatrix,colEdges,rowEdges] = histcounts2(positions10.Z, positions10.X, edgesCol,edgesRows);

%% which are was visited by participants in the first place?
positionsAll = table;
positionsAll.X = [gazes_allParts.PosX]'*xT+xA;
positionsAll.Z = [gazes_allParts.PosZ]'*zT+zA;


[countMatrixAll,colEdgesAll,rowEdgesAll] = histcounts2(positionsAll.Z, positionsAll.X, edgesCol,edgesRows);

% % apply kernal smoothing / convolution
% kernel  = [1,1,1;1,1,1;1,1,1];
% convCountAll = countMatrixAll;
% convCountAll = conv2(convCountAll,kernel,'same');
convCountAll = countMatrixAll; % comment line if kernel smoothing is applied)

% get alpha data so that all areas that were not visited in the first place
% can be set to 0 transparency in the plot
alphaD = convCountAll';
zeros = alphaD(:,:)==0;
alphaD(~zeros) = 0.6;

%% now the real triangulation plot
% first get logical array of grid and how many top 10 houses were seen at
% that location
fullCount = struct;

for index = 1:length(housesTop10)
        
    houseName = housesTop10{index};
    houseIndex = strcmp({gazes_allParts.Collider}, houseName);
    positions = table;
    positions.X = [gazes_allParts(houseIndex).PosX]'*xT+xA;
    positions.Z = [gazes_allParts(houseIndex).PosZ]'*zT+zA;
    
    [countMatrix,colEdges,rowEdges] = histcounts2(positions.Z, positions.X, edgesCol,edgesRows);
    fullCount(index).columnEdges = colEdges;
    fullCount(index).rowEdges = rowEdges;
    fullCount(index).countMatrix = countMatrix;
 
end

% apply kernal smoothing / convolution
kernel  = [1,1,1;1,1,1;1,1,1];
convCount = fullCount;


for index11 = 1:length(fullCount)

    convCount(index11).countMatrix = conv2(convCount(index11).countMatrix,kernel,'same');
end

logicalCount = convCount;

for index2 = 1:length(fullCount)

    logicalCount(index2).countMatrix = convCount(index2).countMatrix > 0;
 
end

logicalCell = struct2cell(logicalCount);

logical3D = [];

for index3 = 1:length(fullCount)
    logical3D(:,:,index3) = logicalCell{3,1,index3};
    
end


sumAll = sum(logical3D,3);

% plot the summed matrix - use alpha for alphadata to only colour space
% that was actually visited
colours = [ 0.24,0.15,0.66;0.01,0.72,0.80;0.96,0.73,0.23];

figure(1)
imshow(map);
alpha(0.1)
hold on
plotty1 = imagesc(colEdges,rowEdges,sumAll', 'AlphaData', alphaD);
colorbar
title('visibility of top 10 houses - rich club and node degree');
saveas(gcf, strcat(savepath, 'visibility of top 10 houses.png'));
hold off

%% final aspect - only display 0,1,2 or more

more3 = sumAll >= 2;

sumAll3cut = sumAll;
sumAll3cut(more3) = 2;

colormap3 = [
    0.24,0.15,0.66
    0.18,0.77,0.64
    0.97,0.85,0.17];

figure(2)
imshow(map);
alpha(0.2)
hold on
plotty2 = imagesc(colEdges,rowEdges,sumAll3cut', 'AlphaData', alphaD);
colormap(colormap3);
colorbar('Ticks',[0.35,1,1.65], 'TickLabels',{'0 houses','1 house','2 or more houses'})
title('Visibility of top 10 houses - rich club & node degree');

saveas(gcf, strcat(savepath, 'visibility of top 10 houses - Triangulation.png'));
saveas(gcf, strcat(savepath, 'visibility of top 10 houses - Triangulation.fig'));

hold off

h1(:,1)= rowEdges';
h1(:,2) = 0;

h2(:,1)= rowEdges';
h2(:,1)= rowEdges';

% plot applied grid over map
figure(3)
imshow(map);
% xticks(colEdges)
% yticks(rowEdges)
% grid minor


% [rows, columns, numberOfColorChannels] = size(map);

stepSize = 30; % Whatever you want.
for row = 1 : length(rowEdges)
    line([1, 2700], [rowEdges(row), rowEdges(row)], 'Color', 'r', 'LineWidth', 0.1);
end
for col = 1 : length(colEdges)
    line([colEdges(col), colEdges(col)], [1, 3000], 'Color', 'r', 'LineWidth', 0.1);
end
saveas(gcf, strcat(savepath, 'grid size_vibility plots.png'));


%% percentage of triangulation area vs walked area

walkedGridAll = convCountAll ~= 0;
sumGridAll = sum(walkedGridAll,'all');

saw1 = sumAll3cut == 1;
saw2 = sumAll3cut == 2;

sumGrid1 = sum(saw1, 'all');
sumGrid2 = sum(saw2, 'all');

percTable = table;
percTable.percentage_0Houses = ((sumGridAll-(sumGrid1+sumGrid2))/sumGridAll)*100;
percTable.percentage_1House = (sumGrid1/sumGridAll)*100;
percTable.percentage_2Houses = (sumGrid2/sumGridAll)*100;
save([savepath,'table_percentage_triangulation.mat'],'percTable');


figure(20)
labelsData = {'0 houses','1 house','2 or more houses'};
figgy20 = pie([sumGridAll-sumGrid1-sumGrid2, sumGrid1, sumGrid2]);
legend(labelsData)
title('Percentage of possibility to triangulate in walked area');
saveas(gcf, strcat(savepath, 'piePlot_triangualationPercentage.png'));



%% how much of the experiment time did participants spend in areas where
% triangulation is possible?

% load data interpolated - here the analysis does not depend on the eye
% tracking data, therefore the data is used before the gaze separation.
% Note that the position data used here is not affected by the
% interpolation or the pre-preprocessing pipeline until the gaze - noise
% separation. Thus, since we are interested in the whole experiment time, 
% we want to use the position data before it gets affected by the gaze 
% separation. Here we use the interpolated data files, instead we could 
% also use data files earlier in the preprocessing pipeline, like 
% the condensedCollider files once all sessions have been combined.

interpol_allParts = load('interpolData_allParticipants.mat');
interpol_allParts = interpol_allParts.interpolData_allParticipants;

disp('interpolated data loaded')

positionsID = table;
positionsID.X = [interpol_allParts(:).PosX]'*xT+xA;
positionsID.Z = [interpol_allParts(:).PosZ]'*zT+zA;

[countMatrixID,colEdgesAll,rowEdgesAll] = histcounts2(positionsID.Z, positionsID.X, edgesCol,edgesRows);

logicSaw2 = sumAll3cut == 2;
logicSaw1 = sumAll3cut == 1;
logicSaw0 = sumAll3cut == 0;

timeTr2 = countMatrixID(logicSaw2);
timeTr1 = countMatrixID(logicSaw1);
timeTr0 = countMatrixID(logicSaw0);

% now sum the areas
sumTTri2 = sum(timeTr2);
sumTTri1 = sum(timeTr1);
sumTTri0 = sum(timeTr0);
sumAllInterpol = sum(countMatrixID, 'all');

percTableTimeTri = table;
percTableTimeTri.percentage_Time0Houses = (sumTTri0 /sumAllInterpol)*100;
percTableTimeTri.percentage_Time1House = (sumTTri1/sumAllInterpol)*100;
percTableTimeTri.percentage_Time2Houses = (sumTTri2/sumAllInterpol)*100;
save([savepath,'table_times_triangulation_possible.mat'],'percTableTimeTri');

figure(21)
labelsData = {'0 houses','1 house','2 or more houses'};
figgy20 = pie([sumTTri0, sumTTri1, sumTTri2]);
legend(labelsData)
title('Percentage of times triangulation was possible');
saveas(gcf, strcat(savepath, 'piePlot_TimesTriangualationPossible.png'));