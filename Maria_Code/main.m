
%T=makeCentroid()
%for i=1:5
%    T=makeCentroid(T)
%end
T(1,:);

for j=1:size(T,1)+1
    point=[T(j,4), T(j,5)];
    if j==1
       centroid=[T(1,4), T(1,5)];
       centroids=centroid;
    else
        if or(and(centroid < point(1)(1), centroid+10>point(1)(1)), and(centroid>point(1)(1), centroid-10<point(1)(1)))
            centroids=[centroids, point]
            
            also take into account if j==3 radius is 1/2
        end
    end
end