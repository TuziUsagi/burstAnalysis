% input data: stimes for spike train, cut for the criteria of isi for
% burst,i for the ID of the neuron


function [bursts] = findbursts(stimes, cut) %, burstPlot
    threshold = 10^cut;

    isi = diff(stimes);
    tmax = max(stimes);
    
    qualifiedISI = isi < threshold;
    ISIcluster1 = false(1,length(qualifiedISI));
    ISIcluster2 = false(1,length(qualifiedISI));
    ISIcluster1(1:end-1) = qualifiedISI(1:end-1) & qualifiedISI(2:end);
    ISIcluster2(2:end) = qualifiedISI(2:end) & qualifiedISI(1:end-1);
    index = [ISIcluster1 | ISIcluster2 false];
    startindex = [];
    endindex = [];
    prevvalue = false;
    for count = 1:length(index)
        if((~prevvalue) && index(count))
            startindex = [startindex count];
            prevvalue = true;
        end
        if(prevvalue && (~index(count)))
            endindex = [endindex count];
            prevvalue = false;
        end
    end

    
    burststart = stimes(startindex).'/1000;
    burstend = stimes(endindex).'/1000;
    burstDuration = burstend - burststart;
    numofSpikes = endindex.'-startindex.'+1;
    BurstsRate = ones(size(burstDuration,1),1)*60*size(burstDuration,1)/(tmax/1000.); %return the number of burst/min
    FRinBurst = numofSpikes./burstDuration;
    ISIthreshold = ones(size(burstDuration,1),1)*threshold*0.001;
    bursts = [burstDuration numofSpikes BurstsRate FRinBurst ISIthreshold burststart burstend];
   
    
    % delete the burst with action potentials number less than 3 
    nonbursts = find(bursts(:,2)<=3);
    bursts(nonbursts,:) = [];
    %few duration will be negative because of the issue of raw data, delete
    %those data
    nonbursts = find(bursts(:,1)<0);
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
    else
        bursts = bursts;
    end

end
