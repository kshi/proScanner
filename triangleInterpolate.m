function [ptcloud] = triangleInterpolate(Points, Colors)
Z = Points(:,1);
X = Points(:,2);
Y = Points(:,3);
R = Colors(:,1);
G = Colors(:,2);
B = Colors(:,3);
TRI = delaunay(Z,X,Y);
interpolatedPoints = [mean(Z(TRI),2), mean(X(TRI),2), mean(Y(TRI),2)];
interpolatedColors = [mean(R(TRI),2), mean(G(TRI),2), mean(G(TRI),2)];
reconPoints = [Points; interpolatedPoints];
reconColors = [Colors; interpolatedColors];
RGBColors = uint8(round(reconColors * 255));
ptcloud = pointCloud(reconPoints,'Color',RGBColors);
%pcshow(ptcloud);
end