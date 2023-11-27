function [model,fit,i] = MCC_LF(x,ytotal)
En0=1e10;
w = ones(1,size(x,2));
for i=1:100
    [model,fit]=Linefit_MCC(x,ytotal,w);
    E=abs(fit-ytotal);
    sigma_E = std(E);
    Q1 = quantile(E,0.25);
    Q3 = quantile(E,0.75);
    r = (Q3-Q1)/1.34;
    sigma = 1.06*min(sigma_E,r)*size(E,2)^(-0.2);
    w = exp(-E.^2./(2*sigma^2));
    En = sum(w.*E.^2);
    if abs(En-En0)<1e-3
        break;
    end
    En0 = En;
end