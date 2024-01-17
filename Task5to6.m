clear; close all;

%Set input, output and ground truth folder names
inputFolder_I = 'Assignment_Input';
outputFolder = 'Assignment_Output';
GT_Folder = 'Assignment_GT';

%making output folder
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Task 5: Robust method --------------------------
%+
imageFiles = dir(fullfile(inputFolder_I, '*.jpg'));
GT_Files = dir(fullfile(GT_Folder, '*png'));

%loop through each image and perform the operations
for i = 1:length(imageFiles)
    %read in each image
    I = imread(fullfile(inputFolder_I, imageFiles(i).name));
    I_gray = rgb2gray(I);
    
    J = imresize(I_gray, 0.5, "bilinear");

    enhancedJ = imsharpen(J, radius=2, amount=9);
    
    BW = imbinarize(enhancedJ, "adaptive" , "ForegroundPolarity",'dark','Sensitivity',0.40);
    BW = ~BW;
    
    %Setting structuring elements##
    SEsq = strel('square', 3);
    SErect = strel('rectangle', [3 3]);
    
    %Morphological Operations etc
    I_Dilate = imdilate(BW, SErect);
    I_Remove = bwareaopen(I_Dilate, 60);
    I_Thicken = bwmorph(I_Remove, 'thicken');
    I_Maj = bwmorph(I_Thicken, 'majority');
    I_Filled = imfill(I_Maj, 'holes');
    I_Open = imerode(I_Filled, SEsq);

    I_Seg = medfilt2(I_Open, [6 6]);
    % BW2 = imfilter(BW2, fspecial('average', 3));

    I_Seg = bwareaopen(I_Seg, 30);

    
    [L, num] = bwlabel(I_Seg);

    stats = regionprops('table', L, 'Perimeter', 'Area', 'Circularity');
    washerCircularityThreshold = 0.90;
    longScrewAreaThreshold = 1500;
    

    %no idea why, but if I use 1,2 and 3, they do not get classified
    %correctly??
    for j=1:height(stats)
        if stats.Circularity(j) > washerCircularityThreshold
            L(L == j) = 20;
        elseif (stats.Area(j) > longScrewAreaThreshold)
            L(L == j) = 21;
        else
            L(L == j) = 22;
        end
    end
   
    %so I have to do it down here?? but it works in the other image
    %task1-4?

    %Set label for washer, long screw and short screw.
    L(L == 20) = 1; %washer
    L(L == 21) = 3;%long screw
    L(L == 22) = 2;%short screw

    rgb_label = label2rgb(L,'prism', 'k', 'shuffle');
    figure, imshow(rgb_label);
    title(['Processed Image: ', num2str(i)]);
    %writing processed images to separate folder.
    [~, baseName, ext] = fileparts(imageFiles(i).name);
    outputFile = fullfile(outputFolder, [baseName '_processed' ext]);
    imwrite(rgb_label, outputFile);

    %Reading in ground truth images
    GT = imread(fullfile(GT_Folder, GT_Files(i).name));
    %Creating label for GT image
    L_GT = label2rgb(GT, 'prism','k','shuffle');
    figure, imshow(L_GT), title(['GT Image: ', num2str(i)]);
    

    TP = sum((GT == L) & (GT == 1 | GT == 2 | GT == 3));  % True Positives
    TN = sum(GT == L & GT == 0);  % True Negatives
    FP = sum(GT ~= L & L ~= 0);  % False Positives
    FN = sum(GT ~= L & GT ~= 0);  % False Negatives

    %Convert to logical for dice score
    logical_L = logical(rgb_label);
    logical_GT = logical(L_GT);

    Dice_score = dice(logical_L, logical_GT);
    Precision = TP/(TP+FP);
    Recall = TP/(TP+FN);
    
    disp(" ");
    disp("Image " + i + ": ");

    disp("Dice Score: " + Dice_score);
    disp("Precision: "+ Precision);
    disp("Recall: "+ Recall);

end
