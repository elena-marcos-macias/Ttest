function overlayIndividualDataPoints(data, group, group_categories, ...
                                     graphBar, nGroup, nRegions, ...
                                     lineColorMatrix, jsonFilePath)
% overlayIndividualDataPoints - Overlays individual data points on bar graph.
%
% PREREQUISITES
% The function "generateIndividualMarkers" must be available. The "generateColorMatrices"
% function must be availabe and must have been used before in the script.
% 
% INPUTS:
%   data             - Numeric matrix of subject-level data (rows: subjects, columns: regions)
%   group            - Categorical or cell array specifying group assignment per subject
%   group_categories - Cell array with unique group names (must match order in plotting)
%   graphBar         - Bar graph object returned by bar()
%   nGroup           - Number of groups
%   nRegions         - Number of regions (columns in 'data')
%   lineColorMatrix  - nGroup x 3 matrix of RGB colors for marker edges/fills
%   jsonFilePath     - Path to JSON file with 'markerShape' and 'fillStatus' info

% Read marker shape and fill info
[markerShapeMatrix, filledStatusLogical] = generateIndividualMarkers(jsonFilePath);

% Overlay points for each group and region
for g = 1:nGroup
    % Extract individual data for group g
    isInGroup = group == group_categories{g};
    data_group = data(isInGroup, :);

    % For each region (column)
    for r = 1:nRegions
        xPos = graphBar(g).XEndPoints(r);
        yVals = data_group(:, r);
        marker = markerShapeMatrix{g};

        % Determine fill
        if filledStatusLogical(g)
            scatter(repmat(xPos, size(yVals)), yVals, 30, ...
                'Marker', marker, ...
                'MarkerEdgeColor', lineColorMatrix(g,:), ...
                'MarkerFaceColor', lineColorMatrix(g,:), ...
                'LineWidth', 1, ...
                'jitter', 'on', 'jitterAmount', 0.10);
        else
            scatter(repmat(xPos, size(yVals)), yVals, 30, ...
                'Marker', marker, ...
                'MarkerEdgeColor', lineColorMatrix(g,:), ...
                'MarkerFaceColor', 'none', ...
                'LineWidth', 1, ...
                'jitter', 'on', 'jitterAmount', 0.10);
        end
    end
end
end