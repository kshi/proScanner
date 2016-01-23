%{
Focal Length:          fc = [ 1037.17154   1037.35775 ] ± [ 2.19372   2.19262 ]
Principal point:       cc = [ 534.33411   374.15207 ] ± [ 3.59162   3.22865 ]
Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
Distortion:            kc = [ 0.08420   -0.12560   0.00132   -0.00281  0.00000 ] ± [ 0.00725   0.02230   0.00120   0.00135  0.00000 ]
Pixel error:          err = [ 0.22964   0.23875 ]
%}

% Image Set Parameters
height = 720;
width = 1280;

frames = 100;
step = 2;

[xinds,yinds] = meshgrid(1:width, 1:height);

diff_thresh = 0.9;

diffs = zeros(height, width, 3, frames - step);
midlines = zeros(height, frames - step);
for ii = 1:(frames - step)
    diffs(:,:,:,ii) = (ims(:,:,:,ii+2) - ims(:,:,:,ii))/255;
    change = sum(diffs(:,:,:,ii),3) > diff_thresh;
    coords = xinds.*change;
    
    %midlines(:,ii) = sum(coords,2)./max(sum(change,2), 1);
    
    coords(coords == 0) = NaN;
    midlines(:,ii) = median(coords, 2, 'omitnan');
end
midlines(isnan(midlines)) = 0;

% Camera and Projector Parameters
PPc = [374.1,534.3]; % camera optical center [pixels]
Fc = 1037; % camera focal length [pixels]
%{
PPp = 50; % projector optical center [pixels]
Fp = 200/70*100; % projector "focal length" [pixels]
L = 0.36; % baseline [m]
angle = 0*pi/180; %[rad]
%}
%{
% David and Fifi's faces
PPp = 60;%50; % projector optical center [pixels]
Fp = 52/22*100; % projector "focal length" [pixels]
L = 0.26; % baseline [m]
angle = 15*pi/180; % [rad]
%}
%{a
PPp = 60;%50; % projector optical center [pixels]
Fp = 51/27*100; % projector "focal length" [pixels]
L = 0.26; % baseline [m]
angle = 10*pi/180; % [rad]
%}

% Reconstruction
xs = zeros(height,frames-step);
ys = zeros(height,frames-step);
zs = zeros(height,frames-step);
colors = zeros(height,frames-step,3);

% Creat point cloud
for ii = 1:(frames - step)
    uc = midlines(:,ii) - PPc(2);
    up = -PPp + ii + step/2;
    
    ac = uc/Fc;
    ap = tan(-angle + atan2(up,Fp));
    
    zs(:,ii) = L./(ac - ap);
    xs(:,ii) = uc/Fc .* zs(:,ii);
    ys(:,ii) = (-PPc(1) + (1:height))/Fc .*zs(:,ii)';
    
    im = ims(:,:,:,ii);
    inds = sub2ind([height,width], 1:height, max(round(midlines(:,ii)),1)');
    colors(:,ii,:) = cat(3,im(inds),im(inds+height*width),im(inds+height*width*2));
    
    zs(midlines(:,ii)==0,ii) = NaN;
    xs(midlines(:,ii)==0,ii) = NaN;
    ys(midlines(:,ii)==0,ii) = NaN;
end

colors = reshape(colors,[height*(frames-step),3])/255;

figure(4)
%plot3(zs(:),xs(:),-ys(:),'.')
%axis equal
pts = pcshow([zs(:),-xs(:),-ys(:)],colors,'markersize',50);
xlabel('x')
ylabel('y')
zlabel('z')

set(gca,'xlim',[0,1.5],'ylim',[-.7,.7],'zlim',[-.7,.7])

% Create a surface from point cloud
step_thresh = 0.1;

figure(5)
depth = nan(height,width);
for ii = 2:(frames - step)
    for jj = 1:height
        if (midlines(jj,ii) ~= 0) 
            % Interpolate if consecutive pixels are good
            if (midlines(jj,ii-1) ~= 0)
                inds = [round(midlines(jj,ii-1)), round(midlines(jj,ii))];
                depth(jj,inds(1):inds(2)) = linspace(zs(jj,ii-1),zs(jj,ii),inds(2)-inds(1)+1);
            else
                depth(jj,round(midlines(jj,ii))) = zs(jj,ii);
            end
        end
    end
end

% Remove large jumps
jump_dist = [depth(:,2:end) - depth(:,1:(end-1)), zeros(height,1)];
depth(jump_dist > step_thresh | [zeros(height,1),-jump_dist(:,1:(end-1))] > step_thresh) = NaN;

%depth(isnan(depth)) = max(zs(:));

depthx = bsxfun(@times, (-PPc(2) + (1:width))/Fc, depth);
depthy = bsxfun(@times, (-PPc(1) + (1:height)')/Fc, depth);

surf(depthx,-depthy,-depth,ims(:,:,:,10)/255,'edgealpha',0);
axis equal

set(gca,'xlim',[-.7,.7],'ylim',[-.7,.7],'zlim',[-1.5,0])

%{
% Display line finding
figure(3)
clf
im3 = imshow(zeros(height,width,1));
hold on
line = plot(zeros(1,height),1:height,'r');
hold off
for ii = 1:(frames - step)
    set(im3, 'cdata', sum(diffs(:,:,:,ii),3)>0.9)
    set(line, 'xdata', midlines(:,ii) + midlines(:,ii)./midlines(:,ii)-1)
    title(ii)
    drawnow
    waitforbuttonpress
end
%}


