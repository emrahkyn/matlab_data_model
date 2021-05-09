function [rmse rse rsqr] = test_master_curve (test_dataset, alpha, beta)
% a set of CT scans belong to single patient
    a = alpha;
    b = beta;
    
    sample=size(test_dataset); 
    predArr=zeros(sample(1,1),1);
    obsArr=zeros(sample(1,1),1);
    j = 1;    
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
                t1_onCurve = (d0-a)/b;
                t0_onCurve=t1_onCurve-t1;
                d0_pred=a+(b*t0_onCurve);
                
            else               
                t1=test_set{:,2}(i);
                d0=test_set{:,3}(i-1);
                d1=test_set{:,3}(i);           
                
                % first find t0 on curve and predict diameter at t1
                t0_onCurve = (d0-a)/b;
                t1_onCurve=t0_onCurve+t1;
                d1_pred=a+(b*t1_onCurve);

                predArr(j,1) = d1_pred;
                obsArr(j,1) = d1;
                
                j = j+1;
            end
            
        end

    end

    rmse = sqrt(mean((obsArr-predArr).^2));
    rse = sqrt(sum((obsArr-predArr).^2)/(length(obsArr)-2));
    rsqr = 1 - sum((obsArr - predArr).^2)/sum((obsArr - mean(obsArr)).^2);
        
end

