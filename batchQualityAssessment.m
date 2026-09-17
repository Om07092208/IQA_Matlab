clc;
clear;

% ==========================================
% BATCH FUNDUS QUALITY ASSESSMENT

% ==========================================

% Main dataset folder
rootFolder = uigetdir(pwd, ...
    'Select MAIN DATASET folder');

if isequal(rootFolder, 0)
    error('No folder selected.');
end

% Search all supported image formats recursively
files = [
    dir(fullfile(rootFolder, '**', '*.jpg'));
    dir(fullfile(rootFolder, '**', '*.jpeg'));
    dir(fullfile(rootFolder, '**', '*.png'))
];

% Remove duplicate paths
allPaths = fullfile({files.folder}, {files.name});
[~, uniqueIndex] = unique(allPaths, 'stable');
files = files(uniqueIndex);

numImages = length(files);

fprintf('Total Images: %d\n', numImages);

% Preallocate results
Filename = strings(numImages, 1);
Status = strings(numImages, 1);
Reason = strings(numImages, 1);

FOV_Ratio = NaN(numImages, 1);
Brightness = NaN(numImages, 1);
DarkRatio = NaN(numImages, 1);
BlurScore = NaN(numImages, 1);

% ==========================================
% PROCESS IMAGES
% ==========================================

for i = 1:numImages

    fprintf('Processing image %d/%d\n', i, numImages);

    imagePath = fullfile(files(i).folder, files(i).name);

    try

        img = imread(imagePath);

        result = assessFundusQuality(img);

        Filename(i) = string(files(i).name);
        Status(i) = result.status;
        Reason(i) = result.reason;

        FOV_Ratio(i) = result.fovRatio;
        Brightness(i) = result.brightness;
        DarkRatio(i) = result.darkRatio;
        BlurScore(i) = result.blurScore;

    catch ME

        Filename(i) = string(files(i).name);
        Status(i) = "ERROR";
        Reason(i) = string(ME.message);

    end

end

% ==========================================
% CREATE RESULTS TABLE
% ==========================================

results = table( ...
    Filename, Status, Reason, ...
    FOV_Ratio, Brightness, ...
    DarkRatio, BlurScore);

% Save CSV
writetable(results, 'final_quality_results.csv');

fprintf('\nProcessing completed!\n');
fprintf('Results saved as final_quality_results.csv\n');

% Display summary
disp(groupcounts(results.Status));