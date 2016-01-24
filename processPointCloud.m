%function [ points_out,colors_out ] = processPointCloud( points_in,colors_in )
% removes non-face points in the point cloud
pz = Points(:,1);
px = Points(:,2);
py = Points(:,3);
remove1 = find(pz < 0.5 | pz > 2 | px < -1.5 | px > 1.5 | py < -1.5 | py > 1.5 | isnan(pz));
Points(remove1,:) = [];
Colors(remove1,:) = [];
[idx,C] = kmeans(Points,3);
faceInd = mode(idx);
pz = Points(:,1);
px = Points(:,2);
py = Points(:,3);
remove2 = find(abs(C(faceInd,1) - pz) > 0.15 | abs(C(faceInd,2) - px) > 0.15 | abs(C(faceInd,3) - py) > 0.15);
Points(remove2,:) = [];
Colors(remove2,:) = [];

