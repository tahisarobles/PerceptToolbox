function LFP = correct4MissingSamples(LFP, TicksInS, GlobalPacketSizes)
%Replace missing data by NaNs
%Yohann Thenaisie 02.09.2020

warning('Some samples were lost during this recording')

%Create time vector of all samples that should have been received theorically
time = TicksInS(1):1/LFP.Fs:TicksInS(end)+(GlobalPacketSizes(end)-1)/LFP.Fs;
time = round(time,3); %round to the ms

%Create logical vector indicating which samples have been received
isReceived = zeros(size(time, 2), 1);
nPackets = numel(GlobalPacketSizes);
for packetId = 1:nPackets
    [~, packetIdx] = min(abs(time - TicksInS(packetId)));
    isReceived(packetIdx:packetIdx+GlobalPacketSizes(packetId)-1) = isReceived(packetIdx:packetIdx+GlobalPacketSizes(packetId)-1)+1;
end
figure; plot(isReceived, '.'); yticks([0 1]); yticklabels({'not received', 'received'}); ylim([-1 10])

%Introduce NaN in data at the timepoints of discontinuities
data = NaN(size(time, 2), LFP.nChannels);
data(isReceived, :) = LFP.data;

LFP.data = data;
LFP.time = time;
