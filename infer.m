% This script shows how the already trained system can be used. When the system is trained,
% its state is saved in .mat files. When the system is then run from here these are reloaded.
% Input: a csv file with class metrics for a repo, with the corresponding entry in the
% 'repositories.csv' index (without the stars and the forks of course).
% NOTE: the initial csv syntax was not easy to import, so use the bash scripts provided to filter it.

% The input repo name (assuming the csv file is named in the convention of the training samples)
input= 'bigbluebutton';

% Load the data
reader= DataReader;
class_metrics= reader.load(input,'Class');

% Use the previously trained system to infer the reusability for each class
system= model.System;
class_reusability= system.infer(class_metrics);

% The reusability scores are now contained in class_reusability
figure, histogram(class_reusability);
% If many reusability scores are exactly zero, the corresponding classes have been rejected
% by the model as of either low quality or having metrics outside the expected range (SVM)
