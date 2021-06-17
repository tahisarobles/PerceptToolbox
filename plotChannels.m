function channelsFig = plotChannels(data, LFP, params, varargin)
%channelsFig = plotChannels(LFP.data, LFP)
%Plots data from each channel of LFP data in a subplot
%S is a structure with fields:
%.data, .time, .nChannels, .channel_names, .channel_map, .ylabel
%Yohann Thenaisie 26.10.2018
%Modified by Bart Keulen 15.10.2020
%Modified by Tahisa Robles 17.05.2021

if nargin > 3 && strcmpi(LFP.recordingMode,'BrainSenseTimeDomain')
    stimAmp = varargin{1};
end

channelsFig = figure();

ax = gobjects(LFP.nChannels, 1);
[nColumns, nRows] = size(LFP.channel_map);
for chId = 1:LFP.nChannels
    channel_pos = find(LFP.channel_map == chId);
    ax(chId) = subplot(nRows, nColumns, channel_pos);
    hold on
    
    % Plot LFP data
    plot(LFP.time, data(:, chId))
    xlabel('Time (s)')
    ylabel(LFP.ylabel)
%     LFP.channel_names={'ZERO_THREE_LEFT','EIGHT_ELEVEN_RIGHT'};
    title(regexprep(LFP.channel_names{chId},'_','-'))
%     title ('ZERO-THREE LEFT','EIGHT-ELEVEN RIGHT');
    grid on
    
    % Set axis limits
    minY = min(data,[],'all');
    maxY = max(data,[],'all');
    if minY ~= maxY
        ylim([minY maxY])
    end
    xlim([LFP.time(1) LFP.time(end)])
    
    % Plot stimulation amplitude if BrainSenseTimeDomain
    if exist('stimAmp','var')
        yyaxis right
        plot(stimAmp.time,stimAmp.data(:,chId),'--r','LineWidth',1.5)
        ylabel(stimAmp.ylabel); xlabel(stimAmp.xlabel)
        ylim([0 5])
        yyaxis left
    end
end

subplot(nRows, nColumns, LFP.nChannels-nColumns+1)
linkaxes(ax, 'xy')

% Set figure title and save as .fig
% sgtitle({regexprep(LFP.json(1:end-5),'_',' ');[LFP.recordingMode,' - Recording: ',LFP.recording(1:end-5)]})
savename = append(regexprep(LFP.ptID,' ','_'),'_',LFP.recording(1:end-5),'_channels_report.',params.format);
saveas(channelsFig,[params.data_pathname filesep savename],params.format)
% savefig([params.data_pathname filesep savename])
disp([savename ' saved'])

end