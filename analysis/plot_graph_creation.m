%% ------------------ plot_graph_creation-------------------------------------
% script written by Jasmin Walter


clear all;


savepath= 'E:\NBP\SeahavenEyeTrackingData\90minVR\analysis\graphs\graph_plots\';


cd 'E:\NBP\SeahavenEyeTrackingData\90minVR\duringProcessOfCleaning\gazes_vs_noise\'

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {35};%21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

% good visuals - 31


Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;

scope = 40;

% load map

map = imread ('C:\Users\Jaliminchen\Documents\GitHub\NBP-VR-Eyetracking\EyeTracking_VR_Seahaven\additional_files\Map_Houses_New.png');



% load house list with coordinates

listname = 'C:\Users\Jaliminchen\Documents\GitHub\NBP-VR-Eyetracking\EyeTracking_VR_Seahaven\additional_files\CoordinateListNew.txt';
coordinateList = readtable(listname,'delimiter',{':',';'},'Format','%s%f%f','ReadVariableNames',false);
coordinateList.Properties.VariableNames = {'House','X','Y'};

% coordinateList.X = coordinateList.X.*0.215555;  %factor of newmap vs oldmap resolution to fit the points
% coordinateList.Y = coordinateList.Y.*0.215666;


for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    
    file = strcat('gazes_data_',num2str(currentPart),'.mat');
 
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
        
        currentPartName= strcat('Participant_',num2str(currentPart));
        
%         % create houseList
%         uniqueHouses= unique(gazedObjects.House);
%         houseList = uniqueHouses;
        lastsum = 0;
        housesYaxis = 0;
        rowsAHouses = 0;
        
        xlist = [];
        ylist = [];
        appearedHouses = table;
        
        
      %% timeline and colors  
        
        color = colormap(jet);%(scope*4)
        sz = size(color); 
        scolor = sz(1,1) /11;
        %colR = color(randperm(size(color, 1)), :);
        %col = colR(1:2:end,:);
        col = color(1:scolor:end,:);
        
        xNan = [];
        yNan = [];
        

        
%         [uniqueHouses, iGazed, iunique] = unique(gazedObjects(:, 1), 'stable');
%         ypatches = max(ylabels) + 1 - [ylabels, ylabels, ylabels-1, ylabels-1]'; 
        colorindex = 1;
        for index = 1: scope
            
            % x values
            newsum = sum(gazedObjects.Samples(1:index));
            x = [lastsum newsum newsum lastsum];
            xlist = [xlist;x];
            
            lastsum = newsum;
            
            % y values
            
            % what is the data point? noData? NH/Sky? House?
            
            noData = strcmp(gazedObjects{index,1},'noData');
            other = strcmp(gazedObjects{index,1},'sky')||strcmp(gazedObjects{index,1},'NH');
            house = not(noData | other);
            
%             hAH = height(appearedHouses);
%             if hAH ==0
%                 if noData
%                     rowsAHouses = 1;
%                     
%                 elseif house
%                     housesYaxis = 1;
%                     rowsAHouses = 1;
%                 
%                 end
%                 disp('first loop')
%             else
%                 disp('2nd loop')
                if noData
                    
                    rowsAHouses = rowsAHouses +1;
                    
                    noValue = 12;
                    y = [0 0 noValue noValue];
                    ylist = [ylist;y];
                    currentColour = [0 0 0];
%                     xNan = [xNan; x];
%                     yNan = [yNan; y];
                    appearedHouses.Name(rowsAHouses) = gazedObjects{index,1};


                    % if it is sky or NH
                 elseif other
                    noValue = 12;
                    y = [0 0 noValue noValue];
                    ylist = [ylist;y];
                    if strcmp(gazedObjects{index,1},'sky')
                        currentColour = [0 1 1];
                    else
                        currentColour = [0.85 0.85 0.85];

                    end
                        % if it is the first house
    %             elseif index ==1
    %                 allHouses = 1;
    %                 appearedHouses.Name(index) = gazedObjects{index,1};
    %                 appearedHouses.Number(index) = allHouses;
    %                 appearedHouses.Color(index) = {col(index,:)};
    %                 % appearedHouses.Color(index) = {rand(1,3)};
    %                
    %                 currentColour = appearedHouses.Color{index};
    %                 
    %                 y = [allHouses-1 allHouses-1 allHouses allHouses];
    %                 ylist = [ylist;y];
    
    

                % else if object is a house    
                    elseif house 
                    
                        % if it is the first item in the appeaerdHouses List
                        if height(appearedHouses) == 0
                            % if it is the first item, just add house -
                        % otherweise check whether it is new or already
                        % exists
                       
                            housesYaxis = housesYaxis+1;
                            rowsAHouses = rowsAHouses +1;

                            appearedHouses.Name(rowsAHouses) = gazedObjects{index,1};
                            appearedHouses.Number(rowsAHouses) = housesYaxis;
                            appearedHouses.Color(rowsAHouses) =  {col(colorindex,:)};
                            
                            colorindex = colorindex +1;

                            currentColour = appearedHouses.Color{rowsAHouses};

                            y = [housesYaxis-1 housesYaxis-1 housesYaxis housesYaxis];
                            ylist = [ylist;y];

                        
                        
                        else
                            % if the house was already seen
                            if any(strcmp(gazedObjects{index,1},appearedHouses.Name))

                                position = strcmp(gazedObjects{index,1},appearedHouses.Name);
                                object = appearedHouses.Name(position);
                                currentNumber = appearedHouses.Number(position);
                                currentColour = appearedHouses.Color{position};

                                y = [currentNumber-1 currentNumber-1 currentNumber currentNumber];
                                ylist = [ylist;y];
                            else
                                
                                housesYaxis = housesYaxis+1;
                                rowsAHouses = rowsAHouses +1;
                        
                                appearedHouses.Name(rowsAHouses) = gazedObjects{index,1};
                                appearedHouses.Number(rowsAHouses) = housesYaxis;
                                appearedHouses.Color(rowsAHouses) =  {col(colorindex,:)};
                                
                                colorindex = colorindex+1;

                                currentColour = appearedHouses.Color{rowsAHouses};

                                y = [housesYaxis-1 housesYaxis-1 housesYaxis housesYaxis];
                                ylist = [ylist;y];
                        
                            end

                        end
                    
                    else
                        disp('unknown condition error in y value loop')
                    end
            
            figure(1)
            patchy = patch(x,y,currentColour);

        end
        
        % add house names
        xlables= zeros(1,housesYaxis);
        xlables(1:end)= lastsum +30;
        
        ylables = linspace(0.5, housesYaxis-0.5,housesYaxis);
        
        houselables = appearedHouses.Name;
        noData2 = strcmp('noData',houselables);
        houselables(noData2) = []; 
        
        text(xlables,ylables,houselables,'Interpreter','none')
        ax = gca;
        ax.YTick = 0:1:housesYaxis;
        
        xlabel('hit points')
        ylabel('houses')
    
        
        title({strcat('time line of gazed objects - first 30 sec - participant: ',num2str(currentPart)),''});
        
        
        
        figure(2)
        
        patchy2 = patch(xlist',ylist','blue');
       
        
        

      %% create map accordingly  
            figure(3)

            imshow(map);
            alpha(0.1)
            hold on;
           
           
        %% draw edges
        
        edgerange = gazedObjects(1:scope,:);
        sky = strcmp('sky',gazedObjects{1:scope,1});
        nh = strcmp('NH',gazedObjects{1:scope,1});
        exclude= sky | nh;
        edgerange(exclude,:) = [];
        
        %%
               % create edge table
        
        fullEdgeT= cell2table(edgerange.House,'VariableNames',{'Column1'});
        
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
        
        uniqueTable= unique(fullEdgeT,'stable');

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
        %%
        
        nredge = 0;

        
           for index3 = 1: height(noRepsTable)
               object1 = noRepsTable{index3,1};
               object2 = noRepsTable{index3,2};
               
               %if the current houses is not a noData point
               if not(strcmp('noData',object1))
                   
                   
                   % and if the last house was not a noData point draw edge
                   if not(strcmp('noData',object2))

                        nredge = nredge +1;
                        
                        foundO1 = strcmp(object1, coordinateList{:,1});

                        x1 = coordinateList{foundO1,2};
                        y1 = coordinateList{foundO1,3};
                        
                       foundO2 = strcmp(object2, coordinateList{:,1});

                        x2 = coordinateList{foundO2,2};
                        y2 = coordinateList{foundO2,3};

                       line([x1,x2],[y1,y2],'Color','k','LineWidth',2);
                       
                       p2 = [x2, y2];
                       p1 = [x1, y1];
                       
                       spot = (p2(:) + p1(:)).'/2;
                       
                       text((spot(1)+1), (spot(2)+1),num2str(nredge),'FontSize',20, 'FontWeight','bold')
                       
                   end

               end
           end
        %y = [index-1 index index index-1];
        
        %% draw nodes
        
         for index2 =1:height(appearedHouses)

                object = appearedHouses{index2,1};

                % draw node if current house is not a noData object
                if not(strcmp(object, 'noData'))
                    
                    
                    found = strcmp(object, coordinateList{:,1});

                    xC = coordinateList{found,2};
                    yC = coordinateList{found,3};
                    plotty = scatter(xC,yC,400,cell2mat(appearedHouses{index2,3}),'filled');
                    title(strcat('time line of graph creation - first 30 sec - participant: ',num2str(currentPart)));
                    hold on
                    
                    
                end

                %pause               

            end
        
        
        
        
        
    else
        disp('something went really wrong with participant list');
    end

end


disp(strcat(num2str(Number), ' Participants analysed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

%csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');

disp('done');