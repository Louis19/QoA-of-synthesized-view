clear
%% select dataset and model
model = 'DTS';
dataset = '3DGaze';
figure;
c = jet(6);
%% Different SalPath
for j = 1:6
%% Path setup
switch j
    case 1 
        salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\ColorContrastMap\');
    case 2
        salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\ColorDiffusionMap\');
    case 3
        salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\DepthContrastMap\');
    case 4
        salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\DepthDiffusionMap\');
    case 5
        salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\DisparityTuningMap\');
%     case 6
%         salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\salMapWithout\');
    case 6
        salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\salMap\');
end

salFiles = dir(fullfile(salPath, '*.jpg'));
n = length(salFiles);
score = zeros(1,n);
tp = zeros(13,n);
fp = zeros(13,n);
for i=1:n
    i
    salName = salFiles(i).name;
    salMap = mat2gray(imread(fullfile(salPath, salName)));
    fixationName = strcat(salName(1:end-4),'.jpg');
    FixationPath = strcat('D:\Project\StereoSaliency\DATA\',dataset,'\FixationMap\');
    fixation=imread(fullfile(FixationPath,fixationName));
    mysize=size(fixation);
    fixation=im2double(fixation); %将图像转换为灰度图像
    if size(salMap, 1)~=size(fixation, 1) || size(salMap, 2)~=size(fixation, 2)
        salMap = imresize(salMap, size(fixation));
    end
    fixation = im2bw(fixation,0.5);
    [score(i),tp(:,i),fp(:,i)] = AUC_Borji(salMap, fixation);
end
Score(j) = mean(score);
TP = mean(tp,2);
FP = mean(fp,2);
%% plot the ROC curve
tp1 = TP(1:1:end); fp1 = FP(1:1:end);
plot(FP,TP,'color',c(j,:),'linewidth',1); hold on;
colmap = fliplr(colormap(jet(13)));
% for ii = 1:13
%      plot(fp1(ii),tp1(ii),'.','color',colmap(ii,:),'markersize',20); hold on;
% end 
end
% title(sprintf('AUC: %2.2f',Score),'fontsize',14);
xlabel('FPR','fontsize',14); ylabel('TPR','fontsize',14);
legend('Color Contrast','Color Diffusion','Depth Contrast','Depth Diffusion','Disparity Tuning','Fused Saliency','Location','Best');