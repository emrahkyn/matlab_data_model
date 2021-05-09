% function [r2, rmse, residual_standard_error, accuracy] = PredCapabilitySplitGraphV2 (a, b, indexOfMeasurement)
clear all;
%firstparam = [37.34, 40.51];
%secondparam = linspace(0.0044,0.0045,2);
%[F,S] = ndgrid(firstparam, secondparam);
%[r2, rmse, rse, accuracy] = arrayfun(@(p1,p2) PredCapabilitySplitGraphV2(p1,p2,5), F, S);
[allParameters, txt, raw] = xlsread('../input/AllMeasurements.xlsx');

% k=1 folding use 22..26 patients for testing
% allParameters=allParameters(86:106,:);
% k=1 folding use 1..5 patients for validation
% allParameters=allParameters(1:16,:);

% k=2 folding use 6..10 patients for testing
% allParameters=allParameters(17:43,:);
% k=2 folding use 1..5 patients for validation
allParameters=allParameters(21:25,:);

% k=3 folding use 11..15 patients for testing
% allParameters=allParameters(44:66,:);
% k=3 folding use 1..5 patients for validation
% allParameters=allParameters(1:16,:);

% k=4 folding use 16..20 patients for testing
% allParameters=allParameters(67:82,:);
% k=4 folding use 1..5 patients for validation
% allParameters=allParameters(1:16,:);

%[allParameters, txt, raw] = xlsread('../input/HighAreaFracMeasurements.xlsx');
%[allParameters, txt, raw] = xlsread('../input/LowAreaFracMeasurements.xlsx');

% index of dia =5
% index of AAA_vol = 8
% index of ILT_vol = 10
% index of axial diameter = 22
indexOfYear=3;

% function is y=a*exp(b*t), t=ln(y/a)/b
% parameters of representative master curve which has already calculated

indexOfDia=5;
%indexOfDia=indexOfMeasurement;
parameter='Spherical Diameter (mm)';
% k=1
a=105974;
b=0.0049;
% k=2
%a=40.51;
%b=0.0048;
% k=3
%a=41.47;
%b=0.0043;
% k=4
%a=30.58;
%b=0.0047;

%indexOfDia=14;
%parameter='Orthogonal Diameter (mm)';
%a=31.3334;
%b=0.0068056;14
%indexOfDia=22;
%parameter='Axial Diameter (mm)';
%a=35.7823;
%b=0.0055811;

%AAAVOL
%indexOfDia=8;
%parameter='AAA Volume (mm3)';
%a=58213;
%b=0.012;

%ILTVOL
%indexOfDia=10;
%parameter='ILT Volume (mm3)';
%a=19517;
%b=0.0175;

%indexOfDia=5;
%parameter='Spherical Diameter Test (mm)';
%a=32.05;
%b=0.00453;


% first find all the observed values on the curve for each scan
j = 1;
time =0;
for i=1:length(allParameters(:,1))
    deltaT = allParameters(i,indexOfYear)*12;
    
    if deltaT == 0
        time = 0;
        % we need to predict diameter of scan at t0 using diameter and time
        % at t1
        t1=allParameters(i+1,indexOfYear)*12;
        d1=allParameters(i+1,indexOfDia);
        d0=allParameters(i,indexOfDia);
        % predict what diameter of scan at t0 = d0_pred

        % first find the time at t1 on the curve and predict diameter
        t1_onCurve = log(d1/a)/b;
        t0_onCurve=t1_onCurve-t1;
        d0_pred=a*exp(b*t0_onCurve);

        pred_by_time(i)=d0_pred;
        obs(i)=d0;
        % find residual 
        %residual = d0_pred-d0;
        %residualArr(i,1) = residual;
    else
        % we need to predict the diameter of scan using the previous one
        time = time + t1;
        timeArr(j,1) = time;

        t1=allParameters(i,indexOfYear)*12;
        d0=allParameters(i-1,indexOfDia);
        d1=allParameters(i,indexOfDia);

        % first find t0 on curve and predict diameter at t1
        t0_onCurve = log(d0/a)/b;
        t1_onCurve=t0_onCurve+t1;
        d1_pred=a*exp(b*t1_onCurve);
        t0_onCurve

        pred_by_time(i)=d1_pred;
        obs(i)=d1;
        % find residual 
        residual = d1_pred-d1;
        residualArr(j,1) = residual;


        predArr(j,1) = d1_pred;
        obsArr(j,1) = d1;

        if deltaT > 4
            % discard samples less than 5 months
            j = j+1;
        end
    end   
    
end

[mu,sigma] = normfit(obsArr-predArr);
cutoff1 = mu + 2*sigma;
cutoff2 = mu - 2*sigma;

% find correlation and its significance
[RHO, PVAL]=corrcoef(predArr, obsArr);
corr_coef=RHO(1,2);
p_val=PVAL(1,2);

%histfit(obsArr-predArr,20);
%xlabel('Prediction error in mm');
%ylabel('Frequency');



num_correct_pred=0;
num_incorrect_pred=0;
for k=1:length(timeArr)
    if ((obsArr(k)-predArr(k)) <= cutoff1) && ((obsArr(k)-predArr(k)) >= cutoff2)
        num_correct_pred = num_correct_pred + 1;
        s_timeArrCorr(num_correct_pred) = timeArr(k);
        s_obsArrCorr(num_correct_pred) = obsArr(k);
        s_predArrCorr(num_correct_pred) = predArr(k);
    else
        num_incorrect_pred = num_incorrect_pred + 1;
        s_timeArrInCorr(num_incorrect_pred) = timeArr(k);
        s_obsArrInCorr(num_incorrect_pred) = obsArr(k);
        s_predArrInCorr(num_incorrect_pred) = predArr(k);       
    end
end

RMSE = sqrt(mean((obsArr-predArr).^2));
accuracy = (num_correct_pred/k)*100;
%disp(["rmse:", RMSE, " accuracy", accuracy, " avg time for success", mean(s_timeArrCorr), " avg time for incorrect", mean(s_timeArrInCorr)]);




% correctly predicted samples
% figure;
% scatter(s_timeArrCorr,s_predArrCorr,'+','b');
% hold on;
% scatter(s_timeArrCorr,s_obsArrCorr,'o','r');
% hold on;
% scatter(s_timeArrInCorr,s_predArrInCorr,'+','b');
% hold on;
% scatter(s_timeArrInCorr,s_obsArrInCorr,'o','r');



% xlabel('Time from Baseline (months)');
% ylabel(parameter);
%txt=strcat('Observed and predicted diameter in mm');
%title(txt);

%for k=1:length(timeArr)
%    hold on;
%    if ((obsArr(k)-predArr(k)) <= cutoff1) && ((obsArr(k)-predArr(k)) >= cutoff2)
%        plot([timeArr(k),timeArr(k)],[obsArr(k),predArr(k)],'b')    
%    else
%        plot([timeArr(k),timeArr(k)],[obsArr(k),predArr(k)],'r')
%    end
%end
%legend("Predicted Measurements","Observed Measurements");

[RMSE, num_correct_pred,mu,sigma,corr_coef];
[r2, rmse] = rsquare(obsArr,predArr);
[residual_standard_error]=sqrt(sum((obsArr-predArr).^2)/(k-2));
[accuracy] = (num_correct_pred/(num_incorrect_pred+num_correct_pred))*100;

% end
