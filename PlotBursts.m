%%%%%%%%%%%%%%%%%
% data aquisition
%%%%%%%%%%%%%%%%%

% Retrieve burst information from the neuron spike train input file

% allBurst contains burst values for individual burst, including the 
% following burst properties: 1. burst duration, 2. # of spikes in the 
% burst, 3. firing rate within the burst, 4. inter-burst intervals


dest_dir = '../data/diestrus';
[DBurst, allDBurst]=bursts(dest_dir);

dest_dir = '../data/estrus';
[EBurst, allEBurst]=bursts(dest_dir);



%%%%%%%%%%%%%%%%%%%
% graphics
%%%%%%%%%%%%%%%%%%%


%duration
figure
SD = cdfplot(allDBurst(:,1));
set(SD,'Color','k','DisplayName','Diestrus/Burst');
hold on
SD = cdfplot(allEBurst(:,1));
set(SD,'Color','r','DisplayName','Estrus/Burst');
hold off
xlabel('Burst Duration (s)')
ylabel('Cumulative Probability Distribution')
legend('show')
xlim([0 30]);

% #ofspikeS
figure
SS = cdfplot(allDBurst(:,2));
set(SS,'Color','k','DisplayName','Diestrus/Burst');
hold on 
SS = cdfplot(allEBurst(:,2));
set(SS,'Color','r','DisplayName','Estrus/Burst');
hold off
xlabel('# of Spikes/Burst')
ylabel('Cumulative Probability Distribution')
legend('show')
xlim([0 100]);


% FR within burst
figure
SS = cdfplot(allDBurst(:,4));
set(SS,'Color','k','DisplayName','Diestrus/Burst');
hold on
SS = cdfplot(allEBurst(:,4));
set(SS,'Color','r','DisplayName','Estrus/Burst');
hold off
xlabel('Intraburst Firing Rate (Hz)')
ylabel('Cumulative Probability Distribution')
legend('show')
xlim([0 15]);


% distribution of interburst interval
figure
SS = cdfplot(allDBurst(:,8));
set(SS,'Color','k','DisplayName','Diestrus/Burst');
hold on
IND = cdfplot(allEBurst(:,8));
set(IND,'Color','r','DisplayName','Estrus/Burst');
hold off
xlabel('Inter Burst Interval (s)')
ylabel('Cumulative Probability Distribution')
legend('show')
xlim([0 100]);


%%%%%%%%%%%%%%%%%%%%%%%%
% Statistical Comparison
%%%%%%%%%%%%%%%%%%%%%%%%

%burst duration
[EDduration,EDdurationP] = kstest2(allDBurst(:,1), allEBurst(:,1));

%number of spikes per burst
[EDspike,EDspikeP] = kstest2(allDBurst(:,2), allEBurst(:,2));

%intraburst firing rate
[EDrate,EDrateP] = kstest2(allDBurst(:,4), allEBurst(:,4));

%interburst interval
[EDinterval,EDintervalP] = kstest2(allDBurst(:,8), allEBurst(:,8));


