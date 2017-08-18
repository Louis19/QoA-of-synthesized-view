function S = CalLBESaliency( dep, sup, height, width )
%CALLBESALIENCY 此处显示有关此函数的摘要
%   此处显示详细说明
% r is the radius of the neibourhood of patch P
r = sqrt(height^2+width^2)/4;
% pixelList is the list of point in patches
[adjcMatrix, pixelList] = SLIC_Split(sup);
%% LBE saliency
meanDepth = GetMeanDepth(dep, pixelList);
spNum = size(meanDepth, 1);
meanPos = GetMeanPos(pixelList, height, width);
posDistM = GetDistanceMatrix(meanPos);
depthJudgeM =  repmat(meanDepth, [1, spNum]) > repmat(meanDepth', [spNum, 1]);
distanceJudgeM = posDistM<r;
% patches further than the selected patch within which the radius of
neighbourM = depthJudgeM.*distanceJudgeM;
A = neighbourM .* repmat(meanDepth(:), [1, spNum]);
meanNeighbourPatchDepth = sum(A)./(sum(A>0)+eps);
depthSigma = sqrt(sum(((repmat(meanDepth(:), [1, spNum]) - repmat(meanNeighbourPatchDepth(:), [1, spNum])).*(A>0)).^2)./sum(A>0)); 
F = zeros(spNum,1);
G = zeros(spNum,1);
for i=1:10
     DepthM = (repmat(meanDepth, [1, spNum]) > repmat(meanDepth', [spNum, 1])+i/10*repmat(depthSigma,[spNum,1]));
     NM = DepthM.*neighbourM;
     XPosM = (repmat(meanPos(:,1),[1,spNum]) - repmat(meanPos(:,1)',[spNum,1])).*NM;
     YPosM = (repmat(meanPos(:,2),[1,spNum]) - repmat(meanPos(:,2)',[spNum,1])).*NM;

     AngleM = atan2(YPosM,XPosM);
     AngleM = ((AngleM/pi)+NM)*16;
     AngleM = sort(AngleM,'descend');
     AngleM = ceil(AngleM);
     ElementM = cell(spNum,1);
     for j = 1:spNum
        tm = AngleM(:,j);
        ElementM{j} = unique(tm(tm ~=0));
        F(j) = F(j)+numel(ElementM{j});
        if numel(ElementM{j})>1
            diff = zeros(length(ElementM{j}),1);
            for k = 1:length( ElementM{j})-1
                diff(k) = ElementM{j}(k+1)-ElementM{j}(k);
            end
            diff(length(ElementM{j}))=ElementM{j}(1)+32-ElementM{j}(length(ElementM{j}));
        elseif numel(ElementM{j})==1
            diff = 31;
        else
            diff = 32;
        end
        G(j)=G(j)+1-max(diff)/32;
     end
end
F = F/320;
G = G/10;
S = F.*G;

end

