clc;clear;
close all;

%% add dependencies
addpath('./dependencies');
dataPath = '.\data\';
rootPath = '.\data\Saliency\';
%% input paths
rgbPath =strcat(dataPath, 'Original/');
depPath = strcat(dataPath,'Disparity\');

%% output paths
supPath =strcat(rootPath, 'superpixel\');
if ~exist(supPath,'file')
    mkdir(supPath);
end
salPath = strcat(rootPath,'salMap/');
if ~exist(salPath,'file')
    mkdir(salPath);
end
LBEPath =strcat(rootPath, 'LBEMap/');
if ~exist(LBEPath,'file')
    mkdir(LBEPath);
end
ColorContrastPath =strcat(rootPath, 'ColorContrastMap/');
if ~exist(ColorContrastPath,'file')
    mkdir(ColorContrastPath);
end
DepthContrastPath =strcat(rootPath, 'DepthContrastMap/');
if ~exist(DepthContrastPath,'file')
    mkdir(DepthContrastPath);
end
ColorDiffusionPath =strcat(rootPath, 'ColorDiffusionMap/');
if ~exist(ColorDiffusionPath,'file')
    mkdir(ColorDiffusionPath);
end
DepthDiffusionPath =strcat(rootPath, 'DepthDiffusionMap/');
if ~exist(DepthDiffusionPath,'file')
    mkdir(DepthDiffusionPath);
end
DisparityTuningPath =strcat(rootPath, 'DisparityTuningMap/');
if ~exist(DisparityTuningPath,'file')
    mkdir(DisparityTuningPath);
end
BPPath =strcat(rootPath, 'BackgroundPriorMap/');
if ~exist(BPPath,'file')
    mkdir(BPPath);
end
DepthPath =strcat(rootPath, 'DepthMap/');
if ~exist(DepthPath,'file')
    mkdir(DepthPath);
end
%% processing
rgbFiles = dir(fullfile(rgbPath, '*.bmp'));
depFiles = dir(fullfile(depPath, '*.bmp'));
if isempty(rgbFiles)
    sprintf('the input image format is ".bmp"');
    rgbFiles = dir(fullfile(rgbPath, '*.jpg'));
    for i = 1:length(rgbFiles)
        imgName = rgbFiles(i).name;
        rgb = imread(fullfile(rgbPath, imgName));
        savePath = fullfile(rgbPath, [imgName(1:end-4), '.bmp']);
        imwrite(rgb,savePath,'bmp');        
    end
    rgbFiles = dir(fullfile(rgbPath, '*.bmp'));
end
% if length(rgbFiles) ~= length(depFiles)
%     error('the number of files is mismatching');
% end

%% calculate saliency map
for index = 1:length(rgbFiles)
    index
    %% get rgb image and generate superpixels
    imgName = rgbFiles(index).name;
    imgPath = [rgbPath, imgName];
    rgb = double(imread(fullfile(rgbPath, imgName)));
    [height width channel] = size(rgb);
    %% segment into superpixels
    supNum = sqrt((height^2+width^2)/2);
    comm = ['SLICSuperpixelSegmentation' ' ' imgPath ' ' int2str(20) ' ' int2str(supNum) ' ' supPath];
    system(comm);    
    supName = fullfile(supPath, [imgName(1:end-4) '.dat']);
    sup = ReadDAT([height, width],supName);
    %% load depth data
    depName = depFiles(index).name;
 %   if strfind( depName(1:strfind(depName,'.')-1), imgNa m e(1:strfind(imgName,'.')-1) )
%         dep = importdata(fullfile(depPath,depName));
%         dep = double(dep.cdata);
%         depnorm = 1 - mat2gray(dep);
  %  else
    %    error('depth image name is mismatching.');
   % end
%         salMapPath = fullfile(DepthPath, [imgName(1:end-4), '.jpg']);
%     imwrite(depnorm, salMapPath);
%     depName = strcat(imgName(1:end-4),'.jpg');
    dep = imread(fullfile(depPath, depName));    

    mysize = size(dep);
    if numel(mysize)>2
       dep=rgb2gray(dep); %将彩色图像转换为灰度图像
    end
    depnorm = mat2gray(dep);
    %% Get super-pixel properties
    [adjcMatrix, pixelList] = SLIC_Split(sup);
    spNum = size(adjcMatrix, 1);
    meanRgbCol = GetMeanColor(rgb, pixelList);
    spArea = zeros(spNum,1);
    for i=1:spNum
        spArea(i) = size(pixelList{i},1);
    end
    meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
    meanDepth = GetMeanDepth(dep, pixelList);
    meanNormDepth = GetMeanDepth(depnorm, pixelList);
    
    meanPos = GetNormedMeanPos(pixelList, height, width);
    colDistM = GetDistanceMatrix(meanLabCol);                                   %分块间的特征距离
    posDistM = GetDistanceMatrix(meanPos);                                      %分块间的空间距离
    %% Calculate LBE Saliency
    lbeSM = CalLBESaliency(1-depnorm, sup, height, width);
    lbeMap = CreateImageFromSPs(lbeSM , pixelList, height, width);
    salMapPath = fullfile(LBEPath, [imgName(1:end-4), '.jpg']);
    imwrite(lbeMap, salMapPath);
    %% Calculate color contrast saliency
    wCtr = CalWeightedContrast(colDistM, posDistM, spArea);
    wCtr = 1-exp(-3*wCtr);
    ColorContrastSM = CreateImageFromSPs(wCtr, pixelList, height, width);
    salMapPath = fullfile(ColorContrastPath, [imgName(1:end-4), '.jpg']);
    imwrite(ColorContrastSM, salMapPath);
    %% Saliency of Depth Contrast
    DepthDistM = zeros(spNum, spNum);
    DepthDistM = DepthDistM + ( repmat(meanNormDepth, [1, spNum]) - repmat(meanNormDepth', [spNum, 1]) ).*( repmat(meanNormDepth, [1, spNum]) > repmat(meanNormDepth', [spNum, 1]) );
    DepthContrast = CalWeightedContrast(DepthDistM, posDistM, spArea);
    DepthContrast = mat2gray(DepthContrast);
    DepthContrastSM = CreateImageFromSPs(DepthContrast, pixelList, height, width);
    salMapPath = fullfile(DepthContrastPath, [imgName(1:end-4), '.jpg']);
    imwrite(DepthContrastSM, salMapPath);
    %% Saliency of Depth Diffusion
    th=1.8*mean(DepthContrast);
    DC=DepthContrast >= th;
    DepthDiffusion = Diffusion(adjcMatrix, sup, DepthContrast, GetDistanceMatrix(meanNormDepth),10);
    DepthDiffusionSM = CreateImageFromSPs(DepthDiffusion, pixelList, height, width);
    salMapPath = fullfile(DepthDiffusionPath, [imgName(1:end-4), '.jpg']);
    imwrite(DepthDiffusionSM, salMapPath);
    %% Saliency of Color Diffusion
    th1=1.8*mean(wCtr);
    CC = wCtr >= th1;
    ColorDiffusion = Diffusion(adjcMatrix, sup, DepthContrast,  colDistM,10);
    ColorDiffusion = 1-exp(-3*ColorDiffusion);
    ColorDiffusionSM = CreateImageFromSPs(ColorDiffusion, pixelList, height, width);
    salMapPath = fullfile(ColorDiffusionPath, [imgName(1:end-4), '.jpg']);
    imwrite(ColorDiffusionSM, salMapPath);
    %% Saliency of Depth tuning
%     AngleDepth = -atand(meanDepth./970);
    AngleDepth = -atand(meanDepth/1080*31/93);
%     AngleDepth = atand(6.3/93)-atand(6.3./(93-meanDepth));
    DTNeural = DisparityTuningMT( AngleDepth );
    DTStatistical = sqrt(meanNormDepth);
    DT = mat2gray(DTStatistical);
    DisparityTuningSM = CreateImageFromSPs(DT, pixelList, height, width);
    salMapPath = fullfile(DisparityTuningPath, [imgName(1:end-4), '.jpg']);
    imwrite(DisparityTuningSM, salMapPath);
    
    %% Calculate Background Prior
    B = CalBPSaliency(rgb, sup, height, width);
    salMapPath = fullfile(BPPath, [imgName(1:end-4), '.jpg']);
    imwrite(B, salMapPath);
    %% Saliency Combination
    smap=[DepthContrast';DepthDiffusion';ColorDiffusion';wCtr';lbeSM';DT']';
    var = sqrt(sum((smap-repmat(mean(smap),spNum,1)).^2));
    var = exp(-mat2gray(var));
    d3map = smap*var';

%     d3map = Adaptive_Fusion(smap,meanPos,meanDepth,spArea);
    %% color propagantion
    a1 = mat2gray(d3map);
    A = zeros(1,spNum);
    G = zeros(1,spNum);
    A(a1>0.8)=1;
    A(a1<0.2)=1;
    G(a1>0.8)=1;
    feature = mat2gray(meanDepth)';
    ColorP = ColorPropagation(adjcMatrix, sup,posDistM, feature,A,G);
    
    %% 
    SaliencyMap = CreateImageFromSPs(d3map, pixelList, height, width);

    [row, col, dim] = size(SaliencyMap);
    center_bias_map = CenterBias_Model(SaliencyMap, 2);
    SaliencyMap = mat2gray(0.7*SaliencyMap+0.3*center_bias_map);
%     SaliencyMap = SaliencyMap.*B;

    SaliencyMap = imresize(SaliencyMap, 1/16);    
    SaliencyMap = Norm_Operation(SaliencyMap);
    f = fspecial('gaussian',[8 8],3); %高斯模板
    SaliencyMap = imfilter(SaliencyMap,f,'same'); % 滤波
    SaliencyMap = imresize(SaliencyMap, [row col]);  
    SaliencyMap = mat2gray(SaliencyMap);
    salMapPath = fullfile(salPath, [imgName(1:end-4), '.jpg']);
    imwrite(SaliencyMap, salMapPath);
end