function cbm = CenterBias(height, width)
sigma = sqrt(height^2+width^2)/4;
Y0 = round(height/2);
X0 = round(width/2);
y = -Y0:1:height-Y0-1;
x = -X0:1:width-X0-1;
y = repmat(y', [1, width]);    
x = repmat(x, [height, 1]);
cbm = exp((-x.^2 - y.^2)/(2*sigma*sigma));
end


