function y= xrand(m,n,r)
% rng('twister')
% s=randi([1,1000],1,1);
% rng(s);
y= r(1)+rand(m,n)*(r(2)-r(1));

return