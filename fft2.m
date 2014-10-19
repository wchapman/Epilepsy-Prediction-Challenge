function [f, MY, Y] = fft2(Fs,y)
    
    L = length(y);                      % Length of signal
    NFFT = 2^nextpow2(L);               % Next power of 2 from length of y
    Y = fft(y,NFFT)/L;                  % fft
    f = Fs/2*linspace(0,1,NFFT/2+1);    % Frequency vector

    Y = Y(1:NFFT/2+1);                  % Single sided
    MY = 2*abs(Y);                      % second half power to first

end