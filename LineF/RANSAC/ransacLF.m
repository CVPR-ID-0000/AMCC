
function [x_,model, inliers,iter] = ransacLF(x1, x2, t,method)

    if ~all(size(x1)==size(x2))
        error('Data sets x1 and x2 must have the same dimension');
    end
    
    [rows,npts] = size(x1);
    if rows~=1
        error('x1 and x2 must have 1 rows');
    end
    
    if npts < 2
        error('Must have at least 2 points to fitTING');
    end
       
    s = 2;  % Minimum No of points needed to fit a model
    
    fittingfn = @lineF;
    distfn    = @LineDis;
    % x1 and x2 are 'stacked' to create a 6xN array for ransac
    [M, inliers,iter] = ransac([x1; x2], fittingfn, distfn, s, t,method);
    model=lineF(x1(:,inliers),x2(:,inliers));
    x=[x1; x2];
    inliers =LineDis(model, x, t);
    x_=model(1)*x1+repmat(model(2),1,size(x1,2));
end
%----------------------------------------------------------------------
% Function to evaluate the symmetric transfer error of a homography with
% respect to a set of matched points as needed by RANSAC.

function [inliers, model] = LineDis(model, xy, maxDistance)

x = xy(1,:);   % Extract x1 and x2 from x
y = xy(2,:);

% Calculate, in both directions, the transfered points
d=abs(y - (model(1)*x+model(2)));
inliers = find(d< maxDistance);
end