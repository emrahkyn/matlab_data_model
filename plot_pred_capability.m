function [accuracy] = plot_pred_capability (test_dataset, alpha, beta)
% a set of CT scans belong to single patient
    a = alpha;
    b = beta;
        
    sample=size(test_dataset); 
    predArr=zeros(sample(1,1),1);
    obsArr=zeros(sample(1,1),1);
    j = 1;    
    time=0;
    for patient=1:sample(1,1)        
        test_set = test_dataset(patient,:);

        for i=1:length(test_set{:,2}(:,1))
            deltaT = test_set{:,2}(i)*12;
            
            if deltaT == 0
                t1=test_set{:,2}(i+1);
                d1=test_set{:,3}(i+1);
                d0=test_set{:,3}(i);
                % predict what diameter of scan at t0 = d0_pred
                
                % first find the time at t1 on the curve and predict diameter
                t1_onCurve = log(d1/a)/b;
                t0_onCurve=t1_onCurve-t1;
                d0_pred=a*exp(b*t0_onCurve);
                
            else   
                % we need to predict the diameter of scan using the previous one
                time = time + t1;
                timeArr(j,1) = time;
                
                t1=test_set{:,2}(i);
                d0=test_set{:,3}(i-1);
                d1=test_set{:,3}(i);           
                
                % first find t0 on curve and predict diameter at t1
                t0_onCurve = log(d0/a)/b;
                t1_onCurve=t0_onCurve+t1;
                d1_pred=a*exp(b*t1_onCurve);

                predArr(j,1) = d1_pred;
                obsArr(j,1) = d1;
                
                j = j+1;
            end
            
        end

    end
    
    [mu,sigma] = normfit(obsArr-predArr)

    % plot histogram of residual error
%     figure
%     histfit(obsArr-predArr,20);
%     xlabel('Prediction error in mm');
%     ylabel('Frequency');
    
%     rse = sqrt(sum((obsArr-predArr).^2)/(length(obsArr)-2));
%     
%     num_correct_pred=0;
%     num_incorrect_pred=0;
%     for k=1:length(timeArr)
%         if (abs(obsArr(k)-predArr(k)) <= 2*rse)
%             num_correct_pred = num_correct_pred + 1;
%             s_timeArrCorr(num_correct_pred) = timeArr(k);
%             s_obsArrCorr(num_correct_pred) = obsArr(k);
%             s_predArrCorr(num_correct_pred) = predArr(k);
%         else
%             num_incorrect_pred = num_incorrect_pred + 1;
%             s_timeArrInCorr(num_incorrect_pred) = timeArr(k);
%             s_obsArrInCorr(num_incorrect_pred) = obsArr(k);
%             s_predArrInCorr(num_incorrect_pred) = predArr(k);       
%         end
%     end
%     
%     accuracy = (num_correct_pred/k)*100;
%     
%     % correctly predicted samples
%     figure;
%     scatter(s_timeArrCorr,s_predArrCorr,'+','b');
%     hold on;
%     scatter(s_timeArrCorr,s_obsArrCorr,'o','r');
%     hold on;
%     scatter(s_timeArrInCorr,s_predArrInCorr,'+','b');
%     hold on;
%     scatter(s_timeArrInCorr,s_obsArrInCorr,'o','r');
%     
%     xlabel('Time from Baseline (months)');
%     ylabel('Spherical Diameter (mm)');
%     txt=strcat('Observed and predicted diameter in mm');
%     title(txt);
%     
%     for k=1:length(timeArr)
%         hold on;
%         if (abs(obsArr(k)-predArr(k)) <= 2*rse)
%             plot([timeArr(k),timeArr(k)],[obsArr(k),predArr(k)],'b')    
%         else
%             plot([timeArr(k),timeArr(k)],[obsArr(k),predArr(k)],'r')
%         end
%     end
%     legend("Predicted Measurements","Observed Measurements");
        
end

