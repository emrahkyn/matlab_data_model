% This main script is written for leave-one-out cross validation (LOOCV),
% and normalized cross validation error (cv) are computed for each
% measurements.


% interestOfArr = read_and_shuffle_data (input_file, indexOfMeasurement)
% 
% [train, test] = leave-one-out cross-validation partition
% [alpha, beta] = train_master_curve(train_set)
% [rmse, rse, rsqr] = test_master_curve(test_set, alpa, beta)
clear all;

indexOfMeasurement=11;
interestOfArr = read_and_shuffle_data('../input/AllMeasurements.xlsx', indexOfMeasurement);
% n=20 patients for train, n=5 patients for test. 
interestOfArr=interestOfArr(1:20,:);

% leave one out cross-validation partition 
n = size(interestOfArr, 1);
cv_group=cvpartition(n,"k",n);
% for rmse, rse and r-sqr
results = zeros(n,3);

for i = 1:n
    train_id=cv_group.training(i);
    test_id=cv_group.test(i);
    
    train_set=interestOfArr(train_id,:);
    test_set=interestOfArr(test_id, :);
    
    [alpha, beta] = train_master_curve(train_set);
    fprintf("RUN:%d, training parameters alpha: %d and beta: %d", i, alpha, beta);
    [rmse, rse, rsqr] = test_master_curve(test_set, alpha, beta);
    fprintf(" ERROR rmse: %d, rse: %d and rsqr: %d", rmse, rse, rsqr);
    results(i,:) = [rmse, rse, rsqr];
end

save('../output/rmse_spherical.mat', 'results');
meanval = mean(results);
stdval = std(results);
fprintf("CV: %d, STD: %d", meanval(1), stdval(1));
