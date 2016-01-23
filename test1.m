if ~exist('fig','var') || ~exist('ax','var') || ~exist('im','var')
    fig = figure(1);
    set(gcf,'toolbar','none')
    set(gcf,'color',[0.5,0,0])
    clf
    im = imshow(zeros(60,100));
    ax = gca;
    set(ax,'pos',[0,0,1,1])
    
    cam = webcam;
end

ims = zeros(720, 1280, 3, 100);

snapshot(cam); snapshot(cam);
for ii = 1:100
    set(im, 'cdata', [ones(60,ii), zeros(60,(100-ii))])
    drawnow
    %snapshot(cam); snapshot(cam);
    ims(:,:,:,ii) = snapshot(cam);
end