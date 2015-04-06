
function [centroids, centroid, angle]=insideArea(T, centroids, centroid, angle)
% once table with all the centroids is found it will go one by one. Needs as input the table T
 %Table structure: hour  minutes    seconds   centroidsx   centroidsy
 length=10; %size of foot
 width=5;   %size of foot

for j=1:size(T,1)
    siz=size(T,1);
    point=[T(siz-j+1,4) T(siz-j+1,5)];  %define point by line being read on the table 
    if j==1                             %if it is the first point
        if exist('centroid','var')==0   %if we input the centroid
            centroid=[T(siz,4), T(siz,5)];   %make it the centroid=point that will define our area we want to be checking
            centroids=centroid;         %matrix that will contain all the centroids that are within the square
        end
                   
       fp=centroid;            %for plotting the first two points
    else
        a=centroid{1,1};                %a is the x of the centroid
        b=centroid{1,2};                %b is the y of the centroid
        x=point{1,1};                   %x is the x coordinate of the point we are looking at in the table
        y=point{1,2};                   %y is the y coordinate of the point we are looking at in the table
        
        if exist('angle','var')==1
        if islogical(angle)==0
            angle
            changey=sin(angle)*2.5;     
                    changex=cos(angle)*2.5;
                    ax=10*sin(angle);
                    by=10*cos(angle);
                    coord1=[a+changex, b+changey]
                    coord2= [a-changex, b-changey]
                    coord3=[coord1(1,1)-ax, coord1(1,2)+by]
                    coord4=[coord2(1,1)-ax, coord2(1,2)+by]
        end
        else
            angle=true;                       %angle will become a double, but in order to easily det if angle was calculated
                                        % or not we will use another
                                        % classtype
            
        end
        
        if height(centroids)==1         %if no point has been added to our centroid besides the first
            if or(or(and(a < x, a+10>x),and(a>x, a-10<x)), a==x)    %check if point we are looking at is 
                                                                    %within a rectangle of 10 by 11
                if or(or(and( b<y, b+11>y), and(b>y, b-11<y)), b==y)
                    centroids=[centroids; point];                   %if it is is then it will be our second point 
                                                                    %that will define the direction of the footstep
                    fp=[fp; point];
                
                    X=(x-a)/(y-b);      %define angle at which the second point is identified
                    
                    angle=atan(X);  
                    %define the 4 points of the rectangle
                    changey=sin(angle)*2.5;     
                    changex=cos(angle)*2.5;
                    ax=10*sin(angle);
                    by=10*cos(angle);
                    coord1=[a+changex, b+changey]
                    coord2= [a-changex, b-changey]
                    'point 2 passed'
                    coord3=[coord1(1,1)-ax, coord1(1,2)+by]
                    coord4=[coord2(1,1)-ax, coord2(1,2)+by]
            
                end
            end
        else
            %if we are not working with the first nor the second point we
            %will use the convex hull idea to check if the point is within
            %the four vertices of the rectangle defined in the end
            xs=[coord1(1,1); coord2(1,1); coord3(1,1); coord4(1,1); point{1,1}];
            ys=[coord1(1,2); coord2(1,2); coord3(1,2); coord4(1,2); point{1,2}];
           
            K=convhull(xs,ys);
            si=size(K);
            mx=0;
            
            for i=1:si(1,1)
                
                if K(i,1)>mx
                    mx=K(i,1);
                
                end
            
            end
            %if convex hull finds only 4 points in the border then the
            %point must be within the rectangle
            if mx==4
                centroids=[centroids; point]
            end
        end
        
         
    end
end

%plotting the points.
if height(centroids)>1
 x=[coord1(1,1); coord2(1,1); coord3(1,1); coord4(1,1)];
 y=[coord1(1,2); coord2(1,2); coord3(1,2); coord4(1,2)];
 k=convhull(x,y); 
 
scatter(centroids{:,1}, centroids{:,2}, 'filled')
hold on;
scatter(T{:,4},T{:,5})
scatter(x(k), y(k))
scatter(fp{:,1}, fp{:,2}, 'b', 'filled')

hold off;

end