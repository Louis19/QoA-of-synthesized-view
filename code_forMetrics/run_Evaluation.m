clear, clc, 
close all
tic
toPlot = 0; 
stepSize = .1; 
Nsplits = 100; 
%% select dataset and model
model = 'DTS';
dataset = '3DGaze';
%% path setup
salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\salMap\');
salFiles = dir(fullfile(salPath, '*.jpg'));
OtherMapPath ='D:\Dataset\IRCCyN\EyMIR3D\Fixation_Maps\OtherMap.jpg';
OtherMap = im2bw(imread(OtherMapPath),0.5);
[h,w] =size(OtherMap);
% OtherMap = CenterBias(h,w);
DensityPath = strcat('D:\Project\StereoSaliency\DATA\3DGaze\DensityMap\');
score = zeros(length(salFiles),12);

for index=1:length(salFiles)
    index
    salName = salFiles(index).name;
    salMap = mat2gray(imread(fullfile(salPath, salName)));
    switch dataset
        case '3DGaze'
        fixationName = strcat(salName(1:end-4),'.jpg');
        FixationPath = strcat('D:\Project\StereoSaliency\DATA\',dataset,'\FixationMap\');
        fixation=imread(fullfile(FixationPath,fixationName));
        densityFiles = dir(fullfile(DensityPath, '*.png'));
        densityName = strcat(salName(1:end-4),'.png');
        density=mat2gray(imread(fullfile(DensityPath,densityName)));
        case 'NCTU'
        fixationName = strcat(salName(1:end-5),'FixPts.bmp');
        FixationPath = strcat('D:\Project\StereoSaliency\DATA\',dataset,'\FixationMap\');
        fixation=imread(fullfile(FixationPath,fixationName));
        densityFiles = dir(fullfile(DensityPath, '*.bmp'));
        densityName = strcat(salName(1:end-5),'Fix.bmp');
        density=mat2gray(imread(fullfile(DensityPath,densityName)));
        case 'NLPR'
        gtName = strcat(salName(1:end-4),'.jpg');
        gtPath = strcat('D:\Project\StereoSaliency\DATA\',dataset,'\groundtruth\');
        gt = imread(fullfile(gtPath,gtName));
        mysize=size(gt);
        if numel(mysize)>2
            gt=rgb2gray(gt); %将彩色图像转换为灰度图像
        end
        gt =mat2gray(gt);
        fixation = gt;density=gt;
        case 'NJUD'
        gtName = strcat(salName(1:end-4),'.png');
        gtPath = strcat('D:\Project\StereoSaliency\DATA\',dataset,'\groundtruth\');
        gt = imread(fullfile(gtPath,gtName));
        mysize=size(gt);
        if numel(mysize)>2
            gt=rgb2gray(gt); %将彩色图像转换为灰度图像
        end
         gt =mat2gray(gt);
        fixation = gt;density=gt;
        case 'NUS'
        gtName = strcat(salName(1:end-4),'.bmp');
        gtPath = strcat('D:\Project\StereoSaliency\DATA\',dataset,'\FixationMap\');
        gt = imread(fullfile(gtPath,gtName));
        mysize=size(gt);
        if numel(mysize)>2
            gt=rgb2gray(gt); %将彩色图像转换为灰度图像
        end
        gt =mat2gray(gt);
        fixation = gt;density=gt;
    end
    
    mysize=size(fixation);
    if numel(mysize)>2
        fixation=rgb2gray(fixation); %将彩色图像转换为灰度图像
    end
    if size(salMap, 1)~=size(fixation, 1) || size(salMap, 2)~=size(fixation, 2)
        salMap = imresize(salMap, size(fixation));
    end
    fixation = im2bw(fixation,0.5);

    %% 1.jAUC
%     score(index,1) = AUC_Judd(salMap, fixation, 1, toPlot);
    %% 2.bAUC
    score(index,2) = AUC_Borji(salMap, fixation, Nsplits, stepSize, toPlot);
    %% 3.sAUC
    score(index,3) = AUC_shuffled(salMap, fixation, OtherMap, Nsplits, stepSize, toPlot);
    %% 4.CC
    score(index,4) = CC(salMap, density);
    %% 5.similarity
    score(index,5) = similarity(salMap, density, toPlot);
    %% 6.CalMAE
    score(index,6) = CalMAE(salMap, fixation);
    %% 7.KLD
    score(index,7) = CalKLDiv(density,salMap);
    %% 8.NSS
    score(index,8) = NSS(salMap, fixation);
    %% 9.EMD
%     score(ii,9) = EMD(salMap, density, toPlot);
    %% 10.PR F-measure
%     [score(index,10),score(index,11)] = CalPR(salMap, fixation);
 
end
score(isnan(score)) = 0;
result= mean(score);
result(12) = 1.3*result(10)*result(11)/(0.3*result(10)+result(11));

resultPath = 'D:\Project\StereoSaliency\DTS\result\';
if ~exist(resultPath,'file')
    mkdir(resultPath);
end

resultPath = strcat(resultPath,'result_',model,'_',dataset,'.mat');
save(resultPath , 'result');
toc