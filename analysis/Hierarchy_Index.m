%% -------------------- Hierarchy_Index -----------------------

% -------------------- written by Lucas Essmann - 2020 --------------------
% ---------------------- lessmann@uni-osnabrueck.de -----------------------

%Hierarchy index 

% Requirements:
% undirected, unweighted graphs with Edges and Nodes Table 

%--------------------------------------------------------------------------
%Procedure: 
%Plotting all occuring degree values against their frequency
%Afterwards fitting a power law function (a*x^b). 
%The inverse of b is the Hierarchy Index, the higher the index, the
%stronger the hierarchy. Values below 1 are considered as no existing
%hierarchy.

clear all;

plotting_wanted = false; %if you want to plot, set to true
saving_wanted = false; %if you want to save, set to true


%% -------------------------- Initialisation ------------------------------

path = what;
path = path.path;

%savepaths
savepath = strcat(path,'/Results/HierarchyIndex/');

% cd into graph folder location
cd graphs;

%graphfolder
PartList = dir();
PartList = struct2cell(PartList);
%reduce the folder to the graphs only
PartList = PartList(1,3:end);
% amount of graphs
totalgraphs = length(PartList);

HierarchyIndex = table();

    
%% ----------------------------- Main -------------------------------------
for part = 1:totalgraphs
    
    %Create and reset the variables in the loop
    NodeDegree = [];
    UniqueDegree = [];
    NodeDegreeMed = [];
    UniqueDegreeMed = [];
    DegreeFrequency = [];
    DegreeFrequencyMed = [];

   %load graph
    graphy = load(string(PartList(part)));
    graphy = graphy.graphy;
    currentPart = PartList{part}(1:2);

   %Calculate the degree
    NodeDegree = degree(graphy); 
    
%% ------------------------- Hierarchy Index ------------------------------
   %Delete 0 degrees (non connected nodes)
    NodeDegree(NodeDegree == 0) = [];
    UniqueDegree = unique(NodeDegree);
    UniqueDegree = sort(UniqueDegree);
   %do another fit only for the NDs > median(NodeDegree) 
    NodeDegreeMed = NodeDegree(NodeDegree>median(NodeDegree));
    UniqueDegreeMed = unique(NodeDegreeMed);
    UniqueDegreeMed = sort(UniqueDegreeMed);
    
    
   %Count how often each degree exists for all nodes (Degree Frequency)
    for ndfreq = 1:length(UniqueDegree)
        DegreeFrequency(ndfreq,:) = ...
            sum(NodeDegree(:) == UniqueDegree(ndfreq,1));
    end
    
   %Same for the meds
    for medfreq = 1:length(UniqueDegreeMed)
        DegreeFrequencyMed(medfreq,:) = ...
            sum(NodeDegreeMed(:) == UniqueDegreeMed(medfreq,1));
    end
    
   %log the axis
    UniqueDegreeMed = log(UniqueDegreeMed);
    DegreeFrequencyMed = log(DegreeFrequencyMed);
   %Fit a curve to the log data above the median with an exponential fit
   %(ax+b)
    ft2 = fittype(@(a,b,x) a*x+b);
    f2 = fit(UniqueDegreeMed,DegreeFrequencyMed,ft2);
    HierarchyIndex.Part(part,:) = currentPart;
    HierarchyIndex.Slope(part,:) = f2.a;
    
   %Fit a curve to the data with a Power Fit
    ft = fittype(@(a,b,x)a*x.^b);
    f = fit(UniqueDegree,DegreeFrequency,ft);
   %The hierarchy index is the inverse exponent of x
    HierarchyIndex.HierarchyIndex(part,:) = -f.b;

    
%% -------------------------- Plotting ------------------------------------

    if plotting_wanted == true
    
        figgy = figure();
        scatter(log(UniqueDegree),...
            log(DegreeFrequency),...
            300,...
            [0.24,0.15,0.66],...
            'filled');
        hold on;
        plotty = fplot(@(x) f2.a*x+f2.b,...
            [min(UniqueDegreeMed),max(UniqueDegreeMed)],...
            'LineWidth',3,'Color',[0.96,0.73,0.23]);
        xlim([0 4]); ylim([0 4]);
        xticks([0,1,2,3,4]);
        yticks([0,1,2,3,4]) 
        rectangle('Position',[0 0 4 4],'LineWidth',1.5);


        plotty = plot(f2,...
            log(UniqueDegree),...
            log(DegreeFrequency),...
            [min(DegreeFrequencyMed),max(DegreeFrequencyMed)]);
        xlabel('Degree'); ylabel('Frequency');
        set(gca,'FontName','Helvetica','FontSize',40,'FontWeight','bold')
        
    if saving_wanted == true
         saveas(gcf,strcat(savepath_fig,...
             'Med_Hierarchy_Fit_Part',...
             currentPart,'.png'),'png');
    end

         close(figgy);

    histy = histogram(HierarchyIndex.Slope,7);
    xlabel('Hierarchy Index'); 
    ylabel('Frequency');
    ylim([0 6.5]);
    set(gca,'FontName','Helvetica','FontSize',40)

    end
     
end



%% --------------------------- Saving -------------------------------------

if saving_wanted == true
    
    save([savepath 'HierarchyIndex_Table.mat'],'HierarchyIndex');
    disp('Saved HierarchyIndex_Table');
    
end

disp('Done');

clearvars '-except' ...
    HierarchyIndex;
