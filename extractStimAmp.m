function all_stimAmp = extractStimAmp(data, params)
%Yohann Thenaisie 24.09.2020

%Extract parameters for this recording mode
recordingMode = params.recordingMode;

%Identify the different recordings
nLines = size(data.(recordingMode), 1);
FirstPacketDateTime = cell(nLines, 1);
for lineId = 1:nLines
    FirstPacketDateTime{lineId, 1} = data.(recordingMode)(lineId).FirstPacketDateTime;
end
FirstPacketDateTime = categorical(FirstPacketDateTime);
recNames = unique(FirstPacketDateTime);
nRecs = numel(recNames);

% Initialize stimAmp
all_stimAmp(nRecs).data = [];

for recId = 1:nRecs
    
    commaIdx = regexp(data.(recordingMode)(recId).Channel, ',');
    nChannels = numel(commaIdx)+1;
    
    %Convert structure to arrays
    nSamples = size(data.(recordingMode)(recId).LfpData, 1);
    TicksInMs = NaN(nSamples, 1);
    mA = NaN(nSamples, nChannels);
    for sampleId = 1:nSamples
        TicksInMs(sampleId) = data.(recordingMode)(recId).LfpData(sampleId).TicksInMs;
        mA(sampleId, 1) = data.(recordingMode)(recId).LfpData(sampleId).Left.mA;
        mA(sampleId, 2) = data.(recordingMode)(recId).LfpData(sampleId).Right.mA;
    end
    
    %Make time start at 0 and convert to seconds
    TicksInS = (TicksInMs - TicksInMs(1))/1000;
    
    Fs = data.(recordingMode)(recId).SampleRateInHz;
    
    %Store stimulation amplitude in one structure
    all_stimAmp(recId).data = mA;
    all_stimAmp(recId).time = TicksInS;
    all_stimAmp(recId).Fs = Fs;
    all_stimAmp(recId).xlabel = 'Time (s)';
    all_stimAmp(recId).ylabel = 'Stimulation amplitude (mA)';
    all_stimAmp(recId).channel_names = {'Left', 'Right'};
    all_stimAmp(recId).firstTickInSec = TicksInMs(1)/1000; %first tick time (s)
    all_stimAmp(recId).json = params.fname;
    all_stimAmp(recId).recordingMode = recordingMode;
    all_stimAmp(recId).recording = regexprep(char(recNames(recId)), {':', '-'}, {''});
    
    %Plot stimulation amplitude
%     figure; plot(stimAmp.time, stimAmp.data, 'Linewidth', 2'); xlabel('Time (s)'); ylabel(stimAmp.ylabel); legend(stimAmp.channel_names); xlim([stimAmp.time(1) stimAmp.time(end)])
    
%     %save
%     savename = append(regexprep(params.ptID,' ','_'),'_',stimAmp.recording(1:end-5),'_stimAmp.mat');
%     save([params.data_pathname filesep savename],'stimAmp')
%     disp([savename ' saved'])
    
end
end