function Parametric_friendly = checkNormHom(Data, Group, Group_categories)
% CHECKANOVA1F Verifies the normality per group and the homogeneity per region.
%
% PREREQUISITES: MATLAB must have access to the file 'swtest.m' which is
% not native to MATLAB but can be downloaded from
% 'https://www.mathworks.com/matlabcentral/fileexchange/13964-shapiro-wilk-and-shapiro-francia-normality-tests'
% 
% INPUTS:
%   - Data: numerical array (nSubjects x nRegions; Subjects in rows and Regions in columns; Subjects must be grouped by some categorical variable)
%   - Group: group vector (categorical variable)
%   - Group_categories: cell with the individual name for each group
%
% OUTPUT:
%   ANOVA_friendly      - logical array that idicates if the assumptions of the ANOVA (normality and homogeneity) are true for each region.
% 

nRegions = size(Data, 2);
nGroup = length(Group_categories);
Parametric_friendly = zeros(1, nRegions);

for r = 1:nRegions
    allGroupsNormal = true;

    for g = 1:nGroup % The normality test is per region and per group
        Data_group = Data(Group == Group_categories(g), r);
        [h, ~] = swtest(Data_group, 0.05);
        if h == 1 % H0 = the data follow a normal distribution; h = 1 discards the H0
            allGroupsNormal = false;
            break;
        end
    end

    Data_region = Data(:, r); % the homogeneity test is only per region
    p_levene = vartestn(Data_region, Group, 'TestType', 'LeveneAbsolute', 'Display', 'off');
    isHomogeneous = p_levene > 0.05; % the H0 (non comparable distributions) cannot be discarded with enough confidence

    Parametric_friendly(r) = allGroupsNormal && isHomogeneous;
end
end