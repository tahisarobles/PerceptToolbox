% Yohann Thenaisie 02.09.2020
% Modified by Bart Keulen 13.10.2020
% Modified by Bart Formsma 02.02.2021
% Modified by Tahisa Robles 03.06.2021

% Matlab script for analyses of JSON files retrieved from the Medtronic
% Percept (A DBS stimulator with the ability to perform measurements)

ptID = 'NL3_JA'; % Anonymous reference to patient
addpath(genpath('CC:\Users\tahis\Documents\Technical Medicine\Internship 3\MATLAB')) % Directory of toolbox
data_pathname = append('C:\Users\tahis\Documents\Technical Medicine\Internship 3\MATLAB',filesep, ptID); % Directory for files
cd(data_pathname)

filenames = ls('*.json'); 
nFiles = size(filenames, 1);

% Set figure format
params.format = 'fig'; % Format to save figures in (default = 'fig')

% Set minimum duration for recordings
minDuration_IS = 5; % IndefiniteStreaming (default = 5 seconds)
minDuration_BSTD = 20; % BrainSenseTimeDomain (default = 20 seconds)
minDuration_SCT = 5; % SenseChannelTests (default = 5 seconds)

% Settings of low-pass filter
params.butter_deg = 3; % Degree of butterworth filter (default = 3)
params.Fc = 100; % Cut-off frequency (default = 100 Hz)

% Settings of spectrogram
params.Fres_spect = 0.1 ; % Frequency resolution (default = 0.5 Hz)
params.overlap_spect = 0.5; % Relative overlap between segments (default = 0.5)
params.normalize_spect = 0; % Normalization of power, 0 or 1 (default = 0)

% Settings of Welch
params.Fres_welch = 0.25; % Frequency resolution (default = 0.25 Hz)
params.overlap_welch = 0.5; % Relative overlap between segments (default = 0.5)
params.scale_welch = 'linear'; % Display scale, linear or log (default = linear)

% Settings of bandpower
params.scale_bandpower = 'linear'; % Display scale, linear or log (default = linear)
params.freqRanges = [8 13; 15 30; 60 90]; % Frequency bands to be calculated
params.freqNames = {'alpha (8-13Hz)'; 'beta (15-30Hz)'; 'FTG (60-90Hz)'}; % Names of frequency bands

% Generate pdf report with results. Note: MATLAB Report Generator Toolbox
% is necessary to run this part of the code 
import mlreportgen.report.* 
import mlreportgen.dom.*

% rpt = Report('01 Percept Toolbox Results','pdf'); 
name_rpt= convertCharsToStrings(filename_anonymous);
rpt = Report (name_rpt,'pdf');

if strcmpi(rpt.Type,"pdf")
    pageLayoutObj = PDFPageLayout;
else
    pageLayoutObj = DOCXPageLayout;
end
pageLayoutObj.PageMargins.Top = "0.5in";
pageLayoutObj.PageMargins.Bottom = "0.5in";
pageLayoutObj.PageMargins.Left = "0.3in";
pageLayoutObj.PageMargins.Right = "0.3in";
pageLayoutObj.PageMargins.Header = "0.3in";
pageLayoutObj.PageMargins.Footer = "0.3in";
add(rpt,pageLayoutObj);

tp = TitlePage; 
tp.Title = append ('Results Percept Toolbox for ',ptID); 
tp.Subtitle = append ('Automatically generated. For research purposes only.'); 
tp.Author = 'Haga Teaching Hospital'; 
append(rpt,tp);


for fileId = 1:nFiles
    
    close all;
    
    data = jsondecode(fileread(filenames(fileId, :)));
    params.fname = filenames(fileId, :);
    params.ptID = ptID;
    params.data_pathname = append(data_pathname,filesep,filenames(fileId, 1:end-5));
    mkdir(params.data_pathname)
    
    if isfield(data, 'IndefiniteStreaming')
        
        totalRec = size(data.IndefiniteStreaming,1);
        sizes = zeros(1,totalRec);
        fs = zeros(1,totalRec);
        for nRec = 1:totalRec
            sizes(nRec) = size(data.IndefiniteStreaming(nRec).TimeDomainData,1);
            fs(nRec) = data.IndefiniteStreaming(nRec).SampleRateInHz;
        end
        data.IndefiniteStreaming(sizes./fs < minDuration_IS) = [];
        
        if ~isempty(data.IndefiniteStreaming)
            params.recordingMode = 'IndefiniteStreaming';
            params.nChannels = 6;
            params.channel_map = [1 2 3 ; 4 5 6];

            extractLFP(data, params)
        end        
    end
    
    if isfield(data, 'BrainSenseTimeDomain')
        
        totalRec = size(data.BrainSenseTimeDomain,1);
        sizes = zeros(1,totalRec);
        fs = zeros(1,totalRec);
        for nRec = 1:totalRec
            sizes(nRec) = size(data.BrainSenseTimeDomain(nRec).TimeDomainData,1);
            fs(nRec) = data.BrainSenseTimeDomain(nRec).SampleRateInHz;
        end
        data.BrainSenseTimeDomain(sizes./fs < minDuration_BSTD) = [];
%         data.BrainSenseLfp(sizes./fs < minDuration_BSTD) = [];
        
        if ~isempty(data.BrainSenseTimeDomain)
            params.nChannels = 2;
            params.channel_map = 1:params.nChannels;

            params.recordingMode = 'BrainSenseLfp';
            all_stimAmp = extractStimAmp(data, params);
            params.recordingMode = 'BrainSenseTimeDomain';
            extractLFP(data, params, all_stimAmp)
        end
    end
    
    if isfield(data, 'SenseChannelTests')

        totalRec = size(data.SenseChannelTests,1);
        sizes = zeros(1,totalRec);
        fs = zeros(1,totalRec);
        for nRec = 1:totalRec
            sizes(nRec) = size(data.SenseChannelTests(nRec).TimeDomainData,1);
            fs(nRec) = data.SenseChannelTests(nRec).SampleRateInHz;
        end
        data.SenseChannelTests(sizes./fs < minDuration_SCT) = [];
        
        if ~isempty(data.SenseChannelTests)
            params.recordingMode = 'SenseChannelTests';
            params.nChannels = 6;
            params.channel_map = [1 2 3 ; 4 5 6];

            extractLFP(data, params)
        end
    end

    if isfield(data.DiagnosticData, 'LFPTrendLogs')
        
        params.recordingMode = 'LFPTrendLogs';
        extractTrendLogs(data, params) 
    end
    
    movefile(params.fname, params.data_pathname)
    
end

%Adding the figures to the report
%note: the for-end loop includes all figures that are open in the report, so will
%also include figures that have not been closed from other m files and will
%not include figures that are closed during the run time 

set(0,'DefaultFigureVisible','off'); % This prevents figures from opening multiple times during the loop 
h =  findobj('type','figure');
n = length(h);

for i=1:1:n
    fig = figure(figure(i));
    fig = mlreportgen.report.Figure();
    fig.Scaling = "custom";
        fig.Height = "8in";
        fig.Width = "7.5in";
%     centerFigure(fig,rpt);
    add (rpt,fig);
end 

set(0,'DefaultFigureVisible','on'); % Resets figure visibility for further edits 
close(rpt)
rptview(rpt)