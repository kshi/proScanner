function [ptcloud] = combineTwoViews(p1,c1,p2,c2)
Points = p1;
Colors = c1;
processPointCloud;
p1 = Points;
c1 = Colors;

Points = p2;
Colors = c2;
processPointCloud;
p2 = Points;
c2 = Colors;

[Points,Colors] = affineRegistration(p1,p2,c1,c2);
ptcloud = triangleInterpolate(Points,Colors);
pcshow(ptcloud);
end