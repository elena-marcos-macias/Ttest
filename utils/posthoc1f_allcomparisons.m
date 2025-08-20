function T_posthoc_AllComparisons = posthoc1f_allcomparisons(Data, Group, Group_categories, ANOVA_friendly, Regions_unique)
% POSTHOC_ALLCOMPARISONS Performs post hoc comparisons per region.
% 
% PREREQUISITES: It must be used after the function 'checkANOVA1f' whose output is 'ANOVA_friendly'
% 
% INPUTS:
%   Data             - Matrix (nSamples x nRegions), each column is a region.
%   Group            - Group labels vector (nSamples x 1).
%   Group_categories - Cell array with the unique group names, ordered as in Group.
%   ANOVA_friendly   - Logical vector (1 x nRegions), 1 = use Tukey, 0 = use Dunn.
%   Regions_unique   - Cell or string array with names of the regions (1 x nRegions).
%
% OUTPUT:
%   T_posthoc_AllComparisons - Table with pairwise post hoc comparisons and significance.

    nRegions = size(Data, 2);
    nGroup = numel(Group_categories);

    posthoc_AllComparisons = {};  % Initialize cell to store results

    for r = 1:nRegions
        Data_resima = Data(:, r);
        RegionName = Regions_unique{r};

        if ANOVA_friendly(r) == 1
            % Post hoc: Tukey-Kramer
            [~, ~, stats] = anova1(Data_resima, Group, 'off');
            result_multcompare = multcompare(stats, 'CType', 'tukey-kramer', 'Display', 'off');

            for row = 1:size(result_multcompare, 1)
                idx1 = result_multcompare(row, 1);
                idx2 = result_multcompare(row, 2);
                Group1_name = Group_categories(idx1);
                Group2_name = Group_categories(idx2);
                p_Tukey = result_multcompare(row, 6);

                posthoc_AllComparisons = [posthoc_AllComparisons; ...
                    {RegionName, Group1_name, Group2_name, 'Tukey', p_Tukey}];
            end

        else
            % Post hoc: Dunn-Bonferroni using ranksum
            numPairs = nchoosek(nGroup, 2);

            for i = 1:nGroup-1
                for j = i+1:nGroup
                    Data_i = Data_resima(Group == Group_categories(i));
                    Data_j = Data_resima(Group == Group_categories(j));
                    p_raw = ranksum(Data_i, Data_j);
                    p_Dunn = min(p_raw * numPairs, 1); % Bonferroni correction

                    posthoc_AllComparisons = [posthoc_AllComparisons; ...
                        {RegionName, Group_categories(i), Group_categories(j), 'Dunn-Bonferroni', p_Dunn}];
                end
            end
        end
    end

    % Convert to table
    T_posthoc_AllComparisons = cell2table(posthoc_AllComparisons, ...
        'VariableNames', {'Region', 'Group1', 'Group2', 'TestType', 'P_Value'});

    % Add significance column
    significance_labels = strings(height(T_posthoc_AllComparisons), 1);
    for i = 1:height(T_posthoc_AllComparisons)
        p = T_posthoc_AllComparisons.P_Value(i);
        if p < 0.01
            significance_labels(i) = "**";
        elseif p < 0.05
            significance_labels(i) = "*";
        else
            significance_labels(i) = "ns";
        end
    end
    T_posthoc_AllComparisons.Significance = significance_labels;

end