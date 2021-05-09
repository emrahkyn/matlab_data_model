clear all
[allParameters, txt, raw] = xlsread('../input/AllMeasurements.xlsx');

%Patient id from 6 to 25 for training and testing (n=20)
%allParameters=allParameters(1:5,:);

% the location of the measurement that we are interested in, years
% between consecutive scans and patient id

%5: Diameter
%6: area fraction
%8: AAA_volume
%11: ecc_maxdia
%13: maximum orthogonal perimeter
%14: global maximum orthogonal diameter
%22: global maximum axial diameter
%15: globmindia
%16: per_maxdia_orthogonal
%17: tort_cl
%21: globalmax_per
%24: axial per max dia

indexOfMeasurement=5;
indexOfYear=3;
indexOfPatientID=1;

%normalized first the measurement
%it does not make sense
%allParameters(:,indexOfMeasurement)=normc(allParameters(:,indexOfMeasurement));

% parse the excel file and grouped by patient id
j=1;
index=1;
tmp_years=zeros(10,1);
tmp_measure=zeros(10,1);
for i=1:length(allParameters(:,1))-1  
    if strcmp(txt(i+2,indexOfPatientID),txt(i+3,indexOfPatientID))
        tmp_years(j,1) = allParameters(i,indexOfYear)*12;
        tmp_measure(j,1) = allParameters(i,indexOfMeasurement);
        tmp_years(j+1,1) = allParameters(i+1,indexOfYear)*12;
        tmp_measure(j+1,1) = allParameters(i+1,indexOfMeasurement);
        j=j+1;
    else
        interestOfArr{index,1} = txt(i+2,indexOfPatientID);
        % get rid of unnecessary zeros in tail
        tmp_years=tmp_years(1:find(tmp_years,1,'last'),1);
        tmp_measure=tmp_measure(1:find(tmp_measure,1,'last'),1);
        interestOfArr{index,2} = tmp_years;
        interestOfArr{index,3} = tmp_measure;
        
        tmp_years=zeros(10,1);
        tmp_measure=zeros(10,1);
        j=1;        
        index = index +1;
    end
end
interestOfArr{index,1} = txt(i+2,indexOfPatientID);
% get rid of unnecessary zeros in tail
tmp_years=tmp_years(1:find(tmp_years,1,'last'),1);
tmp_measure=tmp_measure(1:find(tmp_measure,1,'last'),1);
interestOfArr{index,2} = tmp_years;
interestOfArr{index,3} = tmp_measure;

%4-folding cross validation
%k=1 folding use 6..20 patients for training
interestOfArr=interestOfArr(1:20,:);
% k=2 folding use 11..26 patients for training
% interestOfArr=interestOfArr(11:25,:);
% k=3 folding use 6..10 and 16..25 patients for training
% interestOfArr=[interestOfArr(6:10,:);interestOfArr(16:25,:)];
% k=4 folding use 21..26 and 6..15 patients for training
% interestOfArr=[interestOfArr(21:25,:);interestOfArr(6:15,:)];

% save to mat file
save('../output/interest_of_parameter.mat', 'interestOfArr')