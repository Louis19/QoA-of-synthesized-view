function DistM2 = GetDepthJudgeMatrix( meanDepth )
spNum = size(meanDepth, 1);
DistM2 = repmat(meanDepth(:), [1, spNum]) > repmat(meanDepth(:)', [spNum, 1]);
end

