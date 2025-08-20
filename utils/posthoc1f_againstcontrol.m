function [T_posthoc_vsControl1, T_posthoc_vsControl2] = posthoc1f_againstcontrol(Data, Group, Regions_unique, ANOVA_friendly, nRegions, nGroup, controlGroup1, controlGroup2)

%POSTHOC1F_AGAINSTCONTROL Performs post hoc comparisons against one or two control groups.
%
%   [T1, T2] = posthoc1f_againstcontrol(Data, Group, Regions_unique, ANOVA_friendly, nRegions, nGroup, controlGroup1)
%   performs post hoc comparisons vs controlGroup1 only.
%
%   [T1, T2] = posthoc1f_againstcontrol(..., controlGroup2)
%   additionally performs comparisons vs controlGroup2 if provided.
%
% INPUTS:
%   Data             - Matrix (nSamples x nRegions)
%   Group            - Group labels (categorical, nSamples x 1)
%   Regions_unique   - Cell array with region names (1 x nRegions)
%   ANOVA_friendly   - Logical vector (1 x nRegions)
%   nRegions         - Number of brain regions
%   nGroup           - Total number of groups
%   controlGroup1    - String, first control group
%   controlGroup2    - (Optional) String or empty. Second control group to compare. If omitted, no second comparison.
%
% OUTPUTS:
%   T_posthoc_vsControl1 - Table of comparisons vs controlGroup1
%   T_posthoc_vsControl2 - Table of comparisons vs controlGroup2 (empty if not used)


    % Comparisons against the first control group
    T_posthoc_vsControl1 = run_single_comparison(Data, Group, Regions_unique, ANOVA_friendly, nRegions, nGroup, controlGroup1);


    % Comparisons against the second control group, if provided
    if nargin < 8 || isempty(controlGroup2)
        T_posthoc_vsControl2 = [];
    else
        T_posthoc_vsControl2 = run_single_comparison(Data, Group, Regions_unique, ANOVA_friendly, nRegions, nGroup, controlGroup2);
    end
end

function T_posthoc = run_single_comparison(Data, Group, Regions_unique, ANOVA_friendly, nRegions, nGroup, controlGroup)
    % Reordenar grupos poniendo el control primero
    Group_categories = categories(Group);
    Group = reordercats(Group, [controlGroup; setdiff(Group_categories, controlGroup, 'stable')]);
    Group_categories = categories(Group);  % actualizar categorías tras reordenar

    posthoc_vsControl = {};

    for r = 1:nRegions
        RegionName = Regions_unique{r};
        Data_resima = Data(:, r);

        if ANOVA_friendly(r) == 1
            % ANOVA-friendly -> Dunnett
            [~, ~, stats] = anova1(Data_resima, Group, 'off');
            result_multcompare = multcompare(stats, 'CType', 'dunnett', 'Display', 'off');

            for row = 1:size(result_multcompare, 1)
                idx1 = result_multcompare(row, 1);
                idx2 = result_multcompare(row, 2);
                Group1_name = Group_categories{idx1};
                Group2_name = Group_categories{idx2};

                if strcmp(Group1_name, controlGroup) || strcmp(Group2_name, controlGroup)
                    p_dunnett = result_multcompare(row, 6);
                    posthoc_vsControl = [posthoc_vsControl; {RegionName, Group2_name, Group1_name, 'Dunnett', p_dunnett}];
                end
            end

        else
            % No ANOVA-friendly -> Dunn-Bonferroni
            control_data = Data_resima(Group == controlGroup);
            numComparisons = nGroup - 1;

            for g = 1:nGroup
                thisGroup = Group_categories{g};
                if strcmp(thisGroup, controlGroup)
                    continue;
                end
                other_data = Data_resima(Group == thisGroup);
                p_raw = ranksum(control_data, other_data);
                p_Dunn2 = min(p_raw * numComparisons, 1);

                posthoc_vsControl = [posthoc_vsControl; ...
                    {RegionName, controlGroup, thisGroup, 'Dunn-Bonferroni', p_Dunn2}];
            end
        end
    end

    % Convertir a tabla
    T_posthoc = cell2table(posthoc_vsControl, ...
        'VariableNames', {'Region', 'ControlGroup', 'Group2', 'TestType', 'P_Value'});

    % Añadir significancia
    significance_labels = strings(height(T_posthoc), 1);
    for i = 1:height(T_posthoc)
        p = T_posthoc.P_Value(i);
        if p < 0.01
            significance_labels(i) = "**";
        elseif p < 0.05
            significance_labels(i) = "*";
        else
            significance_labels(i) = "ns";
        end
    end
    T_posthoc.Significance = significance_labels;

end