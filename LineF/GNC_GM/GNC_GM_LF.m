function [model,fit,i] = GNC_GM_LF(src,dst,gnc_factor,noise_bound)
noise_bound_sq=noise_bound^2;
prev_cost=10^15;
mu = 1; maxIter =100;
match_size=size(src,2);
weights=ones(1,match_size);
for i=1:maxIter
    [model,fit]=Linefit(src,dst,weights);
    residuals = abs(fit-dst);
    residuals_sq = residuals.^2;
    if i==1
        max_residual = max(residuals);
        mu = 2*max_residual/noise_bound_sq;
%         if mu<10*noise_bound
%             mu=10*noise_bound;
%         end
    end
    cost = sum(weights.*residuals_sq);
   
    weights = ((mu*noise_bound_sq)./(residuals_sq+mu*noise_bound_sq)).^2;
    cost_diff = abs(cost - prev_cost);

    mu = mu / gnc_factor;
    prev_cost = cost;
    if cost_diff < 1e-3
        break;
    end

end

