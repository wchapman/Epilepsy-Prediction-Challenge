%% Run it:
% featureCalc()

%% Concatinate
load(['output' filesep 'SL'])

pid = arrayfun(@(x) x.patientID, SL);
type = arrayfun(@(x) x.type, SL, 'UniformOutput',0);
fets = arrayfun(@(x) x.fets, SL, 'UniformOutput',0);

for i = 1:max(pid)
    inds{i,1} = intersect(find(pid==i),find(strcmp(type,'interictal')));
    inds{i,2} = intersect(find(pid==i),find(strcmp(type,'preictal')));
    inds{i,3} = intersect(find(pid==i),find(strcmp(type,'test')));
end

%% Build decision trees
options = statset('UseParallel',1);
for i = 1:max(pid)
    inter = cell2mat(cellfun(@(x) x(:)', fets(inds{i,1}),'UniformOutput',0));
    pre = cell2mat(cellfun(@(x) x(:)', fets(inds{i,2}),'UniformOutput',0));
    
    labelT = [zeros(size(inter,1),1);ones(size(pre,1),1)];
    
    tree{i} = TreeBagger(1000, [inter;pre], labelT, 'options', options);
end

%% Predict
prob = [];
for i = 1:max(pid)
    [~, predi] = predict(tree{i}, cell2mat(cellfun(@(x) x(:)', fets(inds{i,3}),'UniformOutput',0)));
    prob = [prob;predi(:,2)];
end

% write (thank elliot post for this)
prob = array2table(prob);
SampleSub = readtable(['output' filesep 'sampleSubmission.csv']);
SampleSub(:,2) = prob;
writetable(SampleSub,['output' filesep 'submission_' datestr(now,30) '.csv'])