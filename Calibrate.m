% Background Calibration
calib_skip = 20;
calib_iters = 30;

[X,Y] = meshgrid(1:size(displayImage,2),1:size(displayImage,1));
calibrationPattern = uint8(zeros(size(displayImage,1),size(displayImage,2),3));
slice = uint8(zeros(size(displayImage,1),size(displayImage,2)));
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

for n=1:calib_skip
    frame = getdata(vid);
    flushdata(vid)
end
flushdata(vid)
background = zeros(size(frame));
for n=1:calib_iters
    frame = getdata(vid);
    background = background + double(frame);
    flushdata(vid)
end
background = uint8(background / calib_iters);
fprintf('Background calibrated.\n');
flushdata(vid)

set(h_display,'cdata',calibrationPattern);
drawnow
pause(2)
flushdata(vid)
frame = getdata(vid);
diff = (double(frame) - double(background)).^2;
dist = diff(:,:,3) + diff(:,:,2);
circles = (dist > 80);
CC = bwconncomp(circles,8);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,I] = sort(numPixels);
I = fliplr(I);

centroids = regionprops(CC,'Centroid');
centroids = cat(1,centroids.Centroid);
centroids = centroids(I(1:25),:);

centroidsSort = sortrows(centroids,1);
for ii = 1:5
    centroidsSort(((ii-1)*5+1):(ii*5),:) = sortrows(centroidsSort(((ii-1)*5+1):(ii*5),:),2);
end

homography = fitHomography(centroidsSort',projectorCentroids);
reverseHomography = fitHomography(projectorCentroids, centroidsSort');

fprintf('Projector calibrated.\n');

homCentroids = applyHomography(centroidsSort',homography);
hold on
h_quality = scatter(homCentroids(1,:),homCentroids(2,:),'o','blue');
hold off
%set(h_display,'cdata',displayImage);
pause(3);
flushdata(vid)
delete(h_quality)