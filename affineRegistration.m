function [ Points,Colors ] = affineRegistration( q,p,qc,pc )

[TR,TT] = icp(q',p');
Points = [q; bsxfun(@plus,p*TR',TT')];
Colors = [qc; pc];
end

