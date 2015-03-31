 clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
closeSerial;

% comPort=('/dev/tty.usbmodem1451'); %arduino com port for mac
comPort=('COM9'); %arduino com port for windows (edit for different ports)

s=serial(comPort);

% set parameters of the arduino
set(s,'DataBits',8);
set(s,'StopBits',1);
set(s,'BaudRate',115200);
set(s,'Parity','none');
set(s,'Terminator', 'CR/LF');
set(s,'InputBufferSize',2048);

fopen(s); % open serial port defined by s

% parameters of the incoming data set
width = 5;
columns = 8;
rows = 64;
num_values = rows*columns;
threshold=300;

GlobalMat=zeros(64,1); % allocate space for global matrix, 64 x 8k, where k is an integer
array = zeros(1, 512); % allocate space for 1-column-512-row matrix

% Give master and slave modules time to boot-up
pause(5);

for j=1:2 % iterate for the number of slave modules are connected to master module
    index = char( num2str(j) ); 
    fwrite(s, index); % index indicates which slave module we're specifying (refer: master .ino file)
    meas = fscanf(s, '%c'); % read in data from serial port and convert to text
    A = strsplit(meas, ' '); % create cell array, A, of data (w/out whitespace)
    
    % go from cell array to matrix (i.e. from A --> array)
    for i=2:513
        array(i-1) = str2double(A(i));
    end

    mat = vec2mat(array,rows); % turn magnitude vector to matrix

    % Flip columns 2, 4, 6, and 8 to account for the different orientation
    % for the two sheets
    mat(:,2) = flipud(mat(:,2));
    mat(:,4) = flipud(mat(:,4));
    mat(:,6) = flipud(mat(:,6));
    mat(:,8) = flipud(mat(:,8));
    
    % Add current sheet's data to the global matrix
    GlobalMat = [GlobalMat,mat];    
end

GlobalMat(:,1)=[]; % remove first column from global matrix (just zeros from initialization

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate image from matrix %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
generate_image_from_mat(GlobalMat,threshold);
        
J = imread('image.jpg','jpg'); % read image from graphics file
BW = im2bw(J); % convert image to binary image

imshow(BW); % display image

    drawnow();
hold on;
        
BW_filled = imfill(BW,'holes'); % fill in holes in 'black' regions, i.e.

boundaries = bwboundaries(BW);
        
[u,v]=size(boundaries);
        
if u>0
    b = boundaries{1};
    plot(b(:,2),b(:,1),'g','LineWidth',3);
    r  = regionprops(BW, 'centroid');
    centroids = cat(1, r.Centroid);
    
    hold on
    plot(centroids(:,1), centroids(:,2), 'b*')
            
    drawnow();
end