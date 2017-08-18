function smap = Diffusion(adjcMatrix, idxImg, bdIds, colDistM,theta)
% The core function for Manifold Ranking Saliency: 
% C. Yang, L. Zhang, H. Lu, X. Ruan, and M.-H. Yang. Saliency
% detection via graph-based manifold ranking. In CVPR, 2013.

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

alpha=0.99;
% theta=10;
spNum = size(adjcMatrix, 1);

%% Construct Super-Pixel Graph
% adjcMatrix_nn = LinkNNAndBoundary2(adjcMatrix, bdIds); 
% This super-pixels linking method is from the author's code, but is 
% slightly different from that in our Saliency Optimization

C = SetSmoothnessMatrix(colDistM, adjcMatrix, theta);

% The smoothness setting is also different from that in Saliency
% Optimization, where exp(-d^2/(2*sigma^2)) is used
% C(adjcMatrix == 0) = 0;
% bdIds = sum(C);
% C(adjcMatrix == 0) = Inf;
% W = exp(-C * theta);
D = diag(sum(C));
optAff = (D-alpha*C) \ eye(spNum);
optAff(1:spNum+1:end) = 0;  %set diagonal elements to be zero

%% Stage 1
% top
% Yt=zeros(spNum,1);
% Yt(bdIds)=1;
smap=optAff*bdIds;
smap=(smap-min(smap(:)))/(max(smap(:))-min(smap(:)));
smap=1-smap;



function W = SetSmoothnessMatrix(colDistM, adjcMatrix_nn, theta)
allDists = colDistM(adjcMatrix_nn > 0);
maxVal = max(allDists);
minVal = min(allDists);

colDistM = (colDistM - minVal) / (maxVal - minVal + eps);
W = colDistM;

function adjcMatrix = LinkNNAndBoundary2(adjcMatrix, bdIds)
%link boundary SPs
adjcMatrix(bdIds, bdIds) = 1;

%link neighbor's neighbor
adjcMatrix = (adjcMatrix * adjcMatrix + adjcMatrix) > 0;
adjcMatrix = double(adjcMatrix);

spNum = size(adjcMatrix, 1);
adjcMatrix(1:spNum+1:end) = 0;  %diagnal elements set to be zero

