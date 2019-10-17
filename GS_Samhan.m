%% Description
%title: GS Algorithm
%desc: an IFTA to determine phase distribution in CGH for beam shaping
%author: Muhammad Syahman Samhan
%email: mssamhan@students.itb.ac.id
%adapted from Gerchberg and Saxton (1971)
%developed from 
    %1. Musa Aydin (Sultan Mehmet Vakif University) and 
    %2. Dae Gwang Choi (KAIST, 2019)

%% General Variables
clc
clear all
close all
size = 256;             %pixel size
x = linspace(-10, 10, size);    
y = linspace(-10, 10, size);
[X,Y] = meshgrid(x,y);  %meshgrid for Input Beam and SLM
x0=0; y0=0;             %center of CGH and Input Beam
tilt = 0;               %only if needed later
i_num = 100;             %number of iteration
error = [];             %error array is empty for first


%% Generate Gaussian Input Beam
sigma = 3;                                      %beam waist
A = 1;                                          %input amplitude
theta = ((X-x0).^2 + (Y-y0).^2)./(2*sigma^2);   %phase of Input beam
input = A*exp(-theta);                          %input amplitude for a given position


%% Target Image
Target_Ori = rgb2gray(imread('star.jpg'));  
Target = double(Target_Ori);             %changing the target into matrix of doubles with precision
A = fftshift(ifft2(fftshift(Target)));  %performing GS initialization step, IFFT
% Notes: 2 times fftshift is used to shift the matrix (q1<->q3, q2<->q4)


%% Perform Gerchberg - Saxton (GS) Algorithm (check wikipedia for pseudo code)
for i=1:i_num
    B = abs(input).*exp(1i*angle(A));
    C = fftshift(fft2(fftshift(B)));
    D = abs(Target).*exp(1i*angle(C));
    A = fftshift(ifft2(fftshift(D)));
    error_cur = sum(sum(abs(abs(C) - abs(Target))));
    error = [error; error_cur];
end


%% Show Result
figure %Input Beam Distribution
    imagesc(input), axis image;
    title('Gaussian Input Beam Amplitude Distribution')
    xlabel('x')
    ylabel('y')
    
figure %CGH Phase Distribution Result
    imagesc(abs(A)), axis image, colormap('gray');
    title('CGH phase distribution');
    
figure %Comparison between the original and reconstructed image
    subplot(2,1,1);
    imshow(Target_Ori);
    title('Original image')
    subplot(2,1,2);
    imagesc(abs(C)), axis image, colormap('gray');
    title('Reconstructed image');
    
figure %Error vs iteration
    i = 1:1:i;
    plot(i,(error'));
    title('Error vs Iteration');