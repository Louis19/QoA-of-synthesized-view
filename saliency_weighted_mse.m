clc;clear;
close all;
%% input paths
synthesized_image_Path = 'D:\Project\QoA\QoA-of-synthesized-view\data\Saliency\Synthesized';
reference_image_Path = 'D:\Project\QoA\QoA-of-synthesized-view\data\Saliency\Image\';
sal_map_Path = 'D:\Project\QoA\QoA-of-synthesized-view\data\Saliency\Result\salMap\';
synthesized_image_Files = dir(fullfile(synthesized_image_Path, '*.bmp'));
reference_image_Files = dir(fullfile(reference_image_Path, '*.bmp'));
sal_map_Files = dir(fullfile(sal_map_Path, '*.jpg'));
MSE = zeros(length(synthesized_image_Files),1);
for index = 1:length(synthesized_image_Files)
    index
    %% get rgb image and generate superpixels
    synthesized_image_Name = synthesized_image_Files(index).name;
%     imgPath = [synthesized_image_Path, synthesized_image_Name];
    rgb = double(rgb2gray(imread(fullfile(synthesized_image_Path, synthesized_image_Name))));
    reference_NO = rem(index,12).*(rem(index,12)~=0)+12.*( rem(index,12)==0);
    reference_image_Name = reference_image_Files(reference_NO).name;
    reference_image = double(rgb2gray(imread(fullfile(reference_image_Path, reference_image_Name))));
    sal_map_Name = sal_map_Files(reference_NO).name;
    sal_map = mat2gray(imread(fullfile(sal_map_Path, sal_map_Name)));
    MSE(index) = 1/mean(mean(((rgb-reference_image).^2).*sal_map));
end
MSE = MSE./max(MSE);
objectScore = cell(84,2);
for i=1:84
objectScore{i,1} = synthesized_image_Files(i).name;
objectScore{i,2} = MSE(i);
end

