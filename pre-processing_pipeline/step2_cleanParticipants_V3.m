%% ---------------------step2_clean_Participants_V3.m----------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description:
% step 2 in pre-processing pipeline
% Script identifies the participants that have more than 30% of their data 
% labeled missing data (noData), thus, data samples during which pupil 
% recognition was below 50%. It also creates a new participant list 


% Input: 
% overviewAnalysis.mat = file created when running script
%                        step1_condenseRawData_V3.m
% Output: 
% newParticipantList     = file containing the cleaned participant list
% NewDataOverview        = data overview of the participants who are in the 
%                          new list
% discartedDataOverview  = data overview of the removed participants

%% adjust the following variables: savepath, current folder and participant list!-----------

clear all;

savepath = '....\preprocessing\';

cd '...\preprocessing\condensedColliders\'


% Participant list of all participants that participated at least 3
% sessions in the Seahaven - 90min
PartList = {1909 3668 8466 3430 6348 2151 4502 7670 8258 3377 1529 9364 6387 2179 4470 6971 5507 8834 5978 1002 7399 9202 8551 1540 8041 3693 5696 3299 1582 6430 9176 5602 2011 2098 3856 7942 6594 4510 3949 9748 3686 6543 7205 5582 9437 1155 8547 8261 3023 7021 5239 8936 9961 9017 1089 2044 8195 4272 5346 8072 6398 3743 5253 9475 8954 8699 3593 9848};

%-------------------------------------------------------------------------------------------------

% load overview fixated_vs_noise
overviewAnalysis = load('overviewAnalysis.mat');
overviewAnalysis = overviewAnalysis.overviewAnalysis;

% create table with all participants that have less than 30% data discarted
lessThan30 = overviewAnalysis{:,4} < 30;
lessThan30Table = overviewAnalysis(lessThan30,:);

% save list of participants, that have less than 30% data discarted
newParticipantList = lessThan30Table{:,1}';
Number= length(newParticipantList);
save(strcat(savepath, 'newParticipantList'),'newParticipantList');

% analyse data of new participant list
summaryNewData = array2table(zeros(1,3),'VariableNames',{'Min','Max','Average'});
summaryNewData.Min(1) = min(lessThan30Table{:,4});
summaryNewData.Max(1) = max(lessThan30Table{:,4});
summaryNewData.Average(1) = mean(lessThan30Table{:,4});

save(strcat(savepath, 'NewDataOverview'), 'summaryNewData');

discarted= overviewAnalysis{:,4} >= 30;
discartedDataOverview= overviewAnalysis(discarted,:);
save(strcat(savepath, 'discartedDataOverview'), 'discartedDataOverview');
testMean = mean(discartedDataOverview.percentage);
        

disp('done');

