function [comod, comod_angle, covar_var_exp] = PAC(x, fs, freqs, nchunks, spec)
    
    t = ((1:numel(x))-1)/fs;

    comod = zeros(nchunks, length(freqs), length(freqs));
    comod_angle = comod; covar_var_exp = comod;
    
    for i = 1:nchunks
        for j=1:numel(freqs)
            for k=j+1:numel(freqs)
                inds = (t>=range(t)/nchunks*(i-1)&t<range(t)/nchunks*i);
                [b,~,stats] = glmfit(...
                    [sin(angle(spec(inds,j))) cos(angle(spec(inds,j)))],...
                    abs(spec(inds,k)));

                comod(i,j,k) = sqrt(sum(b(2:3).^2));
                comod_angle(i,j,k) = atan2(b(2),b(3));
                covar_var_exp(i,j,k) = 1-sum((stats.resid).^2)/sum((abs(spec(inds,k))-mean(abs(spec(inds,k)))).^2);
            end
        end
    
    end
    
end