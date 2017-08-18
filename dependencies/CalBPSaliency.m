function saliencyMap = CalBPSaliency( rgb, sup, height, width )
%% Background Optimization
% Get super-pixel properties
[adjcMatrix, pixelList] = SLIC_Split(sup);
meanRgbCol = GetMeanColor(rgb, pixelList);
meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
bdIds = GetBndPatchIds(sup);
colDistM = GetDistanceMatrix(meanLabCol);
[clipVal, geoSigma, neiSigma] = EstimateDynamicParas(adjcMatrix, colDistM);     
[bgProb, bdCon, bgWeight] = EstimateBgProb(colDistM, adjcMatrix, bdIds, clipVal, geoSigma);
saliencyMap = CreateImageFromSPs(1-bgProb, pixelList, height, width);
end

