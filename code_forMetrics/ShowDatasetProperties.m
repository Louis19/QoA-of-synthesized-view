figure;
for ii = 1:18
    no = num2str(ii);
    Image = imread(strcat('D:\Dataset\IRCCyN\EyMIR3D\Images\Image_', no, '_L.png'));
%     gtimg = im2double(imread(strcat('D:\Project\Saliency Benchmark\gbvs\gbvs\result\',no,'.png')));
%     gtimg = im2double(imread(strcat('D:\Dataset\IRCCyN\EyMIR3D\Fixation_Density_Maps\FDM_',no,'.png')));
    gtimg = im2double(imread(strcat('D:\Project\Matlab\VCIP\Data\3D Gaze\Result\',no,'_3d.png')));
%     gtimg = im2double(imread(strcat('D:\ProcessResult\IRCCyN\EyMIR3D\3d\',no,'.jpg')));
    subplot(3,6,ii);
    imshow(heatmap_overlay(Image, gtimg));
    title(strcat('saliency map overlayed',no));
end