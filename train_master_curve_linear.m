function [alpha beta] = train_master_curve(train_set)
    A = train_set;

    % A(i,7) contains the sum of the time differences upto that point so it is the current time 
    for i=1:length(A(:,1))
        for j=1:length(A{i,2}(:,1))
            A{i,7}(j,1)=sum(A{i,2}(1:j,1));
        end
    end
    
    % plot the parameter over the cumulative time
    for i=1:length(A(:,1))
        A{i,6}=A{i,7};
    end
    
    %we save time and diameter into new matrices or vectors
    for k=1:length(A{6,7}(:,1))
            Time(j)=A{6,7}(k,1);
            Dmax(j)=A{6,3}(k,1);
            j=j+1;
    end
     
    % the type of fitting curve is exponential of degree one in x
    % we fit the time and maximum diameter onto an exponential curve
    
    ft=fittype('poly1');
    fte=fit(Time',Dmax',ft);
    a=fte.p2;
    b=fte.p1;
    
    t=0:1:max(A{5,7});
    
    y=a+(b*t);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MAIN
    T_AVE=1000;
    counter=0;
    Sum=1;
    %the next part is the minimizing and iteration thing
    while (T_AVE>=1e-6)
        %a very small number to compare with for convergence
        for i=1:length(A(:,1))
            Tx=fminsearch(@(T) fun_linear(A{i,6},A{i,3},a,b,T),10);
            % Tx=fminsearch(@(T) fun_linear(A{i,6},A{i,3},a,b,T),10);
            A{i,4}=Tx;
        end
        
        for i=1:length(A(:,1))
            A{i,6}=A{i,6}-A{i,4};    
        end
    
    
        for pat=1:length(A(:,1))
            p=1;
            for k=.1:.1:20
                for j=1:length(A{pat,2}(:,1))
                    A{pat,8}(j,1)=A{pat,2}(j,1)*k;
                end
                A{pat,8};
                for j=1:length(A{pat,8}(:,1))
                    A{pat,9}(j,1)=sum(A{pat,8}(1:j,1));
                    A{pat,9}(j,1)=A{pat,9}(j,1)+A{pat,6}(1,1);
                end
                diff=0;
                sumdiff=0;
                for i=1:length(A{pat,9}(:,1))
                    diff(i)=A{pat,3}(i,1)-(a+(b*A{pat,9}(i,1)));
                end
                diff;
                sumdiff=sum(abs(diff));
                psumdiff(p)=sumdiff;
                p=p+1;
            end
            [smallest_sumdiff,ind]=min(psumdiff);
            best_k=ind*.1;
            A{pat,10}=best_k;
        end
    
        for i=1:length(A(:,1))
            A{i,8}=A{i,2}*A{i,10};
        end
        
        for i=1:length(A(:,1))
            for j =1:length(A{i,8}(:,1))
                A{i,9}(j,1)=sum(A{i,8}(1:j,1));
                A{i,9}(j,1)=A{i,9}(j,1)+A{i,6}(1,1);
                A{i,6}(j,1)=A{i,9}(j,1);
            end
        end
    
        j=1;
        for i=1:length(A(:,1))
            for k=1:length(A{i,6}(:,1))
                Time(j)=A{i,6}(k,1);
                Dmax(j)=A{i,3}(k,1);
                j=j+1;
            end
        end
    
        %we entered the new t values into Time()
        fte=fit(Time',Dmax',ft);
        %fit the curve with the data having new t values
        a=fte.p2;
        b=fte.p1;
        t=-50:1:150;
        y=a+(b*t);
    
        Sum=0;
        for i=1:length(A(:,1))
            Sum=Sum+(A{i,4})^2;
        end
    
        T_AVE=sqrt(Sum)/length(A(:,1));
    
        
        counter=counter+1;
    
    end % while
    alpha = a;
    beta = b;

end % function