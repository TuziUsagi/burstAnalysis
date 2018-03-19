
function [burstInfo, allBursts] = bursts(dest_dir)
    % This function will return burst information from input neuron spike train
    
    % burstInfo contains information for evaluating
    % the morphology of the ISI joint scatter plot for identifying if the
    % neuron shows bursting pattern.
    
    % allBursts contains all the individual burst, can be used for
    % statistical comparison of burst properties.
    
    % This code will also generate the following graphs
    % spike train plot(plot [1:2])
    % ISI histogram with 1 second bin (plot [3] )
    % scatter plot of logISI(n) vs logISI(n+1) (plot [4])
    % graph of cluster distance vs short-long cutoff value (plot [5])
    % clutersing by optimal short-long cutoff criterion (plot [6])

    source_files = dir(fullfile(dest_dir, '*.mat'));
    
    BurstDuration = [];
    BurstSpike = [];
    BurstRate= [];
    FRinBursts = [];
    threshold = [];
    allBursts = [];
    neurons = [];
    difference =[];
    
    ratioSStoLS =[];
    ratioSStoLL =[];
    ratioSStoSL=[];
    rate = [];
    recTime =[];
    numofSpikes = [];
    noteCut =[];
    IBIs = [];


    for i = 1:length(source_files)
        
        disp('====================');
        i
        data = load(fullfile(dest_dir,source_files(i).name));
        name = source_files(i).name;
        name = name(1:7);


        stimes = data.stimes;
        stimes = stimes.';

        %note the firing rate for every neuron
        tmax = max(stimes);
        rate(i) = size(stimes,2)/(tmax/1000.);
        recTime(i) = tmax/(60*1000);
        spikes = size(stimes,2);
        numofSpikes(i)= spikes; 

        %potential noise may occure with the recording condition is not
        %ideal. Very rarely, extreme high firing rate burst will
        %occur,but the neuron are usually under bad condition. Those
        %signal may not reflect the real burst activity the neuron
        %shows. They are delected when: isi<50ms, the second spike
        %will be deleted.     
        isi = diff(stimes);
        invalidISI = find(isi<20);
        invalidSpikes =invalidISI+1;
        stimes(:, invalidSpikes) = [];
    


        tmax = max(stimes);
        isi = diff(stimes);
        nonISI = find(isi(1,:)<0);
        isi(nonISI) = [];
        log_isi = log10(isi);
        stimes(nonISI+1) = [];


        sdISI= std(isi);
        aveISI = mean(isi);
        cv(i) = sdISI/aveISI;
        meanISI(i) = aveISI/1000;
        stdISI(i) = std(isi/1000);
        rate(i) = size(stimes,2)/(tmax/1000.);
        neurons = [neurons; name];

          
            
        isi = isi/1000;
        ISIaxis1 = stimes(1:end-1);
        ISIaxis2 = stimes(2:end);
        ISIaxis = 0.001*(ISIaxis1+ISIaxis2)/2;

        % calc stats
        mean_logisi = mean(log_isi);
        std_logisi = std(log_isi);
        skew_logisi = skewness(log_isi);
        kurt_logisi = kurtosis(log_isi);


        fprintf(1,'nspikes = %d\n', size(stimes,2));
        fprintf(1,'rate = %.1f Hz\n', size(stimes,2)/(tmax/1000.));
            


                            

        %%%%%%%%%%%%%%%%%%%%%%%%
        % SHORT-LONG CLUSTERING
        %%%%%%%%%%%%%%%%%%%%%%%%

        % cutoff is the logisi value that separates short from long
        % list of cutoff values to test
        cutoffs = 0.05:0.05:10; 
        sumdsq = zeros(size(cutoffs)); % summed distance-squared

        log_isi = log_isi.';
        X = [log_isi(1:end-1) log_isi(2:end)];

        for j = 1:length(cutoffs)

            cut = cutoffs(j);

            XSS = X(X(:,1) <= cut & X(:,2) <= cut, :);
            deltaSS = XSS - repmat(mean(XSS),size(XSS,1),1);
            dsqSS = sum(deltaSS.*deltaSS, 2);

            XSL = X(X(:,1) <= cut & X(:,2) > cut, :);
            deltaSL = XSL - repmat(mean(XSL),size(XSL,1),1);
            dsqSL = sum(deltaSL.*deltaSL, 2);

            XLS = X(X(:,1) > cut & X(:,2) <= cut, :);
            deltaLS = XLS - repmat(mean(XLS),size(XLS,1),1);
            dsqLS = sum(deltaLS.*deltaLS, 2);

            XLL = X(X(:,1) > cut & X(:,2) > cut, :);
            deltaLL = XLL - repmat(mean(XLL),size(XLL,1),1);
            dsqLL = sum(deltaLL.*deltaLL, 2);

            sumdsq(j) = sum(dsqSS) + sum(dsqSL) + sum(dsqLS) + sum(dsqLL);

        end


            
        %find the optimal cutoff value
        cut = cutoffs(sumdsq == min(sumdsq));
        cut = cut(1); %pick the last cut if two or more cutoffs are equally best
        XSS = X(X(:,1) <= cut & X(:,2) <= cut, :);
        XSL = X(X(:,1) <= cut & X(:,2) > cut, :);
        XLS = X(X(:,1) > cut & X(:,2) <= cut, :);
        XLL = X(X(:,1) > cut & X(:,2) > cut, :);

        % note the cut for every neuron
        noteCut(i) = 0.001*(10^cut);


        %centroids
        cSS = mean(XSS);
        cSL = mean(XSL);
        cLS = mean(XLS);
        cLL = mean(XLL);

        % differece between the inter & intra burst spike interval
        difference(i) = 0.001*(10^(cLS(1)) - 10^(cSS(1)));


        %point number ratio between different clusters
        if size(XSS,1)>=1
            SStoLS = size(XSS,1)/size(XLS,1);
            SStoLL = size(XSS,1)/size(XLL,1);
            SStoSL = size(XSS,1)/size(XSL,1);
        else
            SStoLS = 0;
            SStoLL = 0;
            SStoSL = 0;
        end


        ratioSStoLS =[ratioSStoLS SStoLS];
        ratioSStoLL =[ratioSStoLL SStoLL];
        ratioSStoSL =[ratioSStoSL SStoSL];



        %%%%%%%%%%%
        %GRAPHICS
        %%%%%%%%%%
        figure
        %spike train
        subplot(3,2,[1:2])
        plot([stimes', stimes'] ./ 60000, [0, 1], 'k-');
        ylim([0, 1]);
        xlabel ('time (minutes)');
        title(source_files(i).name);

        subplot(3,2,3)
        bins = 1.0:0.1:6.0;
        hist(log_isi, bins);
        xlim([1,5]);
        str = sprintf('log isi (mean, std = %.2f, %.2f)', ...
            mean_logisi, ...
            std_logisi);
        xlabel(str)
        title('log isi')
        grid on

        subplot(3,2,4);
        plot(log_isi(1:end-1), log_isi(2:end), '.');
        xlabel('log isi (n)');
        ylabel('los isi (n+1)');
        axis square
        axis([1 5 1 5]);
        grid on;

        %plot summed dsq
        subplot(3,2,5);
        plot(cutoffs, sumdsq, '*-');
        xlabel('logisi cutoff');
        ylabel('summed dist-squared');
        grid on;            

        %plot clusters
        subplot(3,2,6)
        plot(XSS(:,1),XSS(:,2),'m.')
        hold on
        plot(XSL(:,1),XSL(:,2),'r.')
        plot(XLS(:,1),XLS(:,2),'g.')
        plot(XLL(:,1),XLL(:,2),'c.')

        % plot centroids
        plot(cSS(1), cSS(2),'ko');
        plot(cSL(1), cSL(2),'ko');
        plot(cLS(1), cLS(2),'ko');
        plot(cLL(1), cLL(2),'ko');

        title ('Cluster Assignments and Centroids');
        hold off
        axis square
        axis([1 5 1 5]);
        grid on


        %generate bursts and intervals for the spike data based on cut

        [bursts] = findbursts(stimes, cut);

        %give burst infomation for the spike data



        BurstDuration(i) = mean(bursts(:,1));
        BurstSpike(i) = mean(bursts(:,2));
        BurstRate(i) = mean(bursts(:,3));
        FRinBursts(i) = mean(bursts(:,4));
        threshold(i) = mean(bursts(:,5));

        allBursts = [allBursts; bursts];

    end
        
    burstInfo = [FRinBursts.' threshold.' difference.' ratioSStoLS.' ratioSStoLL.' ratioSStoSL.'];  
end