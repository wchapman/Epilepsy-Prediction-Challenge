function [fr, spike_freq, spike_angle] = spikeCalcs(x, fs, freqs, nchunks, spec)
    
    %% Find "Spikes"
    Wn = 120/(fs/2);
    [bup,aup] = butter(3,Wn,'high');
    y = filtfilt(bup,aup,x);
    
    t = ((1:numel(y))-1)/fs;
    [~,inds] = findpeaks((y>=std(y)*3).*y);
    bino_sig = 0*t;
    bino_sig(inds) = 1;
    spk_ts = t(inds);
    
    %% Something?
    fr = zeros(nchunks,1);
    spike_freq = zeros(nchunks, length(freqs));
    spike_angle = zeros(nchunks, length(freqs));
    for i = 1:nchunks
        fr(i) = sum(spk_ts>=range(t)/nchunks*(i-1)&spk_ts<range(t)/nchunks*i)*nchunks/range(t);% ictal spike frequency in window - STORE IN FETS
        
        % Spike frequency as a logistic fit (change in log-odds)
        for j=1:numel(freqs)
            [b] = glmfit(...
                [sin(angle(spec(t>=range(t)/nchunks*(i-1)&t<range(t)/nchunks*i,j))) cos(angle(spec(t>=range(t)/nchunks*(i-1)&t<range(t)/nchunks*i,j)))],...
                bino_sig(t>=range(t)/nchunks*(i-1)&t<range(t)/nchunks*i)'...
                ,'binomial');
            spike_freq(i,j) = sqrt(sum(b(2:3).^2));
            spike_angle(i,j) = atan2(b(2),b(3));            
        end
    
    end
end