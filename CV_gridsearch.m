% [train, test] = leave-one-out cross-validation partition
% [alpha, beta] = train_master_curve(train_set)
% [rmse, rse, rsqr] = test_master_curve(test_set, alpa, beta)
clear all;

indexOfMeasurement=22;
interestOfArr = read_and_shuffle_data('../input/AllMeasurements.xlsx', indexOfMeasurement);
% n=20 patients for train, n=5 patients for test. 
trainSet=interestOfArr(1:20,:);
testSet=interestOfArr(21:25,:);

%hyperparameters - not neccessary to find best alpha because it does not
%change prediction.
hyper_alpha=linspace(30,30,1); %ignore its value. 
hyper_beta=linspace(0.004, 0.006,21);
% hyper_beta=linspace(0.0110, 0.0130,21); for AAA vol
[Alpha,Beta] = ndgrid(hyper_alpha, hyper_beta);

% find the best params
[rmse, rse, rsqr] = arrayfun(@(p1,p2) test_master_curve(trainSet,p1,p2), Alpha, Beta);
[val,idx] = min(rmse);
best_alpha = hyper_alpha;
best_beta = Beta(idx);

% find rmse, rse and rsqr for the tuned model
[rmse_test, rse_test, rsqr_test] = test_master_curve(testSet, best_alpha, best_beta);
fprintf(" ERROR rmse: %d, rse: %d and rsqr: %d", rmse_test, rse_test, rsqr_test);
