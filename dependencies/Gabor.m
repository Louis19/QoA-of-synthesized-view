function [ smap ] = Gabor( R0,A,d0,f,sigma,sita,d)
%GABOR 此处显示有关此函数的摘要
%Disparity tuning 的 Gabor Function
%   此处显示详细说明
smap = R0 + A * exp(-0.5*((d-d0).^2)/(sigma^2)).*cosd(2*180*f*(d-d0)+sita);
end

