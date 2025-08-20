function overlayIndividualDeathPoints(data, group, group_categories, ...
                                     graphBar, nGroup, nRegions, ...
                                     lineColorMatrix, jsonFilePath, deathVector)
% OVERLAYINDIVIDUALDEATHPOINTS overlays individual data points (e.g., deaths)
% onto an existing bar graph, with markers styled by group and status.

% Generate custom marker shapes and fill styles from JSON file
[markerShapeMatrix, filledStatusLogical] = generateIndividualMarkers(jsonFilePath);

hold on  % Keep existing plot active for overlaying scatter points

% Loop through each group (e.g., age group, experimental condition)
for g = 1:nGroup
    % Logical indexing for current group
    isInGroup = group == group_categories{g};
    
    % Subset data and death status for current group
    data_group = data(isInGroup, :);
    death_group = deathVector(isInGroup);
    
    % Loop through each region (e.g., time point or category on x-axis)
    for r = 1:nRegions
        % Get x-axis position from associated bar chart
        xPos = graphBar(g).XEndPoints(r);
        
        % Extract y-values (e.g., measurement values) for current region
        yVals = data_group(:, r);
        
        % Retrieve marker shape for current group
        marker = markerShapeMatrix{g};
        
        % Logical indices for individuals who died or survived
        idxDeath = death_group;
        idxNoDeath = ~death_group;
        
        % Plot individuals who died in red
        if any(idxDeath)
            scatter(repmat(xPos, sum(idxDeath), 1), yVals(idxDeath), 30, ...
                'Marker', marker, ...
                'MarkerEdgeColor', [1 0 0], ...      % Red outline
                'MarkerFaceColor', [1 0 0], ...      % Red fill
                'LineWidth', 1, ...
                'jitter', 'on', 'jitterAmount', 0.10);  % Add horizontal jitter
        end
        
        % Plot individuals who survived with group-specific colors and fill
        if any(idxNoDeath)
            if filledStatusLogical(g)
                % Filled markers for this group
                scatter(repmat(xPos, sum(idxNoDeath), 1), yVals(idxNoDeath), 30, ...
                    'Marker', marker, ...
                    'MarkerEdgeColor', lineColorMatrix(g,:), ...
                    'MarkerFaceColor', lineColorMatrix(g,:), ...
                    'LineWidth', 1, ...
                    'jitter', 'on', 'jitterAmount', 0.10);
            else
                % Unfilled markers for this group
                scatter(repmat(xPos, sum(idxNoDeath), 1), yVals(idxNoDeath), 30, ...
                    'Marker', marker, ...
                    'MarkerEdgeColor', lineColorMatrix(g,:), ...
                    'MarkerFaceColor', 'none', ...
                    'LineWidth', 1, ...
                    'jitter', 'on', 'jitterAmount', 0.10);
            end
        end
    end
end

hold off  % Release plot hold
end