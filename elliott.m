%% Kaggle American Epilepsy Society Seizure Prediction Challenge
% MATLAB Code written by Elliot Dawson
% email: ejdawson@student.unimelb.edu.au
% This script is heavily reliant on the FeatureEngineer2 function written by Elliot Dawson
% Requirements: MATLAB 2013b or higher (for the import of the sample
% submission as a table and writing of the submission as well as the
% parallel computing toolbox and the statistics toolbox
%% Import sample data with the FeatureEngineer2 function
% Note you will need to change the directory in the following statement
[preictalTrainDog1, interIctalTrainDog1, testDog1] = FeatureEngineer2('D:\Seizure2\Dog_1\');
[preictalTrainDog2, interIctalTrainDog2, testDog2] = FeatureEngineer2('D:\Seizure2\Dog_2\');
[preictalTrainDog3, interIctalTrainDog3, testDog3] = FeatureEngineer2('D:\Seizure2\Dog_3\');
[preictalTrainDog4, interIctalTrainDog4, testDog4] = FeatureEngineer2('D:\Seizure2\Dog_4\');
[preictalTrainDog5, interIctalTrainDog5, testDog5] = FeatureEngineer2('D:\Seizure2\Dog_5\');
[preictalTrainHuman1, interIctalTrainHuman1, testHuman1] = FeatureEngineer2('D:\Seizure2\Patient_1\');
[preictalTrainHuman2, interIctalTrainHuman2, testHuman2] = FeatureEngineer2('D:\Seizure2\Patient_2\');
% Now concatenate these matrices for training
trainDog1 = vertcat(preictalTrainDog1, interIctalTrainDog1);
trainDog2 = vertcat(preictalTrainDog2, interIctalTrainDog2);
trainDog3 = vertcat(preictalTrainDog3, interIctalTrainDog3);
trainDog4 = vertcat(preictalTrainDog4, interIctalTrainDog4);
trainDog5 = vertcat(preictalTrainDog5, interIctalTrainDog5);
trainHuman1 = vertcat(preictalTrainHuman1, interIctalTrainHuman1);
trainHuman2 = vertcat(preictalTrainHuman2, interIctalTrainHuman2);
%% Now let's build a decision trees to determine whether or not a seizure is occuring in each subject
% Use the statset function to allow the decision trees to be built in
% parallel instead of just using one core
options  = statset('UseParallel', true);
% Start building the decision trees
Dog1SeizureTree = TreeBagger(1000, trainDog1(:,2:size(trainDog1,2)), trainDog1(:,1), 'options', options);
Dog2SeizureTree = TreeBagger(1000, trainDog2(:,2:size(trainDog2,2)), trainDog2(:,1), 'options', options);
Dog3SeizureTree = TreeBagger(1000, trainDog3(:,2:size(trainDog3,2)), trainDog3(:,1), 'options', options);
Dog4SeizureTree = TreeBagger(1000, trainDog4(:,2:size(trainDog4,2)), trainDog4(:,1), 'options', options);
Dog5SeizureTree = TreeBagger(1000, trainDog5(:,2:size(trainDog5,2)), trainDog5(:,1), 'options', options);
Human1SeizureTree = TreeBagger(1000, trainHuman1(:,2:size(trainHuman1,2)), trainHuman1(:,1), 'options', options);
Human2SeizureTree = TreeBagger(1000, trainHuman2(:,2:size(trainHuman2,2)), trainHuman2(:,1), 'options', options);
%% Now predict on the hold out set
[~, Dog1Predictions] = predict(Dog1SeizureTree, testDog1);
[~, Dog2Predictions] = predict(Dog2SeizureTree, testDog2);
[~, Dog3Predictions] = predict(Dog3SeizureTree, testDog3);
[~, Dog4Predictions] = predict(Dog4SeizureTree, testDog4);
[~, Dog5Predictions] = predict(Dog5SeizureTree, testDog5);
[~, Human1Predictions] = predict(Human1SeizureTree, testHuman1);
[~, Human2Predictions] = predict(Human2SeizureTree, testHuman2);
% Now take the column where the probability is given for positive
Dog1Predictions = Dog1Predictions(:,2);
Dog2Predictions = Dog2Predictions(:,2);
Dog3Predictions = Dog3Predictions(:,2);
Dog4Predictions = Dog4Predictions(:,2);
Dog5Predictions = Dog5Predictions(:,2);
Human1Predictions = Human1Predictions(:,2);
Human2Predictions = Human2Predictions(:,2);
%% Write the predictions to file
% Now concatenate and save these predictions to file
Predictions = vertcat(Dog1Predictions, Dog2Predictions, Dog3Predictions, Dog4Predictions, Dog5Predictions, Human1Predictions, Human2Predictions);
Predictions = array2table(Predictions);
SampleSub = readtable('D:\Seizure2\sampleSubmission.csv');
SampleSub(:,2) = Predictions;
writetable(SampleSub, 'D:\Seizure2\BenchmarkSubmission.csv');