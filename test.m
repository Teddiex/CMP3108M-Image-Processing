clear; close all;

inputFolderI = 'Assignment_Input';
outputFolder = 'Assignment_Output';

%making output folder
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Task 5: Robust method --------------------------

%unfinished
imageFiles = dir(fullfile(inputFolderI, '*.jpg'));
for i = 1:length(imageFiles)
I = imread(fullfile(inputFolderI, imageFiles(i).name));
I_gray = rgb2gray(I);
J = imresize(I_gray, 0.5, "bilinear");
enhancedJ = imsharpen(J, radius=2, amount=15);
edgeI = edge(enhancedJ, 'sobel');

se = strel('disk' , 1);
se2 = strel('disk' , 2);
seoct = strel('octagon', 3);
se3 = strel('disk', 4);

T = adaptthresh(enhancedJ, 0.9);

BW = imbinarize(enhancedJ, T);
BW = ~BW;

filled = imfill(BW, 'holes');
dilated = imclose(filled, se3);
filled = imfill(dilated, 'holes');
open = bwareaopen(filled, 150);
morph = bwmorph(open, 'majority');
morph2 = bwmorph(morph, 'thicken');
morph3 = imerode(morph2, se3);

sep = morph2 - morph3;

% Process each connected component individually


% dilated = imclose(BW, se);
% filled = imfill(dilated , 'holes');
% open = bwareaopen(filled, 150);
% morph = bwmorph(open, 'majority');
% morph2 = bwmorph(morph, 'shrink');
% morph3 = bwmorph(morph2, 'thicken');


I_Dilated = imdilate(edgeI, se);
I_Filled = imfill(I_Dilated, 'holes');
I_Erode = imerode(I_Filled, se2);
I_Seg = bwareaopen(I_Erode, 50);

figure , imshow(sep);

% L = watershed(~I_Seg);
% Lrgb = label2rgb(L);
% imshow(Lrgb);
% 
% D = -bwdist(~I_Seg);
% imshow(D,[]);
% 
% Ld = watershed(D);
% 
% bw2 = I_Seg;
% bw2(Ld==0) = 0;
% 
% mask = imextendedmin(D,2);
% figure, imshowpair(I_Seg,mask,'blend')
% 
% D2 = imimposemin(D,mask);
% Ld2 = watershed(D2);
% bw3 = I_Seg;
% bw3(Ld2 == 0) = 0;
% figure, imshow(bw3)
end