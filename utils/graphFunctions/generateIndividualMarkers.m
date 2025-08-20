function [markerShapeMatrix, filledStatusLogical] = generateIndividualMarkers(jsonFilePath)
% generateIndividualMarkers - Extracts marker shapes and logical fill status from a JSON file.
%
% Syntax:
%   [markerShapeMatrix, fillStatusLogical] = generateIndividualMarkers(jsonFilePath)
%
% Inputs:
%   jsonFilePath - Path to the JSON file containing the graph specifications.
%
% Outputs:
%   markerShapeMatrix - 1xN cell array with marker shape symbols as strings (e.g., {'^', 'o', 's'})
%   fillStatusLogical - 1xN logical array, true for 'filled', false for 'none'

% --------- Read instructions JSON archive -----------
json = readstruct(jsonFilePath);

% List of possible group names
groupNames = ["Group1", "Group2", "Group3", "Group4", ...
              "Group5", "Group6", "Group7", "Group8"];

% Initialize outputs
markerShapeMatrix = {};    % Cell array for marker shapes
filledStatusLogical = [];    % Logical array for fill status

% Loop through each group and extract info
for i = 1:length(groupNames)
    groupName = groupNames(i);
    if isfield(json.graphSpecifications, groupName)
        groupData = json.graphSpecifications.(groupName);

        % Extract markerShape
        if isfield(groupData, "markerShape")
            markerShapeMatrix{end+1} = strtrim(groupData.markerShape);  % clean whitespace
        else
            warning("Group %s does not contain 'markerShape'.", groupName);
            markerShapeMatrix{end+1} = '';  % Default or empty
        end

        % Extract fillStatus and convert to logical
        if isfield(groupData, "filledStatus")
            statusRaw = groupData.filledStatus;
            statusClean = strtrim(string(statusRaw));  % trim spaces and convert to string
            filledStatusLogical(end+1) = strcmpi(statusClean, "filled");
        else
            warning("Group %s does not contain 'fillStatus'.", groupName);
            filledStatusLogical(end+1) = false;
        end
    else
        fprintf("Group %s not found in JSON. Skipping.\n", groupName);
    end
end
end