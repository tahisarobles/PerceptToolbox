function extractLFP(data, params, varargin)
%Yohann Thenaisie 04.09.2020
%Modified by Bart Keulen 15.10.2020

if nargin > 2 && strcmpi(params.recordingMode,'BrainSenseTimeDomain')
    all_stimAmp = varargin{1};
end

%Extract parameters for this recording mode
recordingMode = params.recordingMode;
nChannels = params.nChannels;
fname = params.fname;

%Identify the different recordings
nLines = size(data.(recordingMode), 1);
FirstPacketDateTime = cell(nLines, 1);
for lineId = 1:nLines
    FirstPacketDateTime{lineId, 1} = data.(recordingMode)(lineId).FirstPacketDateTime;
end
FirstPacketDateTime = categorical(FirstPacketDateTime);
recNames = unique(FirstPacketDateTime);
nRecs = numel(recNames);

%Extract LFPs in a new structure for each recording
for recId = 1:nRecs
    
    if exist('all_stimAmp','var')
        stimAmp = all_stimAmp(recId);
    end
    
    datafield = data.(recordingMode)(FirstPacketDateTime == recNames(recId));
    
    LFP = struct;
    LFP.nChannels = size(datafield, 1);
    if LFP.nChannels ~= nChannels
        warning(['There are ' num2str(LFP.nChannels) ' instead of the expected ' num2str(nChannels) ' channels'])
    end
    LFP.channel_names = cell(1, LFP.nChannels);
    LFP.rawData = [];
    for chId = 1:LFP.nChannels
        LFP.channel_names{chId} = datafield(chId).Channel;
        LFP.rawData(:, chId) = datafield(chId).TimeDomainData;
    end
    
    LFP.Fs = datafield(chId).SampleRateInHz;
    
    %Extract size of received packets
    GlobalPacketSizes = str2num(datafield(1).GlobalPacketSizes); %#ok<ST2NM>
    if sum(GlobalPacketSizes) ~= size(LFP.rawData, 1)
       warning('Data length differs from the sum of packet sizes') 
    end
    
    %Extract timestamps of received packets
    TicksInMses = str2num(datafield(1).TicksInMses); %#ok<ST2NM>
    if ~isempty(TicksInMses) %TicksInMses is empty for SenseChannelTest
        TicksInS = (TicksInMses - TicksInMses(1))/1000; %convert to seconds and initiate at 0
        LFP.firstTickInSec = TicksInMses(1)/1000; %first tick time (s)
        
        %If there are more ticks in data packets, ignore extra ticks
        nPackets = numel(GlobalPacketSizes);
        nTicks = numel(TicksInS);
        if  nPackets ~= nTicks
            warning('GlobalPacketSizes and TicksInMses have different lengths')
%             
%             maxPacketId = max([nPackets, nTicks]);
%             nSamples = size(LFP.rawData, 1);
%             
%             %Plot
%             figure; subplot(2, 1, 1); plot(TicksInS, '.'); xlabel('Data packet ID'); ylabel('TicksInS'); xlim([0 max([nPackets nTicks])])
%             subplot(2, 1, 2); plot(cumsum(GlobalPacketSizes), '.'); xlabel('Data packet ID'); ylabel('Cumulated sum of samples received'); xlim([0 max([nPackets nTicks])]);
%             hold on; plot([0 maxPacketId], [nSamples, nSamples], '--')
            
%             TicksInS = TicksInS(1:nPackets);

        end
        
        %Check if some ticks are missing
        %isDataMissing = logical(TicksInS(end) >= sum(GlobalPacketSizes)/LFP.Fs);
        
        %     if isDataMissing
        %         LFP = correct4MissingSamples(LFP, TicksInS, GlobalPacketSizes);
        %     end

    end
    
    % Filter out stimulation frequency
    [b,a] = butter(3,params.Fc/(LFP.Fs/2));
    LFP.data = filtfilt(b,a,LFP.rawData);
    
    % Set time and channel map
    LFP.time = (1:length(LFP.data))/LFP.Fs; % [s]
    if LFP.nChannels <= 2
        LFP.channel_map = 1:LFP.nChannels;
    else
        LFP.channel_map = params.channel_map;
    end
    
    LFP.xlabel = 'Time (s)';
    LFP.ylabel = 'LFP (uV)';
    LFP.ptID = params.ptID;
    LFP.json = fname;
    LFP.recording = regexprep(char(recNames(recId)), {':', '-'}, {''});
    LFP.recordingMode = recordingMode;
    
    % Save
    if  strcmpi(recordingMode, 'IndefiniteStreaming')
        
        % Plot
        plotChannels(LFP.data, LFP, params);
        plotPwelch(LFP.data, LFP, params);
        
        % Save
        savename = append(regexprep(params.ptID,' ','_'),'_',LFP.recording(1:end-5),'_IndefiniteStreaming.mat');
        save([params.data_pathname filesep savename], 'LFP')
        
    elseif strcmpi(recordingMode, 'SenseChannelTests')
        
        % Plot
        plotChannels(LFP.data, LFP, params);
        plotPwelch(LFP.data, LFP, params);
        
        % Save
        savename = append(regexprep(params.ptID,' ','_'),'_',LFP.recording(1:end-5),'_SenseChannelTests.mat');
        save([params.data_pathname filesep savename], 'LFP')
        
    elseif strcmpi(recordingMode, 'BrainSenseTimeDomain')
        
        % Plot
        plotChannels(LFP.data, LFP, params, stimAmp);
        plotSpectrogram(LFP.data, LFP, params, stimAmp);
        
        % Save
        savename = append(regexprep(params.ptID,' ','_'),'_',LFP.recording(1:end-5),'_BrainSenseTimeDomain.mat');
        save([params.data_pathname filesep savename], 'LFP', 'stimAmp')
    end
    disp([savename ' saved'])
    
end
end