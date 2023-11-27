function [fit,model,w]=Tukey(src,dst,weights,u)
[model,fit]=Linefit(src,dst,weights);
E=abs(fit-dst);
kRob=median(E);
kRob=u*kRob;
% w=(1-(E./kRob).^2).^2;
% w(1-(E./kRob).^2<0)=0;
w=exp(-(E./kRob).^2);

