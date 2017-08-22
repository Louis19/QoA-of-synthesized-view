clc;clear;
close all;
%% input paths
synthesized_image_Path = '.\data\Synthesized\';
reference_image_Path = '.\data\Original\';
sal_map_Path = '.\data\Saliency\salMap\';
synthesized_image_Files = dir(fullfile(synthesized_image_Path, '*.bmp'));
reference_image_Files = dir(fullfile(reference_image_Path, '*.bmp'));
sal_map_Files = dir(fullfile(sal_map_Path, '*.jpg'));
MSE = zeros(length(synthesized_image_Files),1);
for index = 1:length(synthesized_image_Files)
    index
    close all
    %% get rgb image and generate superpixels
    synthesized_image_Name = synthesized_image_Files(index).name;
%     imgPath = [synthesized_image_Path, synthesized_image_Name];
    rgb = double(rgb2gray(imread(fullfile(synthesized_image_Path, synthesized_image_Name))));
    reference_NO = rem(index,12).*(rem(index,12)~=0)+12.*( rem(index,12)==0);
    reference_image_Name = reference_image_Files(reference_NO).name;
    reference_image = double(rgb2gray(imread(fullfile(reference_image_Path, reference_image_Name))));
    sal_map_Name = sal_map_Files(reference_NO).name;
    sal_map = mat2gray(imread(fullfile(sal_map_Path, sal_map_Name)));
%     mse = ((rgb(:,:,1)-reference_image(:,:,1)).^2+(rgb(:,:,2)-reference_image(:,:,2)).^2+(rgb(:,:,3)-reference_image(:,:,3)).^2);
    mse = (rgb-reference_image).^2;
%     figure
%     imagesc(mse)
    % 求加权MSE，saliency作为权重
    wmse = mse.*sal_map;
%     figure
%     imagesc(wmse)
%     MSE(index) = 10*log10(255^2./mean(mean(wmse)));
    MSE(index) = 1/mean(mean(wmse));
end
% MSE = MSE./max(MSE);
objectScore = cell(84,2);
for i=1:84
objectScore{i,1} = synthesized_image_Files(i).name;
objectScore{i,2} = MSE(i);
end
save('objectScore.mat','objectScore');
