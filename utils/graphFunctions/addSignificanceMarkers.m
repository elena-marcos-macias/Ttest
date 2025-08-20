function addSignificanceMarkers(p_variance, mean_RegionGroup, sd_RegionGroup, graphBar)
% addSignificanceMarkers - Adds significance asterisks and lines to bar plots
%
% Prerequistes:
%   To have a bar graph and have used the functions variance1f_analysis and
%   compute_descriptives.
% 
% Inputs:
%   p_variance         - Vector of p-values per region (1 x nRegions)
%   mean_RegionGroup   - Matrix of means (nGroup x nRegions)
%   sd_RegionGroup     - Matrix of standard deviations (nGroup x nRegions)
%   graphBar           - Array of bar objects (output of bar(...))

nRegions = size(mean_RegionGroup, 2);
nGroup = size(mean_RegionGroup, 1);

for r = 1:nRegions
    if p_variance(r) < 0.05
        % Compute Y position
        maxY = max(mean_RegionGroup(:, r) + sd_RegionGroup(:, r));
        yStar = maxY + 0.13 * maxY;

        % Compute centered X position
        xPos = mean(arrayfun(@(g) graphBar(g).XEndPoints(r), 1:nGroup));

        % Asterisk text
        if p_variance(r) < 0.01
            text(xPos, yStar, '**', 'FontSize', 30, ...
                'HorizontalAlignment', 'center', 'Color', 'k');
        else
            text(xPos, yStar, '*', 'FontSize', 30, ...
                'HorizontalAlignment', 'center', 'Color', 'k');
        end

        % Draw horizontal line just below the asterisk
        xLeft = graphBar(1).XEndPoints(r);
        xRight = graphBar(end).XEndPoints(r);
        yLine = maxY + 0.11 * maxY;
        plot([xLeft, xRight], [yLine, yLine], 'k-', 'LineWidth', 1.5);
    end
end
end