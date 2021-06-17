function trendlogsFig = plotLFPTrendLogs(LFPTrendLogs, params,DateTime_events,EventID_events,data_events)
%Plot LFP band power and stimulation amplitude accross time from LFPTrendLogs
%Bart Keulen and Yohann Thenaisie 05.10.2020
%Modified by Tahisa Robles 25.05.2021
    %changed y-axis limits (changed upper limit from largest elemenet to
    %x*mode based on patient data ) 
    
    %added if statement to enable plotting measurements of a single
    %hemisphere 
    
    %script for plotting marked events 

trendlogsFig = figure();
ax = gobjects(LFPTrendLogs.nChannels, 1);
if LFPTrendLogs.nChannels == 2 
    for chId = 1:LFPTrendLogs.nChannels

        ax(chId) = subplot(LFPTrendLogs.nChannels,1,chId);
        title(regexprep(LFPTrendLogs.channel_names{chId},'_','-'))


        % Plot LFPTrendLogs
        yyaxis left; 
        plot(LFPTrendLogs.time,LFPTrendLogs.LFP(:,chId)); 
%         ylabel(LFPTrendLogs.ylabel(1)); ylim([min(LFPTrendLogs.LFP,[],'all'),max(LFPTrendLogs.LFP,[],'all')])
        ylabel(LFPTrendLogs.ylabel(1)); ylim([min(LFPTrendLogs.LFP,[],'all'),(35*mode (LFPTrendLogs.LFP(:,chId)))])
       
        % Plot stimulation amplitude
        yyaxis right; 
        plot(LFPTrendLogs.time,LFPTrendLogs.stimAmp(:,chId)); 
        ylabel(LFPTrendLogs.ylabel(2)); ylim([min(LFPTrendLogs.LFP,[],'all'),(100*mode (LFPTrendLogs.LFP(:,chId)))])
    
        xlabel(LFPTrendLogs.xlabel);
        
        linkaxes(ax, 'xy')
        xlim([min(LFPTrendLogs.time) max(LFPTrendLogs.time)])

       
        
%plotting marked events 
hold on 
ymin=min(LFPTrendLogs.LFP,[],'all');
Legend = cell(2,1); 
for i=1:(size(data_events, 1))
    if EventID_events(:,i) == 1 
        Time=(datetime(DateTime_events{i,:},'InputFormat','yyyy-MM-dd''T''HH:mm:ssZ','TimeZone','Europe/London'));
        Time.TimeZone=''; 
        plot (Time,ymin,'rd')
        a=annotation('textbox',[0.2 0.75 0.1 0.01],'String','off');
        a.Color='red';
        a.EdgeColor='none';
    elseif EventID_events(:,i) == 2
        Time=(datetime(DateTime_events{i,:},'InputFormat','yyyy-MM-dd''T''HH:mm:ssZ','TimeZone','Europe/London'));
        Time.TimeZone=''; 
        plot (Time,ymin,'kd') 
        a=annotation('textbox',[0.2 0.73 0.1 0.01],'String','overbeweegelijkheid');
        a.Color='black';
        a.EdgeColor='none';
    end 
end 

 sgtitle({'LFPTrendLogs', regexprep(LFPTrendLogs.json(1:end-5),'_',' ')})
        savename = append(regexprep(params.ptID,' ','_'),'_',LFPTrendLogs.json(end-19:end-5),'_LFPTrendLogs.',params.format);
        saveas(trendlogsFig,[params.data_pathname filesep savename],params.format)
        disp([savename ' saved'])
    
% ----------------------------------------------------------------------------------------
% Code of previous Technical Medicine intern 
%     if isfield(LFPTrendLogs, 'events')
%         hold on
%         
%         %discard events that have been marked out of the LFP recording period
%         events = LFPTrendLogs.events(LFPTrendLogs.events.DateTime > LFPTrendLogs.time(1) & LFPTrendLogs.events.DateTime < LFPTrendLogs.time(end), :);
%         
%         %Plot all events of each type at once
%         eventIDs = unique(events.EventID);
%         nEventIDs = size(eventIDs, 1);
%         colors = lines(nEventIDs);
%         for eventId = 1:nEventIDs
%             plot(events.DateTime(events.EventID == eventIDs(eventId)), 0, '*', 'Color', colors(eventId, :));
%         end
%         
%         %Plot legend for events - to be worked on
%         lgd = legend(unique(events.EventName));
%         title(lgd,'Events');
%     end
% -----------------------------------------------------------------------------------------------
     
    end

elseif LFPTrendLogs.nChannels == 1 
     title(regexprep(LFPTrendLogs.channel_names,'_','-'))
     % Plot LFPTrendLogs
        yyaxis left; 
        plot(LFPTrendLogs.time,LFPTrendLogs.LFP); 
        ylabel(LFPTrendLogs.ylabel); ylim([min(LFPTrendLogs.LFP,[],'all'),max(LFPTrendLogs.LFP,[],'all')])

        % Plot stimulation amplitude
        yyaxis right; 
        plot(LFPTrendLogs.time,LFPTrendLogs.stimAmp); 
        ylabel(LFPTrendLogs.ylabel(2)); ylim([0 5])
else 
end 

end
