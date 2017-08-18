function [ smap ] = Gabor( R0,A,d0,f,sigma,sita,d)
%GABOR �˴���ʾ�йش˺�����ժҪ
%Disparity tuning �� Gabor Function
%   �˴���ʾ��ϸ˵��
smap = R0 + A * exp(-0.5*((d-d0).^2)/(sigma^2)).*cosd(2*180*f*(d-d0)+sita);
end

