clear all
[allParameters, txt, raw] = xlsread('../input/AllMeasurements.xlsx');

% index of dia =5
% index of AAA_vol = 8
% index of ILT_vol = 10
indexOfMeasurement=5:26;
indexOfYear=3;
indexOfDia=16;

index=1;
for i=1:length(allParameters(:,1))
    deltaT = allParameters(i,indexOfYear);
    if deltaT ~= 0
        % this is all correlation between the measurements
        parameter_t1=allParameters(i,indexOfMeasurement);
        parameter_t0=allParameters(i-1,indexOfMeasurement);
        deltaParameter=parameter_t1-parameter_t0;
        inputArr(index,1:length(indexOfMeasurement))=deltaParameter/deltaT;
        
        index=index+1;
    end
end


%correlation coefficient
corrMatrix = corr(inputArr,'Type','Spearman');
xlswrite('../output/correlations/RateValueSpearmanCorrelations.csv',corrMatrix)