function [F,precision,recall] = PR(salMap, gtImg, stepSize, toPlot)
%PR 此处显示有关此函数的摘要
%   此处显示详细说明
if nargin < 4, toPlot = 0; end
if nargin < 3, stepSize = 0.01; end
F=nan;

% If there are no fixations to predict, return NaN
if sum(gtImg(:)>0)<=1
    disp('no fixationMap');
    return
end 

% make the saliencyMap the size of the image of fixationMap
if size(salMap, 1)~=size(gtImg, 1) || size(salMap, 2)~=size(gtImg, 2)
    salMap = imresize(salMap, size(gtImg));
end

% normalize saliency map
salMap = (salMap-min(salMap(:)))/(max(salMap(:))-min(salMap(:)));

if sum(isnan(salMap(:)))==length(salMap(:))
    disp('NaN saliencyMap');
    return
end

thresholdParam = 0:stepSize:1-stepSize;
precision = zeros(1,length(thresholdParam));
recall    = zeros(1,length(thresholdParam));
Fscore    = zeros(1,length(thresholdParam));
for i = 1:length(thresholdParam)
    thresh = thresholdParam(i);
    smap = im2bw(salMap,thresh);
    gtPxlNum = sum(gtImg(:));
    if 0 == gtPxlNum
        error('no foreground region is labeled');
    end
    truepositive = sum(sum(smap(gtImg)));

    precision(i) = truepositive / sum(sum(smap));
    recall(i) = truepositive / sum(sum(gtImg));
    if isnan(precision(i))
        precision(i) = 1;
    end % resolving the case when P(i)==0
    if isnan(recall(i))
        recall(i) = 0;
    end  
    Fscore(i) = 1.3*precision(i)*recall(i)/(0.3*precision(i)+recall(i)); 
end
F = max(Fscore);
if toPlot
    subplot(121); imshow(salMap, []); title('SaliencyMap with fixations to be predicted');
    hold on;
    [y, x] = find(gtImg);
    plot(x, y, '.r');
    subplot(122); plot(recall, precision, '.b-');   title(['Area under ROC curve: ', num2str(F)])
end


