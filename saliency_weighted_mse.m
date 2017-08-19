clc;clear;
close all;
%% input paths
synthesized_image_Path = '?D:\Project\QoA\QoA-of-synthesized-view\data\Saliency\Synthesized\';
reference_image_Path = 'D:\Project\QoA\QoA-of-synthesized-view\data\Saliency\Image\';
disparity_map_Path = 'D:\Project\QoA\QoA-of-synthesized-view\data\Saliency\Disparity\';
synthesized_image_Files = dir(fullfile(synthesized_image_Path, '*.bmp'));
reference_image_Files = dir(fullfile(reference_image_Path, '*.bmp'));
disparity_map_Files = dir(fullfile(disparity_map_Path, '*.bmp'));

for index = 1:length(rgbFiles)
    index
    %% get rgb image and generate superpixels
    imgName = rgbFiles(index).name;
    imgPath = [rgbPath, imgName];
    rgb = double(imread(fullfile(rgbPath, imgName)));
    [height width channel] = size(rgb);