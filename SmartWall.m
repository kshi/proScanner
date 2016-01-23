vidinfo = imaqhwinfo;

vid = videoinput(vidinfo.InstalledAdaptors{1},1);
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat',Inf);
set(vid,'ReturnedColorSpace','YCbCr');

start(vid)

background = [];
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
    frame = getdata(vid);
    title(status);
    set(h_display,'cdata',displayImage);
    drawnow;
    flushdata(vid)
    flushdata(wallcam)        
    
end

stop(vid)
flushdata(vid)
clear vid