% This file will find the bursts from the spike train based on the burst
% threshold.
% input data: stimes for spike train, cut for the criteria of isi for
% burst,i for the ID of the neuron


function [bursts] = findbursts(stimes, cut) 
    threshold = 10^cut;

    isi = diff(stimes);
    tmax = max(stimes);
    
    % identifyVector marks the isi >= threshold to be 1. The isi<threshould
    % will be mark as 0. Use the identifyVector and burstFlag to detect the
    % transition from 0 to 1 (end of a burst) and from 1 to 0 (begining of
    % a burst)
    identifyVector = isi>=threshold;
    burstFlag = diff(identifyVector);
    endFlag = find(burstFlag==1);
    endindex = 1+endFlag;
    startFlag = find(burstFlag==-1);
    startindex = 1+startFlag;
    
    % if the stime end up with a burst, the last endindex will not be
    % detected. Add the index of the last element in the stimes to be the
    % endindex of the last burst.
    if length(startindex) == length(endindex) + 1
        endindex = [endindex length(stimes)];
    end
    

    % organize the burst information to the output
    burststart = stimes(startindex).'/1000;
    burstend = stimes(endindex).'/1000;
    burstDuration = burstend - burststart;
    numofSpikes = endindex.'-startindex.'+1;
    BurstsRate = ones(size(burstDuration,1),1)*60*size(burstDuration,1)/(tmax/1000.); %return the number of burst/min
    FRinBurst = numofSpikes./burstDuration;
    ISIthreshold = ones(size(burstDuration,1),1)*threshold*0.001;
    bursts = [burstDuration numofSpikes BurstsRate FRinBurst ISIthreshold burststart burstend];
   
    % Current burst data may contain some detected burst showing spikes
    % less than 3.
    % delete the burst with action potentials number less than 3 
    nonbursts = find(bursts(:,2)<=3);
    bursts(nonbursts,:) = [];
 

    
    % getting interburst intervals
    if size(bursts,1)>=2
        bursts(1,8) = bursts(1,6);
        for i = 2: 1: size(bursts,1)
            bursts(i,8) = bursts(i,6) - bursts(i-1,6);
        end
    else 
        bursts(1,8) = 60*60*1000;
    end

   % randomly select 100 bursts for statistical analysis
   % if the number of burst is smaller than 100, use all the bursts for
   % analysis
    if size(bursts,1) >= 100
        %random sample 100 bursts for analysis
        bursts = datasample(bursts,100);
    end

end
