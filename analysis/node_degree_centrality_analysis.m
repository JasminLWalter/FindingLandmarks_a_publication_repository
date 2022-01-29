%% ------------------- node_degree_centrality_analysis.m-------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description:
% Creates an image scale (pseudo 3D plot) color coding the node degree 
% centrality values for every house and every participant (Fig. 5c). Also 
% creates corresponding box plots with error bars: the individual mean node 
% degrees of all subjects (Fig. 5a) and the individual mean node degree of
% each house (Fig. 5e)

% Input: 
% Overview_NodeDegree.mat  =  table consisting of all node degree values
%                             for all participants
% Output: 
% nodeDegree_imageScale.png = pseudo 3D plot color coding the node degree 
%                             centrality values for every house and every 
%                             participant (Fig. 5c)
% nodeDegree_mean_std_allHouses.png = error bar plot of mean and std for 
%                                     all houses (Fig. 5e)
% nodeDegree_mean_std_allParticipants.png = error bar plot of mean and std
%                                           for each participant (Fig. 5b)


clear all;

%% adjust the following variables: savepath and current folder!-----------

savepath = '...\analysis\graphs\image_scale\';

cd '...\analysis\graphs\node_degree\'

%--------------------------------------------------------------------------

overviewDegree= load('Overview_NodeDegree.mat');

overviewDegree= overviewDegree.overviewNodeDegree;
%% calculate mean over houses and sort table according to ascending mean ND of each house

meanNDofHouses = mean(overviewDegree{:,2:end},2);

% sort overview based on mean value of each house (sort columns)

overviewDegree.meanOfHouses = meanNDofHouses;

sortedbyH = sortrows(overviewDegree,'meanOfHouses');

%% sort overview based on mean value of each participant and arrange columns accordingly (ascending)
meanNDofParticipants = mean(sortedbyH{:,2:end-1});

columnN = sortedbyH.Properties.VariableNames;

partT = [array2table(meanNDofParticipants'),cell2table(columnN(2:end-1)','VariableNames',{'names'})];
sortPT = sortrows(partT,'Var1','descend');

sParts = sortPT{:,2};

sortedbyParts = sortedbyH;
for index = 1:length(sParts)  
    position = index+1;
    sortedbyParts = movevars(sortedbyParts,sParts(index),'before',position);
    
end

columnN2 = sortedbyParts.Properties.VariableNames;
sortedbyHP = [sortedbyParts; table('meanOfPart','VariableNames',columnN2(1)), array2table(sortPT{:,1}','VariableNames',columnN2(2:end-1)),table(NaN,'VariableNames',columnN2(end))];


%% create image scale
transpose2plot= sortedbyHP{1:end-1,2:end-1}';

fig = figure(1);
imagescaly = imagesc(transpose2plot);
colorbar
title({'Image Scale Node Degree Centrality - all Participants','     '});
ax = gca;
ax.XTick = 0:10:213;
ax.TickDir = 'out';
ax.XMinorTick = 'on';
ax.XAxis.MinorTickValues = 1:1:213;
ax.XLabel.String = 'Houses';
ax.YLabel.String = 'Participants';

print(gcf,strcat(savepath,'nodeDegree_imageScale.png'),'-dpng','-r300'); 
savefig(gcf, strcat(savepath,'nodeDegree_imageScale.fig'));

% fig.PaperPositionMode = 'manual';
% orient(fig,'landscape')
% print(fig,strcat(savepath,'nodeDegree_imageScale_test.pdf'),'-dpdf','-fillpage')

%% create plots with error bars

% calculate and add std to overviews:

stdNDofHouses = std(sortedbyHP{1:end-1,2:end-1},0,2);
stdNDofParts = std(sortedbyHP{1:end-1,2:end-1});

sortedbyHP.stdOfHouses = [stdNDofHouses;NaN];
stdNDofParts = [stdNDofParts, NaN,NaN];

columnN3 = sortedbyHP.Properties.VariableNames;

sortedbyHP = [sortedbyHP;table('stdOfParts','VariableNames',columnN3(1)),array2table(stdNDofParts,'VariableNames',columnN3(2:end))];

% create error bar plots

% mean and std for each house
figure(2)
x = [1:213];
plotty2 = errorbar(sortedbyHP.meanOfHouses(1:end-2), sortedbyHP.stdOfHouses(1:end-2),'b','Linewidth',1);
xlabel('houses')
ylabel('node degree')
xlim([-1 215])
hold on

plotty2a = plot(sortedbyHP.meanOfHouses(1:end-2)','b','Linewidth',3);


hold off

print(gcf,strcat(savepath,'nodeDegree_mean_std_allHouses.png'),'-dpng','-r300'); 
savefig(gcf, strcat(savepath,'nodeDegree_mean_std_allHouses.fig'));

% mean and std for each participant

forPlotting = [array2table(sortedbyHP{end-1,2:end-2}'),array2table(sortedbyHP{end,2:end-2}','VariableNames',{'Var2'})];
forPlottingS = sortrows(forPlotting);

figure(3)
y = [1:20];
plotty3 = errorbar(forPlottingS{:,1},y, forPlotting{:,2},'horizontal','b','Linewidth',1);

xlabel('node degree')
ylabel('participants')
hold on
plotty3a = plot(forPlottingS{:,1},y,'b','Linewidth',3);

hold off

print(gcf,strcat(savepath,'nodeDegree_mean_std_allParticipants.png'),'-dpng','-r300'); 
savefig(gcf, strcat(savepath,'nodeDegree_mean_std_allParticipants.fig'));



 %saveas(gcf,strcat(savepath,'ImageScale_DegreeCentrality_allParticipants.png'),'png');
 %fig.PaperPositionMode = 'manual';
 %orient(fig,'landscape')
 %print(gcf,'ImageScale_DegreeCentrality_allParticipants.pdf','-dpdf','-fillpage')
 


