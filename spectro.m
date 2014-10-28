function spec = spectro(x, fs, freqs)
% Calculates the spectrogram

    Wn = 1/(fs/2);
    [bup,aup] = butter(3,Wn,'high');
    y = filtfilt(bup,aup,x);
    
    spec = NaN(length(y), length(freqs));
    for i=1:numel(freqs)
        sigma = 7/(2*pi*freqs(i));
        ts = round(6*sigma*fs);
        ts = (-ts:ts)/fs;
        wvlt = 1/(sigma*sqrt(2*pi))*exp(-ts.^2/(2*sigma^2)).*exp(2*1i*pi*freqs(i)*ts);
        spec(:,i) = conv(y,wvlt,'same');
    end

end