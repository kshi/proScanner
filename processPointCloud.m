function [ points_out,colors_out ] = processPointCloud( points_in,colors_in )
% removes non-face points in the point cloud
pz = points_in(:,1);
px = points_in(:,2);
py = points_in(:,3);
remove1 = find(pz < 0.5 | pz > 1.5 | px < -1.5 | px > 1.5 | py < -1.5 | py > 1.5 | isnan(pz));
points_out = points_in;
colors_out = colors_in;
points_out(remove1,:) = [];
colors_out(remove1,:) = [];
[idx,C] = kmeans(points_out,3);
faceInd = mode(idx);
pz = points_out(:,1);
px = points_out(:,2);
py = points_out(:,3);
remove2 = find(abs(C(faceInd,1) - pz) > 0.15 | abs(C(faceInd,2) - px) > 0.15 | abs(C(faceInd,3) - py) > 0.15);
points_out(remove2,:) = [];
colors_out(remove2,:) = [];
end

