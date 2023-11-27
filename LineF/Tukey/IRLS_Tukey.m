function [fit,model,W]=IRLS_Tukey(x,y,W,iter)
w=W;
for i=1:iter
    [fit,model,W]=Tukey(x,y,W,2.385);
    if max(max(abs(w-W)))<1e-6
        break;
    end
    w=W;
end
