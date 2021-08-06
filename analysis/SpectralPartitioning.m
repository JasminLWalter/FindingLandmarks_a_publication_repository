%% ----------------------- Spectral Partitioning --------------------------

% -------------------- written by Lucas Essmann - 2020 --------------------
% ---------------------- lessmann@uni-osnabrueck.de -----------------------

% Requirements:
% undirected, unweighted graphs with Edges and Nodes Table 
% The Edges Table needs to contain an EndNodes column

%Spectral Graph Analysis consists of three steps
%--------------------------------------------------------------------------
% 1. Pre-Processing: Create the Laplacian Matrix of the graph 
%    (Degree Matrix - Adjacency Matrix) 
%--------------------------------------------------------------------------
% 2. Decomposition: Compute Eigenvalues and eigenvectors of the matrix.
%    Take the second smaller eigenvalue/eigenvector
%--------------------------------------------------------------------------
% 3. Grouping: Split the vector in two (negative and positiv components) 
%    to get two clusters
%--------------------------------------------------------------------------

% At the current state the script checks if the graph is connected or not,
% i.e. if there are nodes with Node Degree = 0. If there is only one not
% connected node, it is removed for the analysis to be able to use the
% second smallest Eigenvalue. Iff there are more than 1 non connected nodes
% the 3rd smallest Eigenvalue will be used. 

clear all;

plotting_wanted = false; % if you want to plot, set to true
saving_wanted = false; % if you want to save, set to true

%% -------------------------- Initialisation ------------------------------

path = what;
path = path.path;

%savepath
savepath = strcat(path,'/Results/SpectralPartitioning/');

% cd into graph folder location
cd graphs;

%graphfolder
PartList = dir();
PartList = struct2cell(PartList);
%reduce the folder to the graphs only
PartList = PartList(1,3:end);
% amount of graphs
totalgraphs = length(PartList);

%Documentation Table
Doc = table();
Cut_Edges = table();

%% ----------------------------- Main -------------------------------------

for part = 1:totalgraphs
    %load graph
    graphy = load(string(PartList(part)));
    graphy = graphy.graphy;
    currentPart = PartList{part}(1:2);
    
%First of all check whether the graph is fully connected or not! IFF the
%graph has ONE node that is not connected, delete/ignore the node for
%partitioning! Else (2 or more single nodes) proceed the script

%Search for nodes with degree zero!
    cent = centrality(graphy,'degree');
    k = find(cent==0);
    %Iff k has only one entry: create a subgraph without the one node
    if length(k) <= 1 
        node2rmv = table2array(graphy.Nodes(k,:));
        OG_graphy = graphy;
        graphy = rmnode(graphy,node2rmv);
    else 
        disp('Graph is not fully connected, 3rd smallest EV will be used');
    end
%% ----------------------------- Step 1 -----------------------------------

DegreeMatrix = diag(degree(graphy));

AdjacencyMatrix = full(adjacency(graphy));

LaplacianMatrix = DegreeMatrix - AdjacencyMatrix;


%% ----------------------------- Step 2 -----------------------------------
%Step 2 and 3 are executed twice depending on the graph being connected or
%not! 
[EigenvectorL,EigenvalueL] = eig(LaplacianMatrix);
[EigenvectorA,EigenvalueA] = eig(AdjacencyMatrix);
eigenvector2L = [];
eigenvector3L = [];
eigenvalue2L = [];
eigenvalue3L = [];


%-------------------- Step 2 - Graph Connected ----------------------------
%Check whether the graph is connected or not 
%Iff connected, eig2 > 0, else eig2 = 0, then use eig3!

% Graph is connected (if not: go to line 260)
    if EigenvalueL(2,2) > 1e-10

        eigenvalue2L = EigenvalueL(2,2);
        eigenvector2L = EigenvectorL(:,2);
        AllEigValuesL(:,part) = eigenvalue2L;

%---------------------------- Controls ------------------------------------
        %Checking whether the Eigenvalues and Eigenvectors have the right
        %corresponding arrangement
        [d,ind] = sort(diag(EigenvalueL));
        Vs = EigenvectorL(:,ind);
        control_square(part,1) = sum(eigenvector2L);
        control_square(part,2) = sum(eigenvector2L.^2);

            if isequal(EigenvectorL,Vs)  ...
                    && sum(eigenvector2L) ...
                    < 1e-10 && sum(eigenvector2L.^2) ...
                    > 1-1e-10
                disp(strcat('Participant_',currentPart,' is valid'));
            else
                disp(strcat('Something went wrong, ', ...
                    'the Eigenvector might be the wrong one - Part_',...
                    currentPart) );
            end

%-------------------- Step 3 - Graph Connected ----------------------------
    %Sort the eigenvector
    [eigenvector2_sort,index] = sort(eigenvector2L,'ascend');
    %Split it into positive and negative part
    eig_pos = eigenvector2_sort(eigenvector2_sort > 0);
    eig_neg = eigenvector2_sort(eigenvector2_sort < 0);
    %
    eig_posT = table();
    eig_negT = table();
    eig_posT.eig_pos = eig_pos;
    eig_posT.index = index(1:length(eig_pos));
    eig_posT.house = graphy.Nodes{eig_posT.index,:};
    eig_negT.eig_neg = eig_neg;
    eig_negT.index = index(length(eig_pos)+1:end);
    eig_negT.house = graphy.Nodes{eig_negT.index,:};

    %Documentation:
    Doc.meanEigVec(part,:) = mean(eigenvector2L);
    Doc.stdEigVec(part,:) = std(eigenvector2L);
    Doc.Eigenvalue2L(part,:) = eigenvalue2L;
  
    Cut_Edges.Part(part,:) = currentPart;
    Cut_Edges.TotalEdges(part,:) = numedges(graphy);
    
    Cut_Edges.C1_Edges(part,:) = ...
        sum(AdjacencyMatrix(eig_posT.index,eig_posT.index),'all')/2;
    
    Cut_Edges.C2_Edges(part,:) = ...
        sum(AdjacencyMatrix(eig_negT.index,eig_negT.index),'all')/2;
    
    Cut_Edges.CutEdges(part,:) = ...
        Cut_Edges.TotalEdges(part,:) ...
        - (Cut_Edges.C1_Edges(part,:) ...
        + Cut_Edges.C2_Edges(part,:));
    
    Cut_Edges.Portion(part,:) = ...
        Cut_Edges.CutEdges(part,:)/Cut_Edges.TotalEdges(part,:);
    
    Cut_Edges.DensityGraph(part,:) = ...
        numedges(graphy)/nchoosek(numnodes(graphy),2);
    
    NodesC1 = ...
        length(AdjacencyMatrix(eig_posT.index,eig_posT.index));
    
    NodesC2 = ...
        length(AdjacencyMatrix(eig_negT.index,eig_negT.index));
    
    Cut_Edges.DensityC1(part,:) = ...
        Cut_Edges.C1_Edges(part,:)/nchoosek(NodesC1,2);
    
    Cut_Edges.DensityC2(part,:) = ...
        Cut_Edges.C2_Edges(part,:)/nchoosek(NodesC2,2);
    
    Cut_Edges.AvgDensity(part,:) = ...
        (Cut_Edges.DensityC1(part,:)+Cut_Edges.DensityC2(part,:))/2;
    
    Cut_Edges.CutDensity(part,:) = ...
        Cut_Edges.CutEdges(part,:)/(NodesC1*NodesC2);
    
%---------------------------- Plotting ------------------------------------
    if plotting_wanted == true
        
        
      % Plotting the second smallest Eigenvector (sorted)
        figure('Name',strcat('Part_',currentPart,'_Eig2'));
        plot(sort(eigenvector2L),'.-');
        if saving_wanted == true
            saveas(gcf,strcat(savepath,'2rdSmallestEigenvector_',...
                currentPart,'.png'),'png');
        end
        
      % Investigating the Adjacency Matrix:
      % Plotting the Adjacency Matrix based on the sorting distribution of  
      % the second smallest Eigenvector 
      % (Spy Matrix or Sparse Pattern Matrix)
        [ignore, path] = sort(eigenvector2L);
        figure('Name',strcat('Part_',currentPart,'_AdjacencySpy'));
        sortedAdj = AdjacencyMatrix(path,path);
        spy(sortedAdj);
        
      % Split into pos and neg part 
        p_neg = path(ignore<=0);
        p_pos = path(ignore>0);
        
        Adj_neg = sortedAdj;
        Adj_neg(p_pos,p_pos) = 0;
        Adj_pos = sortedAdj;
        Adj_pos(p_neg,p_neg) = 0;
        
        spy(Adj_pos,'r',20);
        hold on;
        spy(Adj_neg,'g',20);
        xlabel('Matrix Entries');
        ylabel('Matrix Entries');
        xticks([0 100 200]);
        yticks([0 100 200]);
        set(gca,'FontSize',40,'FontWeight','bold','Box','off');
        rectangle('Position',[0 0 212 212],'LineWidth',1.5);
        
        cmap = [0.40 0.80 0.42   %green
                0.27 0.38 0.99]; %blue
            
        if saving_wanted == true
            saveas(gcf,strcat(savepath,'Spy_AdjacencyMatrix_Part',...
                currentPart,'.png'),'png'); 
        end
        
      % Highlighting the graph partitions in the graph
        figure('Name',strcat('Part_',currentPart,'_Clusters'));
        plotty = plot(graphy,'MarkerSize',4,'LineWidth',1.5);
        highlight(plotty,index(1:length(eig_neg)),'NodeColor','r');
        highlight(plotty,index(length(eig_neg)+1:end),'NodeColor','g');
        if saving_wanted == true
            saveas(gcf,strcat(savepath,'Clusters_Part_',...
                currentPart,'.png'),'png');
        end
        
      % Plot the Eigenvalue Histogram and save the Eigenvalue Spectrum
        save([savepath 'Part_' currentPart '_EigenvalueSpectrumL,mat'],...
            'EigenvalueL');
        figure('Name', ...
            strcat('Part_',currentPart,'__2nd_Smallest_EigenvectorL'));
        histogram(eigenvector2L);
        xlabel('Eigenvector entry value'); ylabel('Count');
        if saving_wanted == true
            saveas(gcf,strcat(savepath,...
                'Part_',currentPart,...
                '_Histogram_2nd_Smallest_EigenvectorL.png'),'png');
        end

    end
    
%% Graph is not connected

%------------------- Step 2 - Graph Not Connected--------------------------

% Graph is not fully connected, the third smalles EV will be used (if >0)
    elseif EigenvalueL(3,3) > 1e-10
        
         disp(strcat(currentPart,' has a non-connected graph')) ;
         eigenvalue3L = EigenvalueL(3,3);
         eigenvector3L = EigenvectorL(:,3);

         AllEigValuesL(:,part) = eigenvalue3L;

        [d,ind] = sort(diag(EigenvalueL));
        Vs = EigenvectorL(:,ind);
        control_square(part,1) = sum(eigenvector3L);
        control_square(part,2) = sum(eigenvector3L.^2);

            if isequal(EigenvectorL,Vs)  ...
                    && sum(eigenvector3L) ...
                    < 1e-10 ...
                    && sum(eigenvector3L.^2) ...
                    > 1-1e-10
                disp(strcat('Participant_',currentPart,' is valid'));
            else
                disp(strcat('Something went wrong, ',...
                    'the Eigenvector might be the wrong one - Part_',...
                    currentPart) );
            end
            
%------------------- Step 3 - Graph Not Connected -------------------------
      % Sort the eigenvector
        [eigenvector3_sort,index] = sort(eigenvector3L,'ascend');
      % Split it into positive and negative part
        eig_pos = eigenvector3_sort(eigenvector3_sort > 0);
        eig_neg = eigenvector3_sort(eigenvector3_sort < 0);
        save([savepath 'Part_' currentPart '_eig_pos.mat'],...
            'eig_pos');
        save([savepath 'Part_' currentPart '_eig_neg.mat'],...
            'eig_neg');
        
  % Documentation:
    Doc.meanEigVec(part,:) = mean(eigenvector3L);
    Doc.stdEigVec(part,:) = std(eigenvector3L);
%---------------------------- Plotting ------------------------------------
        if plotting_wanted == true
            figure('Name',strcat('Part_',currentPart,'_Eig3'));
            plot(sort(eigenvector3L),'.-');
            
            if saving_wanted == true
                saveas(gcf,strcat(savepath,...
                    '3rdSmallestEigenvector_',...
                    currentPart,'.png'),'png'); 
            end
            %Investigating the Adjacency Matrix:
            [ignore,path] = sort(eigenvector3L);
            figure('Name',strcat('Part_',currentPart,'_AdjacencySpy'));
            spy(AdjacencyMatrix(path,path));
            
            if saving_wanted == true
                saveas(gcf,strcat(savepath,...
                    'Spy_AdjacencyMatrix_Part',...
                    currentPart,'.png'),'png');
            end
            
           % Highlighting the graph partitions in the graph
            figure('Name',strcat('Part_',currentPart,'_Clusters'));
            plotty = plot(graphy,'MarkerSize',4,'LineWidth',1.5);
            highlight(plotty,index(1:length(eig_neg)),'NodeColor','r');
            highlight(plotty,index(length(eig_neg)+1:end),'NodeColor','g');
            if saving_wanted == true
                saveas(gcf,strcat(savepath,...
                    'Clusters_Part_',...
                    currentPart,'.png'),'png');
            end
            %Plot the Eigenvalue Histogram and save the Eigenvalue Spectrum
            if saving_wanted == true
                save([savepath 'Part_' currentPart...
                    '_EigenvalueSpectrumL,mat'],'EigenvalueL');
            end
            figure('Name', strcat('Part_',...
                currentPart,'_2nd_Smallest_Eigenvector'));
            histogram(eigenvector3L);
            xlabel('Eigenvector entry value'); ylabel('Count');
            if saving_wanted == true
                saveas(gcf,strcat(savepath,...
                    'Part_',currentPart,...
                    '_Histogram_3nd_Smallest_EigenvectorL.png'),'png');
            end
        end
    else 
        disp(strcat(currentPart,...
            'seems to be seperated into three graphs'));
        end 
        
%----------------------------- Saving -------------------------------------
       if saving_wanted == true    
            save([savepath 'Part_' currentPart '_eig_pos.mat'],...
                'eig_posT');
            save([savepath 'Part_' currentPart '_eig_neg.mat'],...
                'eig_negT');
       end


            if saving_wanted == true
                save([savepath 'CutEdges.mat'],'Cut_Edges');
                save([savepath 'SpectralDocumentation.mat'],'Doc');
            end
end

clearvars '-except' ...
    Cut_Edges ...
    Doc;
   
disp('Done');
