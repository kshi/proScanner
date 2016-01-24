function [ Points,Colors ] = affineRegistration( q,p,qc,pc,manual_correct )
% computes affine transformation mapping points in p to points in q
if (nargin < 5)
    manual_correct = false;
end
addpath('./icp');
addpath('./sphereFit');
[TR,TT] = icp(q',p');
Points = [q; bsxfun(@plus,p*TR',TT')];
Colors = [qc; pc];
if (manual_correct)
    RGBColors = uint8(round(Colors*255));
    figure;
    ptcloud = pointCloud(Points,'Color',RGBColors);
    pcshow(ptcloud);
    fig = gcf;
    ax = gca;
    CameraPosition = ax.CameraPosition;
    CameraViewAngle = ax.CameraViewAngle;
    CameraUpVector = ax.CameraUpVector;    
    title('Press QE to translate in depth, WASD to translate in the plane, and JKRIUO to rotate. Press Z to accept alignment.');
    w = waitforbuttonpress;
    manualRot = eye(3);
    while true
        key = fig.CurrentCharacter;
        transScale = 0.001;
        rotScale = 1;
        trans = [0,0,0];
        rot = eye(3);
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
                trans = [0,0,-transScale];
            case 's'
                trans = [0,0,transScale];
            case 'z'
                break;
            case 'u'
                rot = rotx(rotScale);
            case 'o'
                rot = rotx(-rotScale);
            case 'k'
                rot = roty(-rotScale);
            case 'i'
                rot = roty(rotScale);
            case 'j'
                rot = rotz(-rotScale);
            case 'l'
                rot = rotz(rotScale);
        end
        TT = TT + trans';
        manualRot = rot * manualRot;
        warpPoints = bsxfun(@plus,p*TR',TT');
        [center,~] = sphereFit(q);
        warpPoints = bsxfun(@plus,bsxfun(@minus,warpPoints,center)*manualRot',center);
        Points = [q; warpPoints];        
        ptcloud = pointCloud(Points,'Color',RGBColors);
        CameraPosition = ax.CameraPosition;
        CameraViewAngle = ax.CameraViewAngle;
        CameraUpVector = ax.CameraUpVector;
        pcshow(ptcloud);
        title('Press QE to translate in depth, WASD to translate in the plane, and JKRIUO to rotate. Press Z to accept alignment.');    
        drawnow;
        ax.CameraPosition = CameraPosition;
        ax.CameraViewAngle = CameraViewAngle;
        ax.CameraUpVector = CameraUpVector;
        w = waitforbuttonpress;
    end
    close;
end
end

