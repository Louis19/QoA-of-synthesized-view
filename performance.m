clear all;
close all;
load('MOS.mat');
load('objectScore.mat');
load('pcScore.mat');
pic_comparison = zeros(size(objectScore,1),2);
for i=1:size(objectScore,1)
    imageName = objectScore{i,1};
    [row,col]=find(strcmp(IRCCyNIVCDIBRImagesDatabaseACRScore,imageName));
    pic_comparison(i,1) = objectScore{i,2};
    pic_comparison(i,2) = IRCCyNIVCDIBRImagesDatabaseACRScore{row,2};
end
PC=zeros(7,1);
for i=1:7
    method_name = IRCCyNIVCDIBRImagesDatabasePCScorev3S3{i+1,1};
    [row,col]=find(strcmp(IRCCyNIVCDIBRImagesDatabasePCScorev3S3,method_name));
    for j = 1:size(row,1)
        PC(i) = PC(i)+IRCCyNIVCDIBRImagesDatabasePCScorev3S3{row(j),2};
    end
end
PC=PC/12;
% 计算每种方法的平均得分
method_comparison = zeros(7,4);
for i = 1:7
    method_comparison(i,1) = mean(pic_comparison(1+(i-1)*12:12+(i-1)*12,1));
    method_comparison(i,2) = mean(pic_comparison(1+(i-1)*12:12+(i-1)*12,2));
    method_comparison(i,3) = PC(i);
    method_comparison(i,4) = i;
end
method_comparison([3,4,6,7],3) = PC([7,6,3,4]);
% 计算每种方法的排序值
method_rank = zeros(7,3);
rank = sortrows(method_comparison,-1);
method_rank(:,1) = rank(:,4);
rank = sortrows(method_comparison,-2);
method_rank(:,2) = rank(:,4);
rank = sortrows(method_comparison,-3);
method_rank(:,3) = rank(:,4);
cc_MOS = corr2(method_comparison(:,1),method_comparison(:,2));
cc_PC = corr2(method_comparison(:,1),method_comparison(:,3));