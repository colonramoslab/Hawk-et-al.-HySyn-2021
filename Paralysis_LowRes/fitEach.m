function [dXY] = fitEach(X,Y)
%fitEach. Linear fit of x/y data to derive slope, dXY.

% X, Times [frames,Samples]
% Y, dq Value, eg displacement [frames,Samples]

dXY=nan([size(X,2),1]);
for ii=1:size(X,2)
    x=X(:,ii);
    y=Y(:,ii);
    gy=~isnan(y);
    p = polyfit(x(gy),y(gy),1);
    dXY(ii)=p(1);
    
end

