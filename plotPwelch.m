function welchFig = plotPwelch(data, LFP, params)
% function pwelchFig = plotPwelch(data, LFP, 'log')
%'log' converts PSD to dB
%Plot Pwelch (PSD along frequencies) for each channel
%Yohann Thenaisie 25.20.2018
%Modified by Bart Keulen 13.10.2020
%Modified by Bart Formsma 10.02.2021
    % Added a plot showing PSD's of one side together line 41-90
    % Zoomed in on single channel plots line 29-39
%Modified by Tahisa Robles 17.05.2021

%Compute pWelch
windowSize = LFP.Fs/params.Fres_welch;
noverlap = windowSize*params.overlap_welch;

[Pxx, F] = pwelch(data, hamming(windowSize), noverlap, 1:params.Fres_welch:params.Fc, LFP.Fs);

%log scale PSD and confidence interval
if nargin > 4 && strcmpi(LFP.scale_welch, 'log')
    Pxx = 10*log10(Pxx);
    LFP.ylabel = 'PSD (dB/Hz)';
else
    LFP.ylabel = 'PSD (V^2/Hz)';
end

welchFig = figure();
ax = gobjects(LFP.nChannels, 1);
[nColumns, nRows] = size(LFP.channel_map);
nRows= nRows + 1;
for chId = 1:LFP.nChannels
    channel_pos = find(LFP.channel_map == chId);
    ax(chId) = subplot(nRows, nColumns, channel_pos);
    hold on
    plot(F, Pxx(:, chId), 'LineWidth', 1)
    ylabel(LFP.ylabel)
    xlabel('Frequency (Hz)')
%     LFP.channel_names={'ZERO_THREE_LEFT','EIGHT_ELEVEN_RIGHT'};
    title(regexprep(LFP.channel_names{chId},'_','-'))
%     title ('ZERO-THREE LEFT','EIGHT-ELEVEN RIGHT');
    xlim([1 params.Fc./2.5])
    ylim([0 max(Pxx(:, chId))*1.1])                 % set ylim to maximum value per PSD plus 10 percent 
end

% BF
% If statement is made to make difference between measurements of one lead
% and measurement of two leads. Comments are placed for only the first part
% as for the other parts the same steps were repeated.

if nColumns == 2
    subplot(nRows,nColumns,(nRows*nColumns)-1);         % create location for plot
    hold on
    Legend = cell(length(nRows),1);                     % Create cell to put legend in
    for chId = 1:LFP.nChannels/2                        % Create loop which plots the lines of one side over eachother
        hold on
        plot(F, Pxx(:, chId), 'LineWidth', 1)             
        ylabel(LFP.ylabel)
        xlabel('Frequency (Hz)')
        hold on
        Legend{chId}=strcat(regexprep(LFP.channel_names{chId},'_','-'));        % fill Legend cell with names of lines plotted.
    end
    xlim([1 params.Fc/4])                         % Decrease the ylim to show more relevant parts of plots
    legend(Legend)                                      % plot legend in the figure
    title("PSD's of left hemipshere channels")
    hold off
    
    
    subplot(nRows,nColumns,(nRows*nColumns));
    Legend = cell(length(nRows),1);
    for chId = ((LFP.nChannels/2)+1):LFP.nChannels
        hold on
        plot(F, Pxx(:, chId), 'LineWidth', 1)
        ylabel(LFP.ylabel)
        xlabel('Frequency (Hz)')
        hold on
        Legend{chId}=strcat(regexprep(LFP.channel_names{chId},'_','-'));
    end
    xlim([1 params.Fc/4])                         % Decrease the ylim to show more relevant parts of plots
    legend(Legend(((LFP.nChannels/2)+1):LFP.nChannels));
    title("PSD's of right hemisphere channels ")
    
else
    subplot(nRows,nColumns,(nRows*nColumns)-1);
    hold on
    Legend = cell(length(nRows),1);
    for chId = 1:LFP.nChannels
        hold on
        plot(F, Pxx(:, chId), 'LineWidth', 1)
        ylabel(LFP.ylabel)
        xlabel('Frequency (Hz)')
        hold on
        Legend{chId}=strcat(regexprep(LFP.channel_names{chId},'_','-'));
    end
    xlim([1 params.Fc/4])                         % Decrease the ylim to show more relevant parts of plots
    legend(Legend)
    title("PSD's of channels plotted together")
end


%Set figure title and save as .fig
sgtitle({regexprep(LFP.json(1:end-5),'_',' ');[LFP.recordingMode,' - Recording: ',LFP.recording(1:end-5)]})
savename = append(regexprep(LFP.ptID,' ','_'),'_',LFP.recording(1:end-5),'_PSD.',params.format);
saveas(welchFig,[params.data_pathname filesep savename],params.format)
disp([savename ' saved'])

end
