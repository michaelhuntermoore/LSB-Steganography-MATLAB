%Hunter Moore
%001144074
%Term Project: LSB Text Hiding
clc;
clear;
close all;

%----------Embedding----------

%Get the cover image
inimage = imread('lena.png');
cover = inimage;

%Get message to embed in image
file= fopen('message.txt','rb');
%Save message as a char array
message = fread(file,'char');
%Close file
fclose(file);


%Ensure that the input message does not exceed the size of the cover image
assert(numel(cover) > numel(message)*8, 'ERROR: message is too large for cover image');

%Insert some uncommon character to append to the message text as a
%terminator.
eof = 'þ';
messageText = [message;eof];

%Each character needs to be converted into 8-bit binary form
binary = transpose(dec2bin(messageText,8));
%Find the least-significant bits to be set to one or zero.
zeroBit = find(binary == '0');
oneBit = find(binary == '1');
%Set the values of the least-significant bits
cover(zeroBit) = bitset(cover(zeroBit),1,0);
cover(oneBit) = bitset(cover(oneBit),1,1);

%----------Extraction----------

%Note that output is usually corrupted when noise is introduced.
%Increasing the level of noise increases the level of corruption.
%cover = imnoise(cover,'salt & pepper', 0.0002);

outputMessage = [];
for i = 1:8:numel(cover)
    chars = bitget(cover(i:i+7),1);
    chars = bin2dec(num2str(chars));
    if(chars == eof)
        break;
    else
        outputMessage(end+1) = chars;
    end
    
end
outputMessage = char(outputMessage);
%----------Output----------
figure(1);
subplot(1,2,1);
imshow(inimage);
subplot(1,2,2);
imhist(inimage);
suptitle('Original Image');

figure(2);
subplot(1,2,1);
imshow(cover);
subplot(1,2,2);
imhist(cover);
suptitle ('Image with embedded message');


out = sprintf( 'Input message is: %s\nOutput message is: %s',message,outputMessage);
fprintf(out);

%Use MSE and PSNR to evaluate output
cover = double(cover);
inimage = double(inimage);
MSE = mse(cover,inimage);
out=sprintf('\nMSE: %f',MSE);
fprintf(out);
peaksnr = psnr(cover,inimage);
out=sprintf('\nPSNR: %f',peaksnr);
fprintf(out);
