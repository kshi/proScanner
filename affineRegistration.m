function [ Points,Colors ] = affineRegistration( q,p,qc,pc )
% computes affine transformation mapping points in p to points in q
addpath('./icp');
[TR,TT] = icp(q',p');
Points = [q; bsxfun(@plus,p*TR',TT')];
Colors = [qc; pc];
end

