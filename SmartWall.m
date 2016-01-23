vidinfo = imaqhwinfo;

vid = videoinput(vidinfo.InstalledAdaptors{1},1);
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat',Inf);
set(vid,'ReturnedColorSpace','YCbCr');

start(vid)

background = [];
backgroundWall = [];
wallBoundary = 0;
homography = [];

displayImage = uint8(zeros(600,800));
[X,Y] = meshgrid(1:size(displayImage,2),1:size(displayImage,1));
calibrationPattern = uint8(zeros(size(displayImage,1),size(displayImage,2),3));
slice = uint8(zeros(size(displayImage)));
projectorCentroids = [];

for x=-2:2
    for y=-2:2        
        centerX = size(displayImage,2) / 2 + x*100;
        centerY = size(displayImage,1) / 2 + y*100;
        slice( (X - centerX).^2 + (Y - centerY).^2 < 1600 ) = 255;
        projectorCentroids = [projectorCentroids, [centerX; centerY]];
    end
end
calibrationPattern(:,:,1) = slice;

h_display = image(displayImage);
set(h_display,'ButtonDownFcn','displayImage = uint8(zeros(600,800));');
colormap('gray');

Calibrate;

%backgroundWall = imresize(backgroundWall,0.25,'bilinear');
%wallBoundary = round(wallBoundary * 0.25) + 1;

%last = [NaN,NaN];

while false
    wallFrame = getdata(wallcam);
    frame = getdata(vid);
    
    diff = (double(wallFrame) - double(backgroundWall)).^2;
    dist = diff(:,:,3) + diff(:,:,2);
    pointer = (dist > 40);
    z = getWallIntersection(pointer);

    diff = (double(frame) - double(background)).^2;
    dist = diff(:,:,3) + diff(:,:,2);
    person = (dist > 50);    
    CC = bwconncomp(person,8);    
    [x,y] = detectFingerTip(CC);
    %density = computeDensity(CC,x,y);
    
    if z >= wallBoundary
        status = strcat(num2str(wallBoundary - z), ' from wall');
    else
        status = 'touching wall'; 
    end
    
    if z < wallBoundary% && density < 0.33
        status = strcat(status, ', detecting fingertip at [',num2str(x),',',num2str(y),']');
        Z = applyHomography([x;y],homography);
        x = round(Z(1));
        y = round(Z(2));
        
        if (x <= 800 && x > 0 && y <= 600 && y > 0)
            displayImage( max(y-2,1):min(y+2,size(displayImage,1)), max(x-2,1):min(x+2,size(displayImage,2)) ) = 255;
%             if (~isnan(last(1)) && abs(x-last(1)) < 200 && abs(y-last(2)) < 200)                
%                 alpha=repmat([0.1:0.02:0.9],2,1);
%                 interpolants = round(bsxfun(@times,[x;y],alpha) + bsxfun(@times,[last(1);last(2)],1-alpha));
%                 interpolants(:,interpolants(1,:)<=0 | interpolants(2,:)<=0 | interpolants(1,:) > 800 | interpolants(2,:) > 600) = [];
%                 pixelInds = sub2ind(size(displayImage),interpolants(2,:),interpolants(1,:));
%                 newPixels = uint8(zeros(size(displayImage)));
%                 newPixels(pixelInds) = 255;
%                 newPixels = imdilate(newPixels,[0,1,1,0;1,1,1,1;1,1,1,1;0,1,1,0]);
%                 displayImage = displayImage + newPixels;
%             end
%             last = [x,y];
%        else
%            last = [NaN,NaN];
        end        
%    else
%        last = [NaN, NaN];
    end
    title(status);
    set(h_display,'cdata',displayImage);
    drawnow;
    flushdata(vid)
    flushdata(wallcam)        
    
end

stop(vid)
stop(wallcam)
flushdata(vid)
flushdata(wallcam)