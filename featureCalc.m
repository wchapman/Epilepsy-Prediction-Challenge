function featureCalc()

addpath /media/wchapman/RatBrains/Insync/git/CMBHOME/
if ~isunix
    datapath = 'G:\';
else
    datapath = '/media/wchapman/RatBrains/';
end
d = cell(1,7);
for i=1:7
    d{i} = [datapath  'Kaggle' filesep 'AmericanEpilepsySocietySeizurePredicationChallenge' filesep 'Data' filesep 'Dog_' num2str(i) filesep];
end
for i=1:2
    d{i+7} =  [datapath  'Kaggle' filesep 'AmericanEpilepsySocietySeizurePredicationChallenge' filesep 'Data' filesep 'Patient_' num2str(i) filesep];
end

SL(1).fname = 'nope';

for i = 1:length(d)
    fls = dir(d{i});
    %     keyboard
    %     fls = fls(4:end); Not super sure why this was 4, gonna just remove
    %     files that start with .
    fls = fls(cellfun(@(x)x(1),{fls.name})~='.');
    for k = 1:length(fls)
        SL(end+1).fname = [d{i} fls(k).name];
        SL(end).patientID = i;
        
        if ~isempty(strfind(SL(end).fname,'interictal'))
            SL(end).type = 'interictal';
        elseif ~isempty(strfind(SL(end).fname,'preictal'))
            SL(end).type = 'preictal';
        elseif ~isempty(strfind(SL(end).fname,'test'))
            SL(end).type = 'test';
        else
            error('Bad filename')
        end
    end
end
SL(1) = [];
SL = SL(:);
SL(end).fets = [];

%% Calculate Features:
for i = 1:length(SL)
    tic;
    t=load(SL(i).fname);
    z = fieldnames(t);
    t = t.(z{1});

    featureCalc2(t.data, t.sampling_frequency, i);

    disp(['Done with ' num2str(i) ':  ' num2str(toc*(i/length(SL))) ' remaining'])    
end

end


function fets = featureCalc2(x, fs, rownum)
% assumes each row in x is a channel, each column is a time point

    % TODO
    % long term energy
    % mse AR models

    % spectral edge frequency
    % spectral edge power
    % decorrelation time
    % Hjorth mobility
    % Hjorth complexity
    % energy of wavelet coefficients

    fets.mean = mean(x, 2);
    fets.std = std(x,0,2);
    fets.skewness = skewness(x,1,2);
    fets.kurtosis = kurtosis(x,1,2);


    for j=1:size(x,1)
        %% Jason 
        nchunks = 5;% I think doing 5 chunks in time is probably a good bet.
        freqs = 1:5:120; %1:2:120

        spec = spectro(x(j,:), fs, freqs);
        [fets.fr(j,:), fets.spike_freq{j}, fets.spike_angle{j}] = spikeCalcs(x(j,:), fs, freqs, nchunks, spec);
        [fets.comod{j}, fets.comod_angle{j}, fets.covar_var_exp{j}] = PAC(x(j,:), fs, freqs, nchunks, spec);
        %fets.spec{j} = spec;
        %% Bill
        d = x(j,:)';
        theta = CMBHOME.LFP.BandpassFilter(d, fs, [4 8]); % theta (4-8)
        alpha = CMBHOME.LFP.BandpassFilter(d, fs, [8 15]); % alpha (8-15)
        beta = CMBHOME.LFP.BandpassFilter(d, fs, [15 30]); % beta (15-30)         
        gamma = CMBHOME.LFP.BandpassFilter(d, fs, [30 100]); % gamma (30-200)
        pow = mean(d.^2);

        fets.rp_theta(j) = mean(theta.^2) / pow;
        fets.rp_alpha(j) = mean(alpha.^2) / pow;
        fets.rp_beta(j) = mean(beta.^2) / pow;
        fets.rp_gamma(j) = mean(gamma.^2) / pow;
        fets.power(j) = pow;
    end
 
    for i = 1:size(x,1)
        for j = 1:size(x,1)
            c = corrcoef(x(i,:),x(j,:));
            cc(i,j) = c(1,2);
        end
    end
    
    fets.corrcoef = cc;
    save(['output' filesep 'SL_' num2str(rownum) '.mat'], 'fets'); %save each one in case of crash ... 

end
