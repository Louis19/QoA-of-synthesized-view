function [ smap ] = DisparityTuningMT( d )
%DISPARITYTUNINGMT 此处显示有关此函数的摘要
%使用Gabor Function拟合13种MT神经的感受野,计算深度显著性
%   此处显示详细说明
para=[72 44 -0.23 1.86 0.19 74;
    77 67 -0.46 1.16 0.25 86;
    81 73 0.15 1.07 0.28 123;
    41 42 -0.11 0.62 0.43 73;
    75 110 -0.04 0.53 0.51 40;
    32 124 -0.16 0.31 0.37 -51;
    24 51 -0.02 0.62 0.42 -38;
    51 77 0.04 0.67 0.5 -55;
    59 46 -0.01 0.57 0.49 -92;
    18 121 0.24 0.52 0.3 -61;
    16 49 0.81 1.01 0.21 -19;
    33 31 1.6 2.1 0.19 38;
    101 92 -0.23 0.56 0.33 -162];
% % response = zeros(13;:);
    [m,n]=size(d);
    response = zeros(m,n,13);
for ii=1:13
R0 = para(ii,1);
A = para(ii,2);
d0 = para(ii,3);
sigma = para(ii,4);
f = para(ii,5);
sita= para(ii,6);
response(:,:,ii) = Gabor(R0,A,d0,f,sigma,sita,d);
end
smap = mat2gray(max(response,[],3));
% smap = mat2gray(mean(response,3));
end

