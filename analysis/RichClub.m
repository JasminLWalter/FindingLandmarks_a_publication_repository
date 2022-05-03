%% ----------------------- Rich Club Coefficient --------------------------

% -------------------- written by Lucas Essmann - 2020 --------------------
% ---------------------- lessmann@uni-osnabrueck.de -----------------------

% Requirements:
% undirected, unweighted graphs with Edges and Nodes Table 
% The Edges Table needs to contain an EndNodes column

% The rich club coefficient is calculated with the following formula:
% RC(k) = 2E>k / N>k(N>k -1) 
% with k = Node Degree, 
% E>k = the number of edges between the nodes of
% degree larger than or equal to k,
% and N>k = the number of nodes with degree larger than or equal to k
% 
% But since the RichClubCoefficient is an abstract measure, the script
% creates a random graph based on the degree distribution of the original
% graph and calculates the RC of this random graph. Afterwards, it
% divides the RealCoefficient by the RandomCoefficient. Therefore, a value
% above 1 would indicate that high node degree nodes are connected to other
% high node degree nodes above chance level 

% Input:
% Graph_V3.mat           = the gaze graph object for every participant

% Map_Houses_New.png     = image of the map of Seahaven in black and white

% CoordinateListNew.txt  = csv list of the house names and x,y coordinates
%                          corresponding to the map of Seahaven

% Output:
% Figure 1 = All houses displayed on the map both color coded and size coded 
%            according to their frequency of being part of the rich club 
%            across participants (Fig 8b in paper)

% Figure 2/ MeanRichClub.png = The development of the rich club coefficient 
%                              with increasing node degree. The dot-lines 
%                              are the rich club coefficients of individual 
%                              participants, while the green line is the 
%                              mean across all participants (Fig 8a in paper)


% RichClub_AllSubs.mat = overview of all rich club values as a function of 
%                        the threshold node degree for each participant.
%                        Note: that the columns correspond to the selection
%                        of the houses included in the rich club based on the
%                        node degree - so column 2 corresponds to the first 
%                        threshold 1 = all nodes of a degree 1 or larger are 
%                        considered. Consequently, column 3 corresponds to
%                        the threshold: all nodes of degree 2 and larger
%                        etc.

% Mean_RichClub.mat = overview of the mean rich club values as a function
%                     of the threshold node degree averaged over all
%                     participants. Here column 1 corresponds to the
%                     threshold of all nodes of a degree of 1 and larger
%                     and column 2 corresponds to the threshold of all
%                     nodes of a degree of 2 and larger etc.

% List_RichClub_Frequency_ofallHouses.mat = overview of all houses and the
%                                           frequency of the houses
%                                           appearing in a rich club across
%                                           participants



clear all;

%% ------------------- adjust the following variables: -------------------------------

plotting_wanted = true; % if you want to plot, set to true
saving_wanted = true; % if you want to save, set to true

path = what;
path = path.path;

% cd into graph folder location
cd 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\preprocessing\graphs\';

savepath = 'E:\NBP\SeahavenEyeTrackingData\90minVR\Version03\analysis\RichClub\';
imagepath = 'D:\Github\FindingLandmarks_analyzingEyeTrackingDataInVRusingGraphTheory\additional_files\'; % path to the map image location
clistpath = 'D:\Github\FindingLandmarks_analyzingEyeTrackingDataInVRusingGraphTheory\additional_files\'; % path to the coordinate list location

%% -------------------------- Initialisation ------------------------------

 
% load house list with coordinates

listname = strcat(clistpath,'CoordinateListNew.txt');
coordinateList = readtable(listname,'delimiter',{':',';'},'Format','%s%f%f','ReadVariableNames',false);
coordinateList.Properties.VariableNames = {'House','X','Y'};


%graphfolder
PartList = dir();
PartList = struct2cell(PartList);
%reduce the folder to the graphs only
PartList = PartList(1,3:end);
% amount of graphs
totalgraphs = length(PartList);

%Rich Club Table
RichT = zeros(20,36);
NodeCountAll = zeros(213,1);

%% ----------------------------Main Part-----------------------------------

for part = 1:20%totalgraphs
   
  % load graph
    graphy = load(string(PartList(part)));
    graphy = graphy.graphy;
    currentPart = PartList{part}(1:2);
      % Calculate the Adjacency Matrix 
        A = full(adjacency(graphy));
      % the NodeDegree
        ND = degree(graphy);
    
%% ------------------creating the random graph-----------------------------

% Firstly calculate the distribution (assume normal) of the degree data by
ND_Dist = fitdist(ND,'normal');
mu = ND_Dist.mu;
sigma = ND_Dist.sigma;
% Then create the probability distribution function according to the 
% Degrees

% Afterwards, create 1000 random graphs with the same amount of nodes and 
% edges and compare the Node Degree Distributions. 
n = height(graphy.Nodes);
E = numedges(graphy);
count = 1000;
Kolmo = [];

for random = 1:count
    adj = [];
    idx = [];
    matrix = [];
    Deg = [];
    h = [];


    adj = spalloc(n, n, E);
    idx = randperm(n * n, E+n);
    idx(ismember(idx, 1:n+1:n*n)) = [];
    idx = idx(1:E);
    adj(idx) = 1;
  % With at least one 1 per column
    adj = min( adj + adj.', 1);
    matrix = full(adj);
    Deg = sum(matrix)';

  % Create the random graph based on the random adjacency matrix
    rgraphy = graph(adj);

  % Now calculate the degree distribution
    Random_Dist = fitdist(Deg,'normal');
    mu_rnd = Random_Dist.mu;
    sigma_rnd = Random_Dist.sigma;

   % Comparing the two distributions. Here, I used the 
   % Kolmogornov-Smirnov-test for continuous datasets with H0 = the two 
   % datasets follow the same distribution. 
   % With h=1 the test rejects the H0, however, we are interested in the 
   % same distribution. This can never be proven though. It only shows that
   % the two sets are consistent with a single distribution.

    [h,p,stat] = kstest2(ND,Deg,'Alpha',0.01);
    Kolmo(random,1) = h;
    Kolmo(random,2) = p;
    Kolmo(random,3) = stat;

    graphs{random,:} = rgraphy;

end

graphs = graphs(~cellfun('isempty',graphs));

[Sorted, index] = sort(Kolmo(:,1),'ascend');
Sorted(:,2) = index;

Top10R = Sorted(1:10,2);


%% ---------------------RichClub Calculation-------------------------------

for Rgraphs = 1:10
          
    randomgraphy = graphs{Top10R(Rgraphs),:};
    
    RandomND = degree(randomgraphy);
    
    x = 1;
    y = 35;
    
    currentRich = [];
    for k = x:y
        
        
      % the number of nodes with higher or equal node degree than k
        ND_largerK_bool = ND>=k;
        ND_largerK = ND(ND_largerK_bool);
        RandomND_largerK_bool = RandomND>=k;
        RandomND_largerK = RandomND(RandomND_largerK_bool);
        
      % The number of nodes with higher node degree:
        N_largerK = length(ND_largerK);
        RandomN_largerK = length(RandomND_largerK);
        
      % the number of edges between those nodes
      % Firstly find out which nodes are larger
        [ND_largerK_sort, index] = sort(ND_largerK_bool,'descend');
        [RandomND_largerK_sort, random_index] = ...
            sort(RandomND_largerK_bool,'descend');
        
      % Then create a subgraph consisting of those nodes
        graphy_largerK = subgraph(graphy,index(1:length(ND_largerK)));
        randomgraphy_largerK =...
           subgraph(randomgraphy,random_index(1:length(RandomND_largerK)));
        
      % Number of edges
        E_largerK = numedges(graphy_largerK);
        E_RandomlargerK = numedges(randomgraphy_largerK);
        
      % Insert everything into the formula:
        RealRichClubCoeff = ...
            (2*E_largerK) / (N_largerK*(N_largerK-1));
        RandomRichClubCoeff = ...
            (2*E_RandomlargerK) / (RandomN_largerK*(RandomN_largerK-1));
        RichClubCoeff = RealRichClubCoeff / RandomRichClubCoeff;
        
        currentRich(1,k) = RichClubCoeff;
        

    end
    RC_Sub(Rgraphs,:) = currentRich;
    
end
    RC_Sub(arrayfun(@isinf,RC_Sub)) = NaN;
    
       % Fill the table of subjects
         RichT(part,1) = str2num(currentPart);
         RichT(part,2:end) = nanmean(RC_Sub);
         
         
       % Are always the same houses in the repective rich club? 
         DegreeOver10 = ND>=13; 
         NodeCountSub = ...
             ismember(coordinateList.House,graphy.Nodes.Name(DegreeOver10));
         NodeCountSub = double(NodeCountSub);
         
         NodeCountAll = NodeCountAll + NodeCountSub;
end

% Take the mean over all subjects
MeanRichClub = nanmean(RichT(:,2:end));
    
%% --------------------------- Plotting -----------------------------------

if plotting_wanted == true
  % Draw Graph with Rich Club Information on Map
  % display map
    map = imread(strcat(imagepath,'Map_Houses_New.png'));
    figgy = figure();%('Position', get(0, 'Screensize'));
    F = getframe(figgy);
    imshow(map);
    alpha(0.1)
    hold on;

   % With Degree Centrality Analysis:   
     x = coordinateList.X;
     y = coordinateList.Y;

     plotty = scatter(x,y,(NodeCountAll+1)*15,NodeCountAll,'filled');
     colormap(parula);
     colorbar

     hold off;

    figure('Position',[0,0,900,900]);
    plot(RichT(:,2:14)','LineStyle',':','Linewidth',1);
    hold on;
    plot(MeanRichClub(1,1:13),'LineWidth',4);
    xlabel('Node Degree')
    ylabel('Mean Rich Club (Real/Random)');
    xlim([1,13]);
    xticks([1:2:13]);
    ylim([0.7,2.5]);
    set(gca,'FontName','Helvetica','FontSize',40,'FontWeight','bold')
    pbaspect([1 1 1]);

    if saving_wanted == true
        saveas(gcf,strcat(savepath,'MeanRichClub.png'),'png');
    end
end 

%% ---------------------------- Saving ------------------------------------

if saving_wanted == true
    save([savepath 'RichClub_AllSubs.mat'],'RichT');
    save([savepath 'Mean_RichClub.mat'],'MeanRichClub');
    rc_countList = table;
    rc_countList.Houses = coordinateList.House;
    rc_countList.Frequency = NodeCountAll;
    save([savepath 'List_RichClub_Frequency_ofallHouses.mat'], 'rc_countList');
end

% clearvars '-except' ...
%     RichT ...
%     MeanRichClub;

disp('Done');
