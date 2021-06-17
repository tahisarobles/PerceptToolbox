function bandFig = plotBandpower(powerData, LFP, stimAmp, params)
% Bart Keulen 06.10.2020
% Modified by Tahisa Robles 17.05.2021

% Extract parameters
allTime = powerData.time;
allFreq = powerData.frequencies;
allPSD = powerData.PSD;

nBands = size(params.freqRanges,1);
maxPower = [];

bandFig = figure();
ax = gobjects(LFP.nChannels, 1);
[nColumns, nRows] = size(LFP.channel_map);
for chId = 1:LFP.nChannels
    channel_pos = find(LFP.channel_map == chId);
    ax(chId) = subplot(nRows, nColumns, channel_pos);
    
    time = allTime(chId,:);
    freq = allFreq(chId,:);
    PSD = squeeze(allPSD(chId,:,:));

    % Calculate and plot bandpower
    for freqId = 1:nBands
        [~,Imin] = find(freq==params.freqRanges(freqId,1));
        [~,Imax] = find(freq==params.freqRanges(freqId,2));
        colors = 'mgb';
        bandpower = sum(PSD(Imin:Imax,:),1);
        
        % Log scale PSD
        if nargin > 4 && strcmpi(params.scale_bandpower, 'log')
            bandpower = 10*log10(bandpower);
        end
        
        yyaxis left;
        plot(time,bandpower,append('-',colors(freqId))); hold on
        maxPower = max([maxPower, max(bandpower,[],'all')]);
    end

    % Set ylabel and limits
    if nargin > 4 && strcmpi(params.scale_bandpower, 'log')
        ylabel('Bandpower (dB)')
    else
        ylabel('Bandpower (V^2)')
    end
    ylim([0 maxPower])
    
    % Plot stimulation amplitude
    yyaxis right
    plot(stimAmp.time(3:1/params.Fres_spect:end),stimAmp.data(3:1/params.Fres_spect:end,chId),'--r','LineWidth',1.5)
    ylabel(stimAmp.ylabel); xlabel(stimAmp.xlabel)
    ylim([0 5])
    
    % Set x limits, title and legend
    xlim([time(1) time(end)])
    LFP.channel_names={'ZERO_THREE_LEFT','EIGHT_ELEVEN_RIGHT'};
    title(regexprep(LFP.channel_names{chId},'_','-'))
    legend([params.freqNames; 'Stimulation amplitude'],'Location','southoutside')
end

linkaxes(ax, 'xy')

% Set figure title and save as .fig
% sgtitle({regexprep(LFP.json(1:end-5),'_',' ');[LFP.recordingMode,' - Recording: ',LFP.recording(1:end-5)]})
savename = append(regexprep(LFP.ptID,' ','_'),'_',LFP.recording(1:end-5),'_bandpower_report.',params.format);
saveas(bandFig,[params.data_pathname filesep savename],params.format)
disp([savename ' saved'])

end
