function [T_descriptives, Mean_RegionGroup, SD_RegionGroup] = compute_descriptives(Data, Group, Group_categories, Regions_unique, nRegions, nGroup)
%COMPUTE_DESCRIPTIVES Computes descriptive statistics by group and region.
%
%   [T, M, SD] = compute_descriptives(Data, Group, Group_categories, Regions_unique, nRegions, nGroup)
%   returns a table with count, mean, and standard deviation by group and region,
%   as well as matrices of mean and standard deviation per region and group.
%
% INPUTS:
%   Data             - Matrix (nSamples x nRegions)
%   Group            - Group vector (categorical, nSamples x 1)
%   Group_categories - Cell array of unique group names
%   Regions_unique   - Cell array of region names
%   nRegions         - Number of regions
%   nGroup           - Number of groups
%   outputFile       - (optional) name of Excel file to save results
%
% OUTPUTS:
%   T_descriptives   - Table with descriptive statistics
%   Mean_RegionGroup - Matrix (nGroup x nRegions) of group means per region
%   SD_RegionGroup   - Matrix (nGroup x nRegions) of group standard deviations per region

    % Initialize output matrices
    Mean_RegionGroup = zeros(nGroup, nRegions);
    SD_RegionGroup   = zeros(nGroup, nRegions);

    % Initialize table columns
    Region_col = {};
    Group_col = {};
    nData_g_r_col = [];
    Mean_col = [];
    SD_col = [];

    % Compute statistics per group and region
    for r = 1:nRegions
        RegionName = Regions_unique{r};
        for g = 1:nGroup
            GroupName = Group_categories(g);
            Data_g_r = Data(Group == GroupName, r);

            mean_val = mean(Data_g_r);
            std_val  = std(Data_g_r, 1); % STD with N-1 normalization

            Mean_RegionGroup(g, r) = mean_val;
            SD_RegionGroup(g, r)   = std_val;

            Region_col = [Region_col; RegionName];
            Group_col = [Group_col; GroupName];
            nData_g_r_col = [nData_g_r_col; numel(Data_g_r)];
            Mean_col = [Mean_col; mean_val];
            SD_col = [SD_col; std_val];
        end
    end

    % Create table
    T_descriptives = table(Region_col, Group_col, nData_g_r_col, Mean_col, SD_col, ...
        'VariableNames', {'Region', 'Group', 'N_Data', 'Mean', 'StdDev'});

end