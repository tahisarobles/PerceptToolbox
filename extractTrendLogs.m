function extractTrendLogs(data, params)
% Bart Keulen 04.10.2020
% Modified by Tahisa Robles 06.05.2021 
    % Added script to extract marked events 

% Extract parameters for this recording mode
recordingMode = params.recordingMode;
fname = params.fname;

% Extract recordings left and right
data_left = data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Left;
data_right = data.DiagnosticData.LFPTrendLogs.HemisphereLocationDef_Right;

if ~isequal(fieldnames(data_left), fieldnames(data_right))
    error('Recordings of both hemispheres do not match')
end

recFields = fieldnames(data_left);
nRecs = numel(recFields);

allLeft = table;
allRight = table;

%Concatenate data accross days
for recId = 1:nRecs
    
    datafield_left = struct2table(data_left.(recFields{recId}));
    allLeft = [allLeft; datafield_left]; %#ok<*AGROW>
    
    datafield_right = struct2table(data_right.(recFields{recId}));
    allRight = [allRight; datafield_right];
   
end

allLeft = sortrows(allLeft, 1);
allRight = sortrows(allRight, 1);

%Extract LFP, stimulation amplitude and date-time information
LFP = [allLeft.LFP allRight.LFP];
mA = [allLeft.AmplitudeInMilliAmps allRight.AmplitudeInMilliAmps];
DateTime = cellfun(@(x) datetime(regexprep(x(1:end-1),'T',' ')), allLeft.DateTime);

% Store data in one struct
LFPTrendLogs.nChannels = 2;
LFPTrendLogs.LFP = LFP;
LFPTrendLogs.stimAmp = mA;
LFPTrendLogs.time = DateTime;
LFPTrendLogs.ylabel = {'LFP band power', 'Stimulation amplitude (mA)'};
LFPTrendLogs.xlabel = 'DateTime';
LFPTrendLogs.channel_names = {'Left', 'Right'};
LFPTrendLogs.json = fname;
LFPTrendLogs.recordingMode = recordingMode;

% If patient has marked events, extract them

if isfield(data.DiagnosticData, 'LfpFrequencySnapshotEvents')
 data_events = cell2table(data.DiagnosticData.LfpFrequencySnapshotEvents);


 % note EventID 1 = 'off' and EventID 2 = 'overbeweegelijkheid' for patient
 % NL3_JA
 
 for i=1:(size(data_events,1))
     EventID_events(i)=data.DiagnosticData.LfpFrequencySnapshotEvents{i, 1}.EventID;
     DateTime_events(i)=convertCharsToStrings(data.DiagnosticData.LfpFrequencySnapshotEvents{i, 1}.DateTime);
 end 
 
 DateTime_events=convertStringsToChars(DateTime_events(:));

%  for i=1:size(data_events,1) %WEGHALEN 
%      S=DateTime_events(i);
%      S = S(1:end-1);
%      DateTime_events(i)=S;
%  end 
%-----------------

% if isfield(data.DiagnosticData, 'LfpFrequencySnapshotEvents')
%     data_events = data.DiagnosticData.LfpFrequencySnapshotEvents;
%     nEvents = size(data_events, 1);
%     events = table;
%     for eventId = 1:nEvents
% %         thisEvent = struct2table(data_events(eventId), 'AsArray', true); 
%         thisEvent = struct2table(data.DiagnosticData.LfpFrequencySnapshotEvents{eventId, 1}.EventID , 'AsArray', true);
%         events(eventId, :) = thisEvent(:, 1:5); %remove potential 'LfpFrequencySnapshotEvents'
%     end
%     events.DateTime = cellfun(@(x) datetime(regexprep(x(1:end-1),'T',' ')), events.DateTime);
%     LFPTrendLogs.events = events;
% end

% Plot
plotLFPTrendLogs(LFPTrendLogs, params,DateTime_events,EventID_events,data_events);


% Save TrendLogs in one file
savename = append(regexprep(params.ptID,' ','_'),'_',fname(end-19:end-5),'_LFPTrendLogs.mat');
save([params.data_pathname filesep savename], 'LFPTrendLogs')
disp([savename ' saved'])
    
end