function spectroFig = plotSpectrogram(data, LFP, params, stimAmp)
%Computes and plot standard spectrogram for each channnel
%'channelParams' is a structure with '.nChannels' and '.channel_map' and
%'.channel_names' fields
%Yohann Thenaisie 05.11.2018
%Modified by Bart Keulen 13.10.2020
%Modifiedby Bart Formsma 10.02.2021
    % Replaced subplot with tiledlayout
    % Added stimulation amplitude next to the spectrograms
%Modified by Tahisa Robles

%Spectrogram parameters
windowSize = LFP.Fs/params.Fres_spect;
noverlap = windowSize*params.overlap_spect;
spectroFig = figure();
[nColumns, nRows] = size(LFP.channel_map);


tiledlayout(nRows*2,nColumns);

for chId = 1:LFP.nChannels
    nexttile
    [~, f, t, p] = spectrogram(data(:, chId), hamming(windowSize), noverlap, 1:params.Fres_spect:params.Fc, LFP.Fs, 'yaxis');
   
    if params.normalize_spect == 1
        power2plot = 10*log10(p./mean(p, 2));
    else
        power2plot = 10*log10(p);
    end
    
    imagesc(t, f, power2plot)
    ax_temp = gca;
    ax_temp.YDir = 'normal';
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    xlim([LFP.time(1) LFP.time(end)])
    ylim([1 params.Fc])          
    c = colorbar;
    c.Label.String = 'Power/Frequency (dB/Hz)';
    grid on
    cmax = max(quantile(power2plot, 0.9));
    cmin = min(quantile(power2plot, 0.1));
    caxis([cmin cmax])
    LFP.channel_names={'ZERO_THREE_LEFT','EIGHT_ELEVEN_RIGHT'};
    title(regexprep(LFP.channel_names{chId},'_','-'))
%     title ('ZERO-THREE LEFT','EIGHT-ELEVEN RIGHT');
    
    powerData.time(chId,:) = t;
    powerData.frequencies(chId,:) = f;
    powerData.PSD(chId,:,:) = p;
    
    %BF plot stimulation amplitude per channel for each spectogram
    nexttile
    plot(stimAmp.time(3:1/params.Fres_spect:end),stimAmp.data(3:1/params.Fres_spect:end,chId),'--r','LineWidth',1.5)
    ylabel(stimAmp.ylabel); 
    xlabel(stimAmp.xlabel)
    ylim([0 5])
    grid on
end



%Set figure title and save as .fig
% sgtitle({regexprep(LFP.json(1:end-5),'_',' ');[LFP.recordingMode,' - Recording: ',LFP.recording(1:end-5)]})
savename = append(regexprep(LFP.ptID,' ','_'),'_',LFP.recording(1:end-5),'_spectrogram_report.',params.format);
saveas(spectroFig,[params.data_pathname filesep savename],params.format)
disp([savename ' saved'])

% Calculate and plot band power
plotBandpower(powerData, LFP, stimAmp, params);

end
