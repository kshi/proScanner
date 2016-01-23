background = zeros(size(frame));
for i=1:calib_iters
    frame = getdata(vid);
    background = background + double(frame);    
end
background = uint8(background / calib_iters);
fprintf('RGB Background Acquired.\n');