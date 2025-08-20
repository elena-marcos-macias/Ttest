function graphBar = plotBarWithStats(json, jsonFilePath, T_Original, T_Data, data, ...
                                     group, mean_RegionGroup, sd_RegionGroup, ...
                                     p_variance, nGroup, nRegions, savePath)
% PLOTBARWITHSTATS - Generates bar plots with error bars, significance markers and optionally overlay points.
%
% Output:
%   - graphBar: handle to the bar plot object (array of Bar objects, one per group)
%
% Inputs:
%   - json: struct parsed from JSON file with graph settings
%   - jsonFilePath: path to JSON config file
%   - T_Original: original data table (used for highlighting variable)
%   - T_Data: filtered table with selected variables
%   - data: numerical matrix (subjects x variables)
%   - group: categorical group labels
%   - mean_RegionGroup: (nGroup x nRegions) matrix of means
%   - sd_RegionGroup: (nGroup x nRegions) matrix of std deviations
%   - p_variance: vector of p-values per variable
%   - nGroup: number of groups
%   - nRegions: number of variables
%   - savePath: path to save the .fig and .png files

    % Reorder groups
    order = cellstr(string(json.inputDataSelection.groupOrder))';
    group = reordercats(group, order);
    group_categories = categories(group);

    % Load color configuration
    [fillColorMatrix, lineColorMatrix] = generateColorMatrices(jsonFilePath);

    % Create bar plot and return handle
    figure;
    graphBar = bar(mean_RegionGroup');  % <-- OUTPUT handle
    for g = 1:nGroup
        graphBar(g).FaceColor = fillColorMatrix(g,:);
        graphBar(g).EdgeColor = lineColorMatrix(g,:);
        graphBar(g).BarWidth = 0.85;
        graphBar(g).LineWidth = 1.5;
    end

    % Error bars
    hold on
    for g = 1:nGroup
        x = graphBar(g).XEndPoints;
        y = graphBar(g).YData;
        e = sd_RegionGroup(g,:);
        errorbar(x, y, e, 'k.', 'LineWidth', 1);
    end

    % Significance markers
    addSignificanceMarkers(p_variance, mean_RegionGroup, sd_RegionGroup, graphBar);

    % Overlay points
    if strcmpi(char(json.graphSpecifications.highlightVariable.showHighlightVariable), 'yes')
        highlightVariable = char(json.graphSpecifications.highlightVariable.highlightVariable);
        trueHighlight = char(json.graphSpecifications.highlightVariable.trueHighlightVariable);
        deathVector = strcmpi(T_Original.(highlightVariable), trueHighlight);
        overlayIndividualDeathPoints(data, group, group_categories, ...
                                     graphBar, nGroup, nRegions, ...
                                     lineColorMatrix, jsonFilePath, deathVector);
    else
        overlayIndividualDataPoints(data, group, group_categories, ...
                                     graphBar, nGroup, nRegions, ...
                                     lineColorMatrix, jsonFilePath);
    end

    % Labels and title
    title(char(json.graphSpecifications.graphTitle));
    legend(group_categories, 'Location', 'bestoutside');
    xticklabels(T_Data.Properties.VariableNames);
    xticks(1:nRegions);
    xlabel(char(json.graphSpecifications.xAxisLabel));
    ylabel(char(json.graphSpecifications.yAxisLabel));
    hold off

end