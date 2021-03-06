%% Calculate spike time histogram (STM) data

function [STM] = calculateSTM(allSpikes, params)

    % Initialise STM store
    STM = {};
    
    % Loop over trials
    for currentTrial = 1:params.numberOfTrials
            
        % Loop over areas
        for currentArea = 1:2

            % Get current data
            data = allSpikes{currentTrial}{currentArea};

            % Loop over spikes
            for t = 1:params.simulationLength
                currentIndices = find(data(:,1)==t);
                if not(isempty(currentIndices))
                    excitatorySpikes = find(data(currentIndices,2)<=400);
                    inhibitorySpikes = find(data(currentIndices,2)>400);
                    STM{currentTrial}.excitatory(currentArea, t) = length(excitatorySpikes);
                    STM{currentTrial}.inhibitory(currentArea, t) = -length(inhibitorySpikes);
                end
            end
            
        end
        
        % Cut the end off STM
        STM{currentTrial}.excitatory = STM{currentTrial}.excitatory(:, 1:end-params.windowToRemove);
        STM{currentTrial}.inhibitory = STM{currentTrial}.inhibitory(:, 1:end-params.windowToRemove);
        
    end

end

