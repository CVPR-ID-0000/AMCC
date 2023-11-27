function [modelLF,fit]=Linefit(x,y,W)

M=[W.*x; W]';
B=(W.*y)';
modelLF=M'*M\(M'*B);
fit = modelLF(1)*x + repmat(modelLF(2),1,size(x,2));




