%Hunter Moore
%001144074
%Term Project: LSB Image Hiding
clc;
clear;
close all;

%This program can accept color images as inputs
%However, outputs will be grayscale.


%-----Embedding-----
inimage = imread('Falcon.jpg');
cover = inimage;
hiddenImage = imread('lena.png');
figure(1);
subplot(1,2,1);
imshow(inimage);
subplot(1,2,2);
imshow(hiddenImage,[]);
suptitle('Original Image and Hidden Image');

[row,col,chan] = size(cover);
%Check if cover image is RGB or grayscale
%Use only the red channel for color images.
if chan > 1
    coverRed=cover(:,:,1);
end


[hrow,hcol,hchan] = size(hiddenImage);
%Check if hidden image is RGB or grayscale
%Use only the red channel for color images.
if hchan > 1
    hiddenImage=hiddenImage(:,:,1);
end
%Generate a binary image with the given threshold to define the watermark.
threshold = 150;
binaryImage = hiddenImage < threshold;
figure(2),imshow(binaryImage,[]);
title('Thresholded Hidden Image');

%Set the target bitplane.
BP=input('please select the target bitplane: ','s') ;
BP=str2double(BP);
%Rescale hidden image in scenarios where it is larger than the cover image
if hrow > row || hcol > col
    scale = min([row/hrow,col/hcol]);
    binaryImage = imresize(binaryImage,scale);
    [hrow, hcol] = size(binaryImage);
end

%For scenarios where the hidden image is smaller than the cover image, tile
%the hidden image across the cover image.
if hrow < row || hcol < col
    wm = zeros(size(cover),'uint8');
    for y = 1:col
        for x =1:row
            wm(x,y)=binaryImage(mod(x,hrow)+1,mod(y,hcol)+1);
        end
    end
    wm = wm(1:row,1:col);
else
    %When watermark and cover image are the same size
    wm = binaryImage;
end
figure(3),imshow(wm,[]);
title('Generated Watermark');

%Generate watermarked image
wmImage = cover;
for z = 1:chan
for y= 1:col
    for x = 1:row
        wmImage(x,y,z) = bitset(cover(x,y),BP,wm(x,y));
    end
end
end
figure(4),imshow(wmImage,[]);
title('Watermarked Image');

%Generate a noisy watermarked image
wmImageNoise = imnoise(wmImage,'gaussian',.02);
figure(5),imshow(wmImageNoise);
title('Noisy Watermarked Image');
%-----Extraction-----

%Initialize the size of extracted watermarks from noisy and noiseless
%images
extWM = zeros(size(wmImageNoise));
extWMNoise = zeros(size(wmImageNoise));
for z = 1:chan
for y = 1:col
    for x = 1:row
        %Extract the watermarks
        extWM(x,y,z) = bitget(wmImage(x,y),BP);
        extWMNoise(x,y,z)=bitget(wmImageNoise(x,y),BP);
    end
end
end
%Rescale extracted watermarks.
extWM = uint8(255 * extWM);
extWMNoise = uint8(255 * extWMNoise);

%Display output extracted watermarks
figure(6);
imshow(extWM,[]);
figure(7);
imshow(extWMNoise,[]);


%Evaluate Output using MSE and PSNR
wmImage = double(wmImage);
wmImageNoise = double(wmImageNoise);
inimage = double(inimage);
MSE1 = mse(wmImage,inimage);
out=sprintf('\nMSE of noiseless watermarked image: %f',MSE1);
fprintf(out);
peaksnr1 = psnr(wmImage,inimage);
out=sprintf('\nPSNR of noiseless watermarked image: %f',peaksnr1);
fprintf(out);

MSE2 = mse(wmImageNoise,inimage);
out=sprintf('\nMSE of noisy watermarked image: %f',MSE2);
fprintf(out);
peaksnr2 = psnr(wmImageNoise,inimage);
out=sprintf('\nPSNR of noiseless watermarked image: %f',peaksnr2);
fprintf(out);


