function [T_Ttest, p_values] = indivGroups2_analysis(data, group, parametric_friendly, regions_unique)
% VARIANCE_ANALYSIS Performs ANOVA or Kruskal-Wallis tests per region.
%
% PREREQUISITES: It must be used after the function 'checkNormHom' whose output is 'parametric_friendly'
% 
% INPUTS:
%   data                    - Matrix (nSubjects x nRegions) with the data, each column is a region.
%   group                   - Vector of group labels (nSubjects x 1).
%   parametric_friendly     - Logical vector (1 x nRegions), 1 to use ANOVA, 0 for Kruskal-Wallis.
%   regions_unique          - Cell array or string array with region names (1 x nRegions).
%
% OUTPUTS:
%   T_Ttest            - Summary table with the results of the analysis.
%   p_values           - Vector of p-values for each region.

    
    group_categories = categories(group); %
    nGroup = numel(group_categories); % Gets the number of categories in the categorical variables (number of groups)
    nRegions = numel(regions_unique); % Gets the number of scalar variables (number of brain regions)

    % Initialize storage
    p_values = nan(1, nRegions);               % Vector of p-values
    significance = strings(1, nRegions);       % Significance markers: '**', '*', or 'ns'
    stat_values = nan(1, nRegions);            % T or Z values
    test_type = strings(1, nRegions);          % Record which test was used

    for r = 1:nRegions
        % Region name (if needed)
        % RegionName = regions_unique{r};
    
        % Initialize containers for the two groups
        matG1 = [];
        matG2 = [];
    
        for g = 1:nGroup
            groupName = group_categories(g);
    
            % Select data for this group and region
            data_g_r = data(group == groupName, r);
    
            % Store in correct matrix
            if g == 1
                matG1 = [matG1; data_g_r]; % append column
            elseif g == 2
                matG2 = [matG2; data_g_r];
            end
        end
    
        if parametric_friendly(r) == 1
            [~,p,~,tbl] = ttest2(matG1,matG2);
            test_type(r) = 'T-test(T)';
            stats = double(tbl.tstat); % T-statistic: is called tstat in the struct tbl
        else
            [p,~,tbl] = ranksum(matG1,matG2,'method','approximate');
            test_type(r) = 'Wilcoxon(Z)';
            stats = double(tbl.zval); % Z-statistic: is called zval in the struct tbl
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
        stat_values(r) = stats;
        significance(r) = sig;
       
    end
    
    % Create summary table
        T_Ttest = table(regions_unique(:), test_type(:), stat_values(:), p_values(:), significance(:), ...
            'VariableNames', {'Region', 'Test_statistic', 'T_or_Z', 'P_Value', 'Significance'});

end
