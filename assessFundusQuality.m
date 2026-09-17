function result = assessFundusQuality(img)

% ==========================================
% FINAL PROVISIONAL FUNDUS QUALITY ASSESSMENT
% ==========================================

% Provisional thresholds
MIN_FOV_RATIO = 0.15;
MIN_BRIGHTNESS = 20;
MAX_BRIGHTNESS = 240;
MIN_BLUR_SCORE = 3;
MAX_DARK_RATIO = 0.15;

% Default result
result.status = "ACCEPT";
result.reason = "Image quality is sufficient";
% Initialize all metrics
result.fovRatio = NaN;
result.brightness = NaN;
result.darkRatio = NaN;
result.blurScore = NaN;

% Image dimensions
[height, width, ~] = size(img);

% Check image resolution
if height < 224 || width < 224
    result.status = "REJECT";
    result.reason = "Image resolution too low";
    return;
end

% Convert to grayscale
if size(img, 3) == 3
    grayImg = rgb2gray(img);
else
    grayImg = img;
end

grayImg = double(grayImg);

% ==========================================
% 1. FIELD OF VIEW
% ==========================================

fovMask = grayImg > 10;

fovRatio = sum(fovMask(:)) / numel(fovMask);

result.fovRatio = fovRatio;

if fovRatio < MIN_FOV_RATIO
    result.status = "REJECT";
    result.reason = "Insufficient field of view";
    return;
end

% ==========================================
% 2. BRIGHTNESS
% ==========================================

roiPixels = grayImg(fovMask);

if isempty(roiPixels)
    result.status = "REJECT";
    result.reason = "No valid retinal region";
    return;
end

roiBrightness = mean(roiPixels);

result.brightness = roiBrightness;

if roiBrightness < MIN_BRIGHTNESS || ...
        roiBrightness > MAX_BRIGHTNESS

    result.status = "REJECT";
    result.reason = "Unsuitable brightness";
    return;
end

% ==========================================
% 3. DARK RATIO
% ==========================================

darkPixels = grayImg(fovMask) < 30;

darkRatio = sum(darkPixels) / numel(roiPixels);

result.darkRatio = darkRatio;

if darkRatio > MAX_DARK_RATIO
    result.status = "REJECT";
    result.reason = "Excessive dark region";
    return;
end

% ==========================================
% 4. BLUR DETECTION
% ==========================================

lapFilter = fspecial('laplacian', 0.2);

lapImg = imfilter(grayImg, lapFilter, 'replicate');

blurScore = var(lapImg(:));

result.blurScore = blurScore;

if blurScore < MIN_BLUR_SCORE
    result.status = "REJECT";
    result.reason = "Image too blurry";
    return;
end

% ==========================================
% FINAL RESULT
% ==========================================

end