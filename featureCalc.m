function fets = featureCalc()

addpath ~/Documents/git/CMBHOME/
d{1} = '/Volumes/BillExternal/Kaggle/AmericanEpilepsySocietySeizurePredicationChallenge/Data/Dog_1/';
d{2} = '/Volumes/BillExternal/Kaggle/AmericanEpilepsySocietySeizurePredicationChallenge/Data/Dog_2/';
d{3} = '/Volumes/BillExternal/Kaggle/AmericanEpilepsySocietySeizurePredicationChallenge/Data/Dog_3/';
d{4} = '/Volumes/BillExternal/Kaggle/AmericanEpilepsySocietySeizurePredicationChallenge/Data/Dog_4/';
d{5} = '/Volumes/BillExternal/Kaggle/AmericanEpilepsySocietySeizurePredicationChallenge/Data/Dog_5/';
d{6} = '/Volumes/BillExternal/Kaggle/AmericanEpilepsySocietySeizurePredicationChallenge/Data/Patient_2/';
d{7} = '/Volumes/BillExternal/Kaggle/AmericanEpilepsySocietySeizurePredicationChallenge/Data/Patient_1/';


SL(1).fname = 'nope';

for i = 1:length(d)
    fls = dir(d{i});
    fls = fls(4:end);
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
%parfor_progress(length(SL))
bads = [];
for i = 1:length(SL)
    try
        t=load(SL(i).fname);
        z = fieldnames(t);
        t = t.(z{1});

        SL(i).fets = featureCalc(t.data, t.sampling_frequency);
        %parfor_progress;
        i
    catch
        bads = [bads i];
        SL(i).fets = [];
    end
end
%parfor_progress(0);

% saveit:
save(['output' filesep 'SL.mat'], 'SL')

end


function subunc(x, fs)
    % assumes each row in x is a channel, each column is a time point
    fets(:,1) = mean(x, 2);
    fets(:,2) = std(x,0,2);
    fets(:,3) = skewness(x,1,2);
    fets(:,4) = kurtosis(x,1,2);
    % long term energy
    % mse AR models
    for k = 1:size(x,1)
    d = x(k,:)';
        % delta (0.1 - 0.4) (relative power)
        theta{k} = CMBHOME.LFP.BandpassFilter(d, fs, [4 8]); % theta (4-8)
        alpha{k} = CMBHOME.LFP.BandpassFilter(d, fs, [8 15]); % theta (8-15)
        beta{k} = CMBHOME.LFP.BandpassFilter(d, fs, [15 30]); % theta (15-30)
        gamma{k} = CMBHOME.LFP.BandpassFilter(d, fs, [30 100]); % theta (30-200)
        pow(k) = mean(d.^2);
        
        rp = [mean(theta{k}.^2) mean(alpha{k}.^2) mean(beta{k}.^2) mean(gamma{k}.^2)] / pow(k);
        fets(k, 5:8) = rp;
    end

    % observation: cross correlations not modulated by theta, but
    % autocorrelations are.
    
    % spectral edge frequency
    % spectral edge power
    % decorrelation time
    % Hjorth mobility
    % Hjorth complexity
    % energy of wavelet coefficients
end