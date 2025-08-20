function [T_VarianceAnalysis, p_values] = variance1f_analysis(Data, Group, ANOVA_friendly, Regions_unique)
% VARIANCE_ANALYSIS Performs ANOVA or Kruskal-Wallis tests per region.
%
% PREREQUISITES: It must be used after the function 'checkANOVA1f' whose output is 'ANOVA_friendly'
% 
% INPUTS:
%   Data            - Matrix (nSubjects x nRegions) with the data, each column is a region.
%   Group           - Vector of group labels (nSubjects x 1).
%   ANOVA_friendly  - Logical vector (1 x nRegions), 1 to use ANOVA, 0 for Kruskal-Wallis.
%   Regions_unique  - Cell array or string array with region names (1 x nRegions).
%
% OUTPUTS:
%   T_VarianceAnalysis - Summary table with the results of the analysis.
%   p_values           - Vector of p-values for each region.

    nRegions = size(Data, 2);

    % Initialize storage
    p_values = nan(1, nRegions);               % Vector of p-values
    significance = strings(1, nRegions);       % Significance markers: '**', '*', or 'ns'
    stat_values = nan(1, nRegions);            % F or Chi-squared values
    test_type = strings(1, nRegions);          % Record which test was used
    tbl_results = cell(1, nRegions);           % Store ANOVA or KW tables

    for r = 1:nRegions
        Data_region = Data(:, r);
        if ANOVA_friendly(r) == 1
            [p, tbl] = anova1(Data_region, Group, 'off');
            test_type(r) = 'ANOVA(F)';
            stats = tbl{2,5}; % F-statistic: row 2, column 5
        else
            [p, tbl] = kruskalwallis(Data_region, Group, 'off');
            test_type(r) = 'KW(H)';
            stats = tbl{2,5}; % Chi-squared: row 2, column 5
        end

        % Determine significance level
        if p < 0.01
            sig = '**';
        elseif p < 0.05
            sig = '*';
        else
            sig = 'ns';
        end

        % Store results
        p_values(r) = p;
        tbl_results{r} = tbl;
        stat_values(r) = stats;
        significance(r) = sig;
    end

    % Create summary table
    T_VarianceAnalysis = table(Regions_unique(:), test_type(:), stat_values(:), p_values(:), significance(:), ...
        'VariableNames', {'Region', 'Test_statistic', 'F_or_Chi2', 'P_Value', 'Significance'});

end
