function [ptcloud] = combineTwoViews(p1,c1,p2,c2)

[Points,Colors] = affineRegistration(p1,p2,c1,c2);
processPointCloud;
ptcloud = triangleInterpolate(Points,Colors);
pcshow(ptcloud);
end