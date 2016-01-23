% Background Calibration
calib_skip = 20;
calib_iters = 30;
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

homography = fitHomography(centroidsSort', projectorCentroids);

fprintf('Projector calibrated.\n');

homCentroids = applyHomography(centroidsSort',homography);
hold on
h_quality = scatter(homCentroids(1,:),homCentroids(2,:),'o','blue');
hold off
%set(h_display,'cdata',displayImage);
pause(2);
flushdata(vid)
delete(h_quality)