function meanDepth = GetMeanDepth(dep, pixelList)
% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

[h, w, chn] = size(dep);
tmpImg=reshape(dep, h*w, chn);

spNum = length(pixelList);
meanDepth=zeros(spNum, chn);
for i=1:spNum
    meanDepth(i, :)=mean(tmpImg(pixelList{i},:), 1);
end

end