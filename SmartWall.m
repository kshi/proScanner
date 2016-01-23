vidinfo = imaqhwinfo;

vid = videoinput(vidinfo.InstalledAdaptors{1},1);
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat',Inf);
set(vid,'ReturnedColorSpace','YCbCr');

start(vid)

displayImage = uint8(zeros(720,1280,3)); %black
h_display = image(displayImage);
set(h_display,'ButtonDownFcn','displayImage = uint8(zeros(720,1280));');
colormap('gray');

Calibrate;
stop(vid)
set(vid,'ReturnedColorSpace','RGB');
start(vid)

displayImage = 200*ones(720,1280,3); %light-ish background color
set(h_display,'cdata',uint8(displayImage));
drawnow;
getBackground;

while false
    frame = getdata(vid);
    diff = double(background) - double(frame);
    diffmagn = sum(diff.^2,3);
    [y,x] = find(diffmagn > 5);
    Z = applyHomography([x,y]',homography);
    outX = find(Z(1,:) < 1 | Z(1,:) > 1280);
    outY = find(Z(2,:) < 1 | Z(2,:) > 720);
    outOfRange = union(outX, outY);
    Z(:,outOfRange) = [];
    y(outOfRange) = [];
    x(outOfRange) = [];
    newDisplayImage = displayImage;
    for i=1:size(Z,2)
       newDisplayImage(round(Z(2,i)),round(Z(1,i)),:) = displayImage(round(Z(2,i)),round(Z(1,i)),:) + sign(diff(y(i),x(i),:));
    end
    displayImage = newDisplayImage;
    set(h_display,'cdata',uint8(displayImage));
    drawnow;
    flushdata(vid)
end

stop(vid)
flushdata(vid)