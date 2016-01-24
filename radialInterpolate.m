Points;
Colors;
addpath('./sphereFit');
[center,~] = sphereFit(Points);
[a,b,r] = cart2sph(Points(:,1),Points(:,2),Points(:,3));
radialInterp = scatteredInterpolant(a,b,r,'natural');
redInterp = scatteredInterpolant(a,b,Colors(:,1),'natural');
blueInterp = scatteredInterpolant(a,b,Colors(:,2),'natural');
greenInterp = scatteredInterpolant(a,b,Colors(:,3),'natural');
u = rand(10000,1);
v = rand(10000,1);
theta = range(a)*u + min(a);
phi = acos(2*v-1) * range(b)/(pi) + min(b);
[X,Y,Z] = sph2cart(u,v, radialInterp(u,v));
interpolatedPoints = [X,Y,Z];
interpolatedColors = [redInterp(u,v), blueInterp(u,v), greenInterp(u,v)];
%FR = scatteredInterpolant(Points,Colors(:,1),'natural','none');
%FG = scatteredInterpolant(Points,Colors(:,2),'natural','none');
%FB = scatteredInterpolant(Points,Colors(:,3),'natural','none');
%FD = scatteredInterpolant(Points,sqrt(sum(bsxfun(@minus,Points,center).^2,2)),'natural','none');

%addpath('./matpcl')
%RGBColors = uint8(round(Colors * 255));
%ptcloud = pointCloud(Points,'Color',RGBColors);
%pcshow(ptcloud);
%savepcd('pcl_points.pcd',[Points'; Colors']);

