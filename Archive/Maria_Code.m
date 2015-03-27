clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
closeSerial;

% comPort=('/dev/tty.usbmodem1451'); %arduino com port for mac
comPort=('COM9'); %arduino com port for windows 

s=serial(comPort);

%set parameters of the arduino
set(s,'DataBits',8);
set(s,'StopBits',1);
set(s,'BaudRate',115200);
set(s,'Parity','none');
set(s,'Terminator', 'CR/LF');
set(s,'InputBufferSize',2048);
fopen(s);
count=0;

%figure(1),clf


%parameters of the incoming data set
width=5;
columns=8;
rows=64;
num_values=rows*columns;
threshold=300;
GlobalMat=zeros(64,1);
blah = zeros(5);    
%allocate space
mag=zeros(1,num_values); 

array=zeros(1,512);

%while true
pause(5);

for j=1:2
    index=char(num2str(j));
   
    fwrite(s,index);
    meas=fscanf(s,'%c');
    
    A = strsplit(meas,' '); %separate the values by space  
   
    %C(~cellfun('isempty',C));
    
    for i=2:513
        array(i-1)=str2double(A(i));
    end
    
    C=array;
    
    
    %C2 = cell2mat(C);
    %C = C(1:end-1);
    
   % if length(C)==rows*columns
        %count=count+1;
       % mag=str2double(C);
       
       

        mat = vec2mat(C,rows)'; %turn magnitude vector to matrix
       % mat = fliplr(mat);
        
        mat(:,2)=flipud(mat(:,2));
        mat(:,4)=flipud(mat(:,4));
        mat(:,6)=flipud(mat(:,6));
        mat(:,8)=flipud(mat(:,8));
        
        %mat=flipud(mat);
        
    GlobalMat=[GlobalMat,mat];    
end

GlobalMat(:,1)=[];
 %%%%IMAGE ZONE       
        
        generate_image_from_mat(GlobalMat,threshold);
        
        J = imread('image.jpeg','jpg');

        BW = im2bw(J);
        
        imshow(BW);
        drawnow();

        hold on;
        
        BW_filled = imfill(BW,'holes');

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
        
%         len=length(centroids);


%         c=clock;
%         Centroid=[];
%         Centroid(1:3)=c(4:6);
%         Centroid(4:4+len-1)=centroids;
% 
%         T=array2table(Centroid, 'VariableNames', {'hour';'minutes';'seconds';'centroidsx';'centroidsy'});
%         %For multiple centroids at different times we can concatenate both tables:
%         %Cent=array2table(Centroid, 'VariableNames', {'hour';'minutes';'seconds';'centroidsx';'centroidsy'})
%         %Tnew=[Cent;T]
% 
%        end
   %end
%end



