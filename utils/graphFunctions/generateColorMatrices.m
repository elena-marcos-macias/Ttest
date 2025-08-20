function [fillColorMatrix, lineColorMatrix] = generateColorMatrices(jsonFilePath)
% generateColorMatrices - Extracts RGB fill and line color matrices from a JSON file.
%
% Syntax:
%   [fillColorMatrix, lineColorMatrix] = generateColorMatrices(jsonFilePath)
%
% Inputs:
%   jsonFilePath - Path to the JSON file containing the graph specifications.
%
% Outputs:
%   fillColorMatrix - Nx3 matrix with RGB values for fill colors.
%   lineColorMatrix - Nx3 matrix with RGB values for line colors.

% --------- Read instructions JSON archive -----------
json = readstruct(jsonFilePath);

% Define color mappings
colorMap = containers.Map;
colorMap("white") = [1 1 1];
colorMap("grayLight") = [0.8706 0.8706 0.8706];
colorMap("gray") = [0.71 0.71 0.71];
colorMap("grayDark1") = [0.5 0.5 0.5];
colorMap("grayDark2") = [0.4000 0.3647 0.3647];
colorMap("black") = [0 0 0];
colorMap("yellowLight2") = [0.9882 0.9882 0.5922];
colorMap("yellowLight1") = [0.9686 0.9294 0.3686];
colorMap("yellow") = [1.0000 0.9490 0.2196];
colorMap("yellowDark1") = [0.8784 0.8392 0.2549];
colorMap("yellowDark2") = [0.7882 0.6902 0.0549];
colorMap("purpleLight2") = [0.9216 0.7098 1.0000];
colorMap("purpleLight1") = [0.8745 0.4235 0.9020];
colorMap("purple") = [0.8078 0.3686 0.9686];
colorMap("purpleDark1") = [0.6902 0.1098 0.9020];
colorMap("purpleDark2") = [0.4196 0.0392 0.4392];
colorMap("blueLight2") = [0.8000 0.9294 0.9059];
colorMap("blueLight1") = [0.6314 0.9412 0.8824];
colorMap("blue") = [0.3569 0.9412 0.8314];
colorMap("blueDark1") = [0.1059 0.8196 0.6902];
colorMap("blueDark2") = [0.0549 0.6706 0.5569];

% List of possible group names
groupNames = ["Group1", "Group2", "Group3", "Group4", ...
              "Group5", "Group6", "Group7", "Group8"];

% Extract fill colors
fillColorMatrix = [];
for i = 1:length(groupNames)
    groupName = groupNames(i);
    if isfield(json.graphSpecifications, groupName)
        fillColor = json.graphSpecifications.(groupName).fillColor;
        if isKey(colorMap, fillColor)
            fillColorMatrix(end+1, :) = colorMap(fillColor);
        else
            warning("Color '%s' is not defined in the color map.", fillColor);
        end
    else
        fprintf("Group %s not found in JSON. Skipping.\n", groupName);
    end
end

% Extract line colors
lineColorMatrix = [];
for i = 1:length(groupNames)
    groupName = groupNames(i);
    if isfield(json.graphSpecifications, groupName)
        lineColor = json.graphSpecifications.(groupName).lineColor;
        if isKey(colorMap, lineColor)
            lineColorMatrix(end+1, :) = colorMap(lineColor);
        else
            warning("Color '%s' is not defined in the color map.", lineColor);
        end
    else
        fprintf("Group %s not found in JSON. Skipping.\n", groupName);
    end
end
end