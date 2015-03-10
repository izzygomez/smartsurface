function T=makeCentroidT(T)
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
workspace;  % Make sure the workspace panel is showing.
Matrix=randomFootstep(64, 8, 10, 5);
J = imread('randomFootstep.jpeg','jpg');
BW = im2bw(J);
imshow(BW)
 
hold on;
 
BW_filled = imfill(BW,'holes');
 
boundaries = bwboundaries(BW);

b = boundaries{1};
plot(b(:,2),b(:,1),'g','LineWidth',3);

s  = regionprops(BW, 'centroid');
centroids = cat(1, s.Centroid);
imshow(BW)
hold on
plot(centroids(:,1), centroids(:,2), 'b*')
hold off

len=length(centroids);
c=clock;
Centroid=[];
Centroid(1:3)=c(4:6);
Centroid(4:4+len-1)=centroids;
if exist('T', 'var') == 0
    T=array2table(Centroid, 'VariableNames', {'hour';'minutes';'seconds';'centroidsx';'centroidsy'});
else
    Cent=array2table(Centroid, 'VariableNames', {'hour';'minutes';'seconds';'centroidsx';'centroidsy'});
    T=[Cent;T]
end 
writetable(T, 'centroidTable.xls');
 
