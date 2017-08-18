function Z = ColorPropagation(adjcMatrix, idxImg, posDistM, meanLabCol,A,G)

alpha=1;
K=30;
spNum = size(adjcMatrix, 1);

%% Construct Super-Pixel Graph
% adjcMatrix_nn = LinkNNAndBoundary2(adjcMatrix); 
% This super-pixels linking method is from the author's code, but is 
% slightly different from that in our Saliency Optimization
[sorted, index] = sort(posDistM);
neighborhood = index(2:(K+1),:);
if(K>3) 
  fprintf(1,'   [note: K>D; regularization will be used]\n'); 
  tol=1e-3; % regularlizer in case constrained fits are ill conditioned
else
  tol=0;
end
W = zeros(K,spNum);
% W = SetSmoothnessMatrix(colDistM, adjcMatrix_nn,spNum);
% The smoothness setting is also different from that in Saliency
% Optimization, where exp(-d^2/(2*sigma^2)) is used
for ii=1:spNum
   z = meanLabCol(:,neighborhood(:,ii))-repmat(meanLabCol(:,ii),1,K); % shift ith pt to origin
   v = z'*z;                                        % local covariance
   v = v + eye(K,K)*tol*trace(v);                   % regularlization (K>D)
   W(:,ii) = v\ones(K,1);                           % solve Cw=1
   W(:,ii) = W(:,ii)/sum(W(:,ii));                  % enforce sum(w)=1
end;

M = sparse(1:spNum,1:spNum,ones(1,spNum),spNum,spNum,4*K*spNum); 
for ii=1:spNum
   w = W(:,ii);
   jj = neighborhood(:,ii);
   M(ii,jj) = M(ii,jj) - w';
   M(jj,ii) = M(jj,ii) - w;
   M(jj,jj) = M(jj,jj) + w*w';
end;
A = alpha.*diag(A);
G = G';
M= M + A;
Z = M\(A*G);
Z = mat2gray(Z);

function W = SetSmoothnessMatrix(colDistM, adjcMatrix_nn,spNum)
% allDists = colDistM(adjcMatrix_nn > 0);
% maxVal = max(allDists);
% minVal = min(allDists);

colDistM(adjcMatrix_nn == 0) = 0;
% colDistM = (colDistM - minVal) / (maxVal - minVal + eps);
W = colDistM\ones(spNum,1);
W = W\sum(W);

function adjcMatrix = LinkNNAndBoundary2(adjcMatrix)
%link boundary SPs
% adjcMatrix(bdIds, bdIds) = 1;

%link neighbor's neighbor
adjcMatrix = (adjcMatrix * adjcMatrix + adjcMatrix) > 0;
adjcMatrix = double(adjcMatrix);
adjcMatrix = (adjcMatrix * adjcMatrix + adjcMatrix) > 0;
adjcMatrix = double(adjcMatrix);

spNum = size(adjcMatrix, 1);
adjcMatrix(1:spNum+1:end) = 0;  %diagnal elements set to be zero
