clear all; close all; clc;

%% Stimulation parameters

% Stimulation length
simulationLength = 1000;
windowToRemove = 50; % The first few milliseconds are quite unsettled
simulationLength = simulationLength + windowToRemove;
timePoints = linspace(1, simulationLength, simulationLength);

% Oscillator parameters
phaseShift = 50;
alphaAmplitude = 2;

% Plot parameters
fontSize = 14;


%% Create network objects

% Create NeuralAreas
area1 = NeuralArea();
area2 = NeuralArea();

% Create Oscillators

oscillator1 = Oscillator(0, alphaAmplitude);
oscillator2 = Oscillator(phaseShift, alphaAmplitude);

%% Simulation loop
for t = timePoints
    if mod(t,100)==0
        disp(['Simulating time point ' num2str(t)])
    end
    
    % Update oscillators
    oscillator1.update(t)
    oscillator2.update(t)
    
    % Update neural areas
    area1.update(t, oscillator1.currentVoltage, area2)
    area2.update(t, oscillator2.currentVoltage, area1)
    
end

%% Remove opening window from sample
area1.firings(find(area1.firings(:,1)<=windowToRemove),:) = [];
area2.firings(find(area2.firings(:,1)<=windowToRemove),:) = [];
area1.firings(:,1) = area1.firings(:,1) - windowToRemove;
area2.firings(:,1) = area2.firings(:,1) - windowToRemove;


%% Plot rastergram of excitatory (red) and inhibitory (blue) neurons in one population during an interval of 1000 ms.
hFig = figure(1); hold on;
set(hFig, 'Position', [10 10 600 500]) 
excitatorySpikes1 = find(area1.firings(:,2)<=area1.n_regularSpiking);
inhibitorySpikes1 = find(area1.firings(:,2)>area1.n_regularSpiking);
excitatorySpikes2 = find(area2.firings(:,2)<=area2.n_regularSpiking);
inhibitorySpikes2 = find(area2.firings(:,2)>area2.n_regularSpiking);
plot(area1.firings(excitatorySpikes1,1), area1.firings(excitatorySpikes1,2), '.', 'Color', 'r');
plot(area1.firings(inhibitorySpikes1,1), area1.firings(inhibitorySpikes1,2), '.', 'Color', [0 .2 .7]);
ylabel('Neuron #')
xlabel('Time (ms)') 
set(gca,'FontSize', fontSize)
% subplot(2,1,2); hold on;
% plot(area2.firings(excitatorySpikes2,1), area2.firings(excitatorySpikes2,2), '.', 'Color', 'r');
% plot(area2.firings(inhibitorySpikes2,1), area2.firings(inhibitorySpikes2,2), '.', 'Color', [0 .2 .7]);
% set(gca,'FontSize', fontSize)

%% Calcualte and plot spike Time Histogram (STM)
STM = {};
areaData = {area1; area2};
red = [1 .2 0]; blue = [0 .2 1];
hFig = figure(2); hold on;
set(hFig, 'Position', [10 10 600 500]) 
for a = 1
    for t = 1:simulationLength
        currentIndices = find(areaData{a}.firings(:,1)==t);
        if not(isempty(currentIndices))
            excitatorySpikes = find(areaData{a}.firings(currentIndices,2)<=400);
            inhibitorySpikes = find(areaData{a}.firings(currentIndices,2)>400);
            STM{a}{1}(t) = length(excitatorySpikes);
            STM{a}{2}(t) = -length(inhibitorySpikes);
        end
    end
    
    % Plot
    smoothing = 10;
    % subplot(2,1,a); hold on;
    area(smooth(STM{a}{1}, smoothing), 'FaceColor', red, 'LineStyle', 'none');
    area(smooth(STM{a}{2}, smoothing), 'FaceColor', blue, 'LineStyle', 'none');
    plot([0 1000], [0 0], 'Color', [0 0 0], 'LineWidth', 1)
    ylabel('# Neurons firing')
    xlabel('Time (ms)') 
    set(gca,'FontSize', fontSize)
    ylim([-7 10])
end


%% Plot oscillators
% figure(1); hold on
% plot(oscillator1.timeseries)
% plot(oscillator2.timeseries)




