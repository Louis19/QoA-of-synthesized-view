function F = Adaptive_Fusion( feature, pos, depth, area )
[S,D]=size(feature);
location =[pos';depth']';  
center = (feature.*repmat(area,1,D))'*location./(repmat(sum(feature.*repmat(area,1,D)),3,1))';
v=zeros(D,1);
for i=1:D
    v(i)=sum(sqrt(sum((location - repmat(center(i,:),S,1)).^2,2)).*feature(:,1).*area)/sum(feature(:,1).*area);
end
w = exp(-v);
F = feature*w;
end

