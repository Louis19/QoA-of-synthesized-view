clear
%% select dataset and model
% model = 'DTS';
dataset = 'NJUD';
stepsize = 0.05;
figure;
c = jet(4);
%% Different SalPath
meanP = zeros(1,4);
meanR = zeros(1,4);
Fmeasure = zeros(1,4);
for j = 1:4
%% Path setup
switch j
    case 1 
        salPath = strcat('D:\Project\StereoSaliency\','DTS','\',dataset,'\salMap\');
    case 2
        salPath = strcat('D:\Project\StereoSaliency\','Fang','\',dataset,'\salMap\');
    case 3
        salPath = strcat('D:\Project\StereoSaliency\','LBE','\',dataset,'\salMap\');
    case 4
        salPath = strcat('D:\Project\StereoSaliency\','ACSD','\',dataset,'\salMap\');
%     case 5
%         salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\DisparityTuningMap\');
%     case 6
%         salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\salMapWithout\');
%     case 6
%         salPath = strcat('D:\Project\StereoSaliency\',model,'\',dataset,'\salMap\');
end

salFiles = dir(fullfile(salPath, '*.jpg'));
n = length(salFiles);
score = zeros(1,n);
threshNum = 1/stepsize;
Precision = zeros(threshNum,n);
Recall = zeros(threshNum,n);
for i=1:n
    i
    salName = salFiles(i).name;
    salMap = mat2gray(imread(fullfile(salPath, salName)));
    if sum(salMap(:)>0)<=1
        continue
    end 
    gtName = strcat(salName(1:end-4),'.png');
    gtPath = strcat('D:\Project\StereoSaliency\DATA\',dataset,'\groundtruth\');
    gtImg=imread(fullfile(gtPath,gtName));
    mysize=size(gtImg);
    if numel(mysize)>2
        gtImg=rgb2gray(gtImg); %将彩色图像转换为灰度图像
    end
    if size(salMap, 1)~=size(gtImg, 1) || size(salMap, 2)~=size(gtImg, 2)
        salMap = imresize(salMap, size(gtImg));
    end
    gtImg = im2bw(gtImg,0.5);
    [score(i),Precision(:,i),Recall(:,i)] = PR(salMap, gtImg, stepsize, 0);
end
% Score(j) = mean(score);
P = mean(Precision,2);
R = mean(Recall,2);
meanP(1,j) = mean(P);
meanR(1,j) = mean(R);
tem = 1.3*P.*R./(0.3*P+R);
Fmeasure(1,j) = max(tem);
%% plot the ROC curve
% tp1 = P(1:1:end); fp1 = R(1:1:end);
plot(R,P,'color',c(j,:),'linewidth',1); hold on;
% colmap = fliplr(colormap(jet(6)));
% for ii = 1:13
%      plot(fp1(ii),tp1(ii),'.','color',colmap(ii,:),'markersize',20); hold on;
% end 
end
% title(sprintf('AUC: %2.2f',Score),'fontsize',14);
xlabel('Recall','fontsize',14); ylabel('Precision','fontsize',14);
legend('DTSS','Fang [17]','LBE [22]','ACSD [21]','Location','Best');