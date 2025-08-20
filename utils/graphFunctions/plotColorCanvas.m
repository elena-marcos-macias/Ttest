function fig = plotColorCanvas()
% plotColorCanvas - Displays a figure with all predefined RGB colors and their names.

ColorMatrix = [
    1 1 1;
    0.8706 0.8706 0.8706;
    0.71 0.71 0.71;
    0.5 0.5 0.5;
    0.4000 0.3647 0.3647;
    0 0 0;
    0.9882 0.9882 0.5922;
    0.9686 0.9294 0.3686;
    1.0000 0.9490 0.2196;
    0.8784 0.8392 0.2549;
    0.7882 0.6902 0.0549;
    0.9216 0.7098 1.0000;
    0.8745 0.4235 0.9020;
    0.8078 0.3686 0.9686;
    0.6902 0.1098 0.9020;
    0.4196 0.0392 0.4392;
    0.8000 0.9294 0.9059;
    0.6314 0.9412 0.8824;
    0.3569 0.9412 0.8314;
    0.1059 0.8196 0.6902;
    0.0549 0.6706 0.5569
];

colorNames = ["white", "grayLight", "gray", "grayDark1", "grayDark2", "black", ...
    "yellowLight2", "yellowLight1", "yellow", "yellowDark1", "yellowDark2", ...
    "purpleLight2", "purpleLight1", "purple", "purpleDark1", "purpleDark2", ...
    "blueLight2", "blueLight1", "blue", "blueDark1", "blueDark2"];

n = size(ColorMatrix, 1);
fig = figure;
hold on;

for i = 1:n
    rectangle('Position', [i, 0, 1, 1], 'FaceColor', ColorMatrix(i,:), 'EdgeColor', 'none');
    text(i + 0.5, -0.1, colorNames(i), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'Rotation', 45, ...
        'FontSize', 10);
end

xlim([1 n+1]);
ylim([-0.5 1]);
axis off;
title('RGB Colors with Names');
end