function [precision, recall] = CalPR(smapImg, gtImg)
smapImg = smapImg(:,:,1);
if ~islogical(gtImg)
    gtImg = gtImg(:,:,1) > 128;
end

if any(size(smapImg) ~= size(gtImg))
    error('saliency map and ground truth mask have different size');
end
[r,c]=size(smapImg);
T = 2*sum(sum(smapImg))/r/c;
if T>1
    T=1;
end
smap = im2bw(smapImg,T);
gtPxlNum = sum(gtImg(:));

if 0 == gtPxlNum
    error('no foreground region is labeled');
end
truepositive = sum(sum(smap(gtImg)));

precision = truepositive / sum(sum(smap));
recall = truepositive / sum(sum(gtImg));
    precision(isnan(precision))=0; % resolving the case when P(i)==0
    recall(isnan(recall))=0;  