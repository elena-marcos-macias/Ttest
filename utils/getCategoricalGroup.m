function [Group, Group_categories, nGroup] = getCategoricalGroup(T_Original, groupName)
%GETCATEGORICALGROUP Extrae una variable categórica de una tabla
%
% [Group, Group_categories, nGroup] = getCategoricalGroup(T_Original, groupName)
%
% Inputs:
%   - T_Original: tabla con los datos originales
%   - groupName: nombre (string o char) de la columna a usar como variable categórica
%
% Outputs:
%   - Group: variable categórica extraída de la tabla
%   - Group_categories: categorías únicas de la variable categórica
%   - nGroup: número de categorías

    % Verifica que el nombre exista en la tabla
    col_index = find(strcmp(T_Original.Properties.VariableNames, groupName));
    
    if isempty(col_index)
        error('No se encontró la columna con el nombre "%s" en la tabla.', groupName);
    end
    
    % Extrae la columna y conviértela en variable categórica
    Group = categorical(T_Original{:, col_index});
    
    % Convertir a categorical explícitamente para garantizar compatibilidad en comparaciones
    Group_categories = categorical(categories(Group));
    
    nGroup = numel(Group_categories);
end