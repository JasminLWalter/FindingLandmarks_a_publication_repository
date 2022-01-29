%% -------------------step2_optional_join3SessionsVR_V3.m------------------

% --------------------script written by Jasmin L. Walter-------------------
% -----------------------jawalter@uni-osnabrueck.de------------------------

% Description:
% optional step after step 2 in pre-processing pipeline
% (only necessary if data acquisition was completed in several sessions)
% combines condensedColliders files of different VR sessions into one file
% here combines the three 30 min sessions of one participant into one file

% Input: 
% combinedSessions_newPartNumbers.csv = list matching the different
%                                       numbers of each session to the 
%                                       respective participant (uploaded in
%                                       https://osf.io/aurjk/)
% condensedColliders_V3.mat = files created when running script
%                             step1_condenseRawData_V3.m
% uses
% Output: 
% condensedColliders3S.mat     = files combining the three sessions for
%                                each participant

clear all;

%% --------adjust the following variables savepath, cd, listpath

savepath = '...\preprocessing\combined3sessions\';

cd '...\preprocessing\condensedColliders\';

% load list that contains the participant numbers belonging together sorted
% into the different sessions (this list here is uploaded with the other
% data)
listpath = '...\preprocessing\combined3Sessions\combinedSessions_newPartNumbers.csv';


%% main code
% here the 3 sessions belonging together are combined into one file
% not that there is a row with empty values and collider identifyer 
% "1/2/3Session" that sepparates the sessions for later identification 


combinedSessions = readtable(listpath);
for part = 1: height(combinedSessions)


    data1 = load(strcat(num2str(combinedSessions.Session1(part)),'_condensedColliders_V3.mat'));
    data1 = data1.condensedData;
    
    data2 = load(strcat(num2str(combinedSessions.Session2(part)),'_condensedColliders_V3.mat'));
    data2 = data2.condensedData;
    
    data3 = load(strcat(num2str(combinedSessions.Session3(part)),'_condensedColliders_V3.mat'));
    data3 = data3.condensedData;
    
    % add variable session to each data
    % for data1
    s1 = cell(length(data1),1);
    s1(:) = {'Session1'};
    [data1.Session] = s1{:};
    order = [21,1:20];
    data1 = orderfields(data1,order);
    
    % for data2
    s2 = cell(length(data2),1);
    s2(:) = {'Session2'};
    [data2.Session] = s2{:};
    data2 = orderfields(data2,order);
            
    % for data3
    s3 = cell(length(data3),1);
    s3(:) = {'Session3'};
    [data3.Session] = s3{:};
    data3 = orderfields(data3,order);
    
    
    % add a row to seperate sessions, in case they need to be identified
    % again at a later point
    data1(end+1).Collider = 'newSession';  
    
    data1(end).Session= NaN; 
    data1(end).TimeStamp= NaN; 
    data1(end).Samples= NaN; 
    data1(end).Distance= NaN; 
    data1(end).hitPointX= NaN; 
    data1(end).hitPointY= NaN; 
    data1(end).hitPointZ= NaN; 
    data1(end).PosX= NaN; 
    data1(end).PosY= NaN; 
    data1(end).PosZ= NaN; 
    data1(end).PosRX= NaN; 
    data1(end).PosRY= NaN; 
    data1(end).PosRZ= NaN; 
    data1(end).PosTimeStamp=NaN; 
    data1(end).PupilLTimeStamp= NaN; 
    data1(end).VectorX= NaN; 
    data1(end).VectorY= NaN; 
    data1(end).VectorZ= NaN; 
    data1(end).eye2Dx= NaN; 
    data1(end).eye2Dy= NaN; 

    % same with data2
    
    data2(end+1).Collider = 'newSession';
    
    data2(end).Session= NaN; 
    data2(end).TimeStamp= NaN; 
    data2(end).Samples= NaN; 
    data2(end).Distance= NaN; 
    data2(end).hitPointX= NaN; 
    data2(end).hitPointY= NaN; 
    data2(end).hitPointZ= NaN; 
    data2(end).PosX= NaN; 
    data2(end).PosY= NaN; 
    data2(end).PosZ= NaN; 
    data2(end).PosRX= NaN; 
    data2(end).PosRY= NaN; 
    data2(end).PosRZ= NaN; 
    data2(end).PosTimeStamp=NaN; 
    data2(end).PupilLTimeStamp= NaN; 
    data2(end).VectorX= NaN; 
    data2(end).VectorY= NaN; 
    data2(end).VectorZ= NaN; 
    data2(end).eye2Dx= NaN; 
    data2(end).eye2Dy= NaN;

    % combine all the session
    condensedColliders3S = [data1, data2, data3];
    newName = strcat(num2str(combinedSessions.newPartNumber(part)),'condensedColliders_3Sessions_V3');
    save(strcat(savepath,newName),'condensedColliders3S');

end


disp('done');
