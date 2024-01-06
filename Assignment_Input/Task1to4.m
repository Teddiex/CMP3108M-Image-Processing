clear; close all;

% Task 1: Pre-processing -----------------------
% Step-1: Load input image
I = imread('IMG_01.jpg');
figure, imshow(I)

% Step-2: Covert image to grayscale
I_gray = rgb2gray(I);
figure, imshow(I_gray)

% Step-3: Rescale image
J = imresize(I_gray, 0.5, 'bilinear');
figure, imshow(J)
title('Image reiszed to half size via billinear interpolation')
% Step-4: Produce histogram before enhancing
figure, imhist(J, 64);
% Step-5: Enhance image before binarisation
enhancedJ = imadjust(J);
figure , imshow(enhancedJ);
title('Enhanced Image')
% Step-6: Histogram after enhancement
figure, imhist(enhancedJ, 64)
% Step-7: Image Binarisation
BW = imbinarize(enhancedJ, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
BW = imcomplement(BW);
figure, imshow(BW)
% Task 2: Edge detection ------------------------

% Task 3: Simple segmentation --------------------

% Task 4: Object Recognition --------------------