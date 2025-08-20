% USE Ttest or non-parametric alternative. Compares the mean of two groups,
% per variable,but does not compare % across variables)
%
% INPUTS
%   - ArchiveName.xlsx      Excel archive in the same file where the program runs...
%                           each row must correspond to a subject,...
%                           there must be a categorical variable, e.g. "experimental group".
%
% OUTPUTS
%   - DescriptiveStatistics.xlsx        Excel archive containing Mean and Standard deviation per group and variable
%   - VarianceAnalysis.xlsx             Excel archive containing Statistics and p-value after the group comparisons per variable (ANOVA or Kruskal-Wallis)
%   - Posthoc_AllComparisons.xlsx       Excel archive containing p-value after the post hoc analysis for all possible comparisons (Tukey or Dunn-Bonferroni)
%   - Posthoc_vsControl1.xlsx           Excel archive containing p-value after the post hoc analysis for the comparisons against a control group (Dunnett or Dunn-Bonferroni)
%   - Posthoc_vsControl2.xlsx           (Optional) Excel archive equal to 'Posthoc_vsControl1' for a different control group (Dunnett or Dunn-Bonferroni)
%   - BarPlot.fig                       Bar plot that represents the mean and SD for each group, grouped per variable. It also marks with an '*' those comparisons that have a p-value < 0.05.


%--------- Add function path and set save path ----------
addpath(genpath('./data'));
addpath (genpath('./utils'));
addpath ('./requirements');
savePath = './results/';

% --------- Read instructions JSON archive -----------
json = readstruct("data/instructionsTtest.json");

%% LOAD DATA
fileName = char(json.inputDataSelection.fileName);
T_Original = rmmissing(readtable(['./data/' fileName])); % Load and Remove rows that contain at least one NaN

% === 1. SCALAR Variables ===
    T_Data = selectColumns (T_Original,...
        json.inputDataSelection.columnCriteria.target_columns, ...
        json.inputDataSelection.columnCriteria.ignore_columns);

    data = table2array(T_Data); % Create an array with the variables' info so that we can later operate with it

    regions_unique = T_Data.Properties.VariableNames; % Gets the names of all the scalar variables (in this case brain regions)
    nRegions = numel(regions_unique); % Gets the number of scalar variables (number of brain regions)


% === 2. CATEGORICAL Variables === 
% Categorical variable that is going to define the groups amongst which we
% are going to compare.
    catVariable = char(json.inputDataSelection.catVariable); % Identify categorical variable as such
    [group, group_categories, nGroup] = getCategoricalGroup(T_Original, catVariable);


% === 3. Prepare Excel file to save results === 
resultsFileName = [savePath char(json.outputFileNames.excelFileName)];

%% DESCRIPTIVE ANALYSIS

order = cellstr(string(json.inputDataSelection.groupOrder))';
group = reordercats(group, order); % Order in which groups should appear
group_categories = categories(group); % After reordering, refresh the group variable

% --------- Mean and standard deviation -----------------
[T_descriptives, mean_RegionGroup, sd_RegionGroup] = compute_descriptives(data, group, group_categories, regions_unique, nRegions, nGroup);
% Save results as .xlsx
writetable(T_descriptives, resultsFileName, 'Sheet', [char(json.outputFileNames.descriptiveStatistics)]);


%% T-TEST

order = cellstr(string(json.inputDataSelection.groupOrder))';
group = reordercats(group, order); % Order in which groups should appear
group_categories = categories(group); % After reordering, refresh the group variable

% ------------ Check normality and homogeneity ---------------
parametric_friendly = checkNormHom(data, group, group_categories);

%------------- THIS IS GOING TO BE A FUNCTION BUT I HAVE IT HERE FOR THE TIME BEING ---------------
% Initialize storage
    p_values = nan(1, nRegions);               % Vector of p-values
    significance = strings(1, nRegions);       % Significance markers: '**', '*', or 'ns'
    stat_values = nan(1, nRegions);            % T or WHICH IS NO PARAMETRICAL values
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
        stats = tbl{1,1}; % T-statistic: row 1, column 1
    else
        % No recuerdo cual es la no paramétrica
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

for r = 1:nRegions
    nG1 = numel()
    
    for s = 1:numel(group)
        if group(s) == group_categories{1}
            matG1(s) = data (s,r);
        else
            matG2(s) = data (s,r);
        end
    end
end


[T_VarianceAnalysis, p_variance] = variance1f_analysis(data, group, parametric_friendly, regions_unique);
% Save results as .xlsx
writetable(T_VarianceAnalysis, resultsFileName, 'Sheet', [char(json.outputFileNames.varianceAnalysis)]);

% ------------- Post-hoc - All comparisons (Tukey or Dunn-Bonferroni) -------
T_posthoc_AllComparisons = posthoc1f_allcomparisons(data, group, group_categories, parametric_friendly, regions_unique);
% Save results as .xlsx
writetable(T_posthoc_AllComparisons, resultsFileName, 'Sheet', [char(json.outputFileNames.posthoc_AllComparisons)]);

% ------------- Post-hoc - Comparisons against control (Dunnett or Dunn-Bonferroni vs. control) -------
controlGroup1 = char(json.inputDataSelection.groupControl.controlGroup1);
controlGroup2 = char(json.inputDataSelection.groupControl.controlGroup2);
[T_posthoc_vsControl1, T_posthoc_vsControl2] = posthoc1f_againstcontrol(data, group, regions_unique, parametric_friendly, nRegions, nGroup, controlGroup1, controlGroup2);
% Save results as .xlsx
writetable(T_posthoc_vsControl1, resultsFileName, 'Sheet', [char(json.outputFileNames.posthoc_vsControl1)]);
writetable(T_posthoc_vsControl2, resultsFileName, 'Sheet', [char(json.outputFileNames.posthoc_vsControl2)]);


%% --------------------- PLOT ----------------------------------
if strcmpi(char(json.wantGraph), 'yes')
    jsonFilePath = "data/instructionsANOVA1f.json";
    json = readstruct(jsonFilePath);
    
    graphBar = plotBarWithStats(json, jsonFilePath, T_Original, T_Data, data, ...
                                group, mean_RegionGroup, sd_RegionGroup, ...
                                p_variance, nGroup, nRegions, savePath);

    % Save results as .fig
    savefig(fullfile(savePath, json.outputFileNames.graphBar));
else
end

