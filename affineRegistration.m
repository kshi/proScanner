function [ Points,Colors ] = affineRegistration( q,p,qc,pc,manual_correct )
% computes affine transformation mapping points in p to points in q
if (nargin < 5)
    manual_correct = false;
end
addpath('./clickA3DPoint');
addpath('./icp');
[TR,TT] = icp(q',p');
Points = [q; bsxfun(@plus,p*TR',TT')];
Colors = [qc; pc];
if (manual_correct)
    RGBColors = uint8(round(Colors*255));
    figure;
    ptcloud = pointCloud(Points,'Color',RGBColors);
    pcshow(ptcloud);
    fig = gcf;
    title('Press QE to translate in depth and WASD to translate in the plane. Press Z to accept alignment.');
    w = waitforbuttonpress;
    while true
        key = fig.CurrentCharacter;
        transScale = 0.001;
        switch key
            case 'q'
                trans = [-transScale,0,0];
            case 'e'
                trans = [transScale,0,0];
            case 'a'
                trans = [0,-transScale,0];
            case 'd'
                trans = [0,transScale,0];
            case 'w'
                trans = [0,0,transScale];
            case 's'
                trans = [0,0,-transScale];
            case 'z'
                break;
            otherwise
                trans = [0,0,0];
        end
        TT = TT + trans';
        Points = [q; bsxfun(@plus,p*TR',TT')];
        ptcloud = pointCloud(Points,'Color',RGBColors);
        pcshow(ptcloud);
        title('Press QE to translate in depth and WASD to translate in the plane. Press Z to accept alignment.');    
        drawnow;
        w = waitforbuttonpress;
    end
    close;
end
end

