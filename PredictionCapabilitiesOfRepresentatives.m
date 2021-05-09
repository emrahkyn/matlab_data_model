clear all
[allParameters, txt, raw] = xlsread('../input/AllMeasurements.xlsx');
%[allParameters, txt, raw] = xlsread('../input/HighAreaFracMeasurements.xlsx');
%[allParameters, txt, raw] = xlsread('../input/LowAreaFracMeasurements.xlsx');

% index of dia =5
% index of AAA_vol = 8
% index of ILT_vol = 10
indexOfYear=3;

% function is y=a*exp(b*t), t=ln(y/a)/b
% parameters of representative master curve which has already calculated
indexOfDia=5;
parameter='SphericalDiameter';
a=30.7062;
b=0.0049996;


% first find all the observed values on the curve for each scan
j = 1
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
        
        pred_by_time(i)=d1_pred;
        obs(i)=d1;
        % find residual 
        residual = d1_pred-d1;
        residualArr(j,1) = residual;
        
        
        predArr(j,1) = d1_pred;
        obsArr(j,1) = d1;
        
        j = j+1;
    end
    
end

figure;
scatter(timeArr,predArr,'+');
hold on;
scatter(timeArr,obsArr,'o');

xlabel('Time from Baseline (months)');
ylabel('Spherical Diameter (mm)');
txt=strcat('The evaluation of the master curve approximation');
title(txt);

for k=1:length(timeArr)
    hold on;
    if (abs(obsArr(k)-predArr(k)) < 2.1)
        plot([timeArr(k),timeArr(k)],[obsArr(k),predArr(k)],'b')
    else
        plot([timeArr(k),timeArr(k)],[obsArr(k),predArr(k)],'r')
    end
end
legend("Predicted Diameter","Actual diameter");

% find out r-square and correlation coefficient, its siginificance
Rsq = 1 - sum((obs - pred_by_time).^2)/sum((obs - mean(obs)).^2);
[RHO, PVAL]=corrcoef(pred_by_time, obs);
corr_coef=RHO(1,2);
p_val=PVAL(1,2);
% if we want to plot observation versus prediction, use below codes
figure;
scatter(obs, pred_by_time);
xlabel('Observed Spherical Dia. (mm)');
ylabel('Predicted Spherical Dia. (mm)');
txt=strcat('Parameter: ', parameter, ' r-square=', num2str(Rsq),' corr-coef=', num2str(corr_coef), ' p-val=', num2str(p_val));
title(txt);
% save the file
fileName=strcat('../output/growth_curve/ObservedVsPredictedBy', parameter);
print(fileName,'-dpng');
