%% ------------------analysis_gazes_clusterLength.m------------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description: 
% Combines all participant data after interpolation. 
% In addition, it creates the pie plot comparing the number of gazes with 
% the number of excluded data. 
% Thirdly, it creates the histograms of the distribution of cluster
% durations

% Input: 
% uses data file interpolatedColliders_3Sessions_V3

% Output: 
% mean_gazes_noise_distr.png        = pie plot of gazes and excluded data 
%                                     (fig. 2c)
% viewing_duration_all.png          = histogram of hit point cluster
%                                     distribution
% viewing_duration_bigCombined.png' = histogram of hit point cluster 
%                                     distribution where all clusters
%                                     bigger than 1000ms are combined in
%                                     the last bin (fig. 2b)
% OverviewGazes.mat                 = summary of number and percentage of data
%                                     rows with noData (= missing data samples)
%                                     for each participant
% allInterpolatedData.mat           = all the loaded data from all participants
%                                     combined in one file
% allSamples_int.mat                = all the samples from all the
%                                     participants combined in one file
% Missing_Participant_Files.mat     = contains all participant numbers where the
%                                     data file could not be loaded




clear all;
%% adjust the following variables: savepath, current folder and participant list!-----------

savepath = '...\analysis\gazes_clusterLength\';

cd '...\preprocessing\interpolatedColliders\'

% participant list of 90 min VR - only with participants who have lost less than 30% of
% their data (after running script cleanParticipants_V2)

% 20 participants with 90 min VR trainging less than 30% data loss
PartList = {21 22 23 24 26 27 28 30 31 33 34 35 36 37 38 41 43 44 45 46};

%----------------------------------------------------------------------------

Number = length(PartList);
noFilePartList = [];
countMissingPart = 0;
countAnalysedPart= 0;


overviewGazes= table('size',[Number,4],'VariableTypes',{'double','double','double','double'},...
                    'VariableNames',{'Participant','SumGazeSamples','SumNoiseSamples','SumAllSamples'});
allSamples = [];

allInterpData = struct;


for ii = 1:Number
    currentPart = cell2mat(PartList(ii));
    
    file = strcat(num2str(currentPart),'_interpolatedColliders_3Sessions_V3.mat');
    
 
    % check for missing files
    if exist(file)==0
        countMissingPart = countMissingPart+1;
        
        noFilePartList = [noFilePartList;currentPart];
        disp(strcat(file,' does not exist in folder'));
    %% main code   
    elseif exist(file)==2
        countAnalysedPart = countAnalysedPart +1;
        % load data
        interpolatedData = load(file);
        interpolatedData = interpolatedData.interpolatedData;
        
        % save all data into one struct --> allInterpData
        % copy the data to the struct if it is empty (first participant)
        if(size(allInterpData) == [1 1])
            allInterpData = interpolatedData;
        end
        allInterpData = [allInterpData, interpolatedData];

        allSamples = [allSamples, allInterpData(:).Samples];
        
        % save information about distribution of gazes and noise
        % something was fixated when having more than 7 samples
        gazes = [interpolatedData(:).Samples] > 7;

        
        gazedObjects = interpolatedData(gazes);
        
        noisyObjects = interpolatedData(not(gazes));
              
        
        sumG = sum([gazedObjects(:).Samples],'omitnan');
        sumN = sum([noisyObjects(:).Samples],'omitnan');
        overviewGazes.Participant(ii) = currentPart;
        overviewGazes.SumGazeSamples(ii) = sumG;
        overviewGazes.SumNoiseSamples(ii) = sumN;
        overviewGazes.SumAllSamples(ii) = sum([interpolatedData(:).Samples],'omitnan');
        
%         figure(1)
%         pieplot= pie([sumG,sumN]);
%         legend({'gazes / bigger 7 samples','noise / smaller/equal 7 samples'},'Location','northeastoutside')
%         title(strcat('gazes noise distribution - participant: ', num2str(currentPart)))
%         savefig(gcf, strcat(savepath, num2str(currentPart) ,'_gazes_noise_distr.fig'));
%         
%         %saveas(gcf,strcat(savepath, num2str(currentPart) ,'_gazes_noise_distr.png'),'png');
%         print(gcf,strcat(savepath, num2str(currentPart) ,'_gazes_noise_distr.png'),'-dpng','-r300'); 
%         

     
  

        
    else
        disp('something went really wrong with participant list');
    end

end

%% plot pie plot of distribution gazes vs noise
avgG = mean(overviewGazes.SumGazeSamples);
avgN = mean(overviewGazes.SumNoiseSamples);

figure(2)
pieplot2 = pie([avgG, avgN]);
legend({'gazes / bigger 7 samples','noise / smaller/equal 7 samples'},'Location','northeastoutside')
title('mean gazes noise distribution')

saveas(gcf,strcat(savepath,'mean_gazes_noise_distr.png'),'png');
print(gcf,strcat(savepath,'mean_gazes_noise_distr.png'),'-dpng','-r300'); 
savefig(gcf, strcat(savepath,'mean_gazes_noise_distr.fig'));

percentage = NaN(Number,2);

percentage(:,1) = (overviewGazes.SumGazeSamples*100) ./ overviewGazes.SumAllSamples;
percentage(:,2) = (overviewGazes.SumNoiseSamples*100) ./ overviewGazes.SumAllSamples;

% figure(3)
% 
% plotty3 = boxplot(percentage(:,2));
% title('percentage of noisy data distribution over all participants')
% ylabel('percentage')
% 
% saveas(gcf,strcat(savepath,'perc_noisy_data_distr_allParts.png'),'png');
% 
% print(gcf,strcat(savepath,'perc_noisy_data_distr_allParts.png'),'-dpng','-r300'); 
% savefig(gcf, strcat(savepath,'perc_noisy_data_distr_allParts.fig'));


%% distribution of cluster sizes over all participants
figure(4)

histyAll= histogram(allSamples,'Normalization','probability');
yt = get(gca, 'YTick');  
xt = get(gca, 'XTick');
% set(gca, 'YTick',yt, 'YTickLabel',yt*100);
set(gca, 'XTick',xt, 'XTickLabel',xt*33.33);

ax = gca;
ax.XLabel.String = 'Distribution of hit point clusters (time in ms)';
ax.XLabel.FontSize = 12;
ax.YLabel.String = 'Probability';
ax.YLabel.FontSize = 12;
saveas(gcf,strcat(savepath,'viewing_duration_all.png'),'png');

print(gcf,strcat(savepath,'viewing_duration_all.png'),'-dpng','-r300'); 
savefig(gcf, strcat(savepath,'viewing_duration_all.fig'));

%% big durations combined into 31st bin

big30= allSamples > 30;

combSamples = allSamples;
combSamples(big30) = 31;

figure(5)

histyCombined = histogram(combSamples,'Normalization','probability');
yt = get(gca, 'YTick');                    
% set(gca, 'YTick',yt, 'YTickLabel',yt*100);
xt= [1:3:31];
set(gca, 'XTick',xt, 'XTickLabel',xt*33.33);

ax = gca;
ax.XLabel.String = 'Distribution of hit point clusters (time in ms)';
ax.XLabel.FontSize = 12;
ax.YLabel.String = 'Probability';
ax.YLabel.FontSize = 12;

saveas(gcf,strcat(savepath,'viewing_duration_bigCombined.png'),'png');

print(gcf,strcat(savepath,'viewing_duration_bigCombined.png'),'-dpng','-r300'); 
savefig(gcf, strcat(savepath,'viewing_duration_bigCombined.fig'));

% save overviews
save([savepath 'Overview_Gazes.mat'],'overviewGazes');
save([savepath 'allInterpolatedData.mat'],'allInterpData');
save([savepath 'allSamples_int.mat'],'allSamples');





disp(strcat(num2str(Number), ' Participants in List'));
disp(strcat(num2str(countAnalysedPart), ' Participants analyzed'));
disp(strcat(num2str(countMissingPart),' files were missing'));

csvwrite(strcat(savepath,'Missing_Participant_Files'),noFilePartList);
disp('saved missing participant file list');



disp('done');