%clear all
%%
x_label='Time in months';
parameter='Maximum Orthogonal Diameter (mm)';
% load the measurement that we are interested in
load('../output/interest_of_parameter');
A = interestOfArr;

% 1 - year, 2 - vol, 3 - dia, 4 - nan, 5 - pid
% 1 - 2, 5 - 1

% A(i,7) contains the sum of the time differences upto that point so it is the current time
for i=1:length(A(:,1))
    for j=1:length(A{i,2}(:,1))
        A{i,7}(j,1)=sum(A{i,2}(1:j,1));
    end
end

% plot the parameter over the cumulative time
figure;
for i=1:length(A(:,1))
    A{i,6}=A{i,7};
    plot(A{i,6}(:,1),A{i,3}(:,1));
    hold on;
end

%we save time and diameter into new matrices or vectors
for k=1:length(A{6,7}(:,1))
    Time(k)=A{6,7}(k,1);
    Dmax(k)=A{6,3}(k,1);
end

ft=fittype('poly1');
fte=fit(Time',Dmax',ft);
a=fte.p2;
b=fte.p1;

t=0:1:100;
%creates a vector that increases from 1 to the maximum of the patient6's
%time. Why did he choose patient 6?
y=a+b*t;
plot(t,y,'g');
%we plot the fitting curve

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MAIN
T_AVE=1000;
counter=0;
Sum=1;
%the next part is the minimizing and iteration thing
while (T_AVE>=1e-6)
    % time alignment according to exponential function

    for i=1:length(A(:,1))
        Tx=fminsearch(@(T) fun_linear(A{i,6},A{i,3},a,b,T),10);
        A{i,4}=Tx;
    end

    for i=1:length(A(:,1))
        A{i,6}=A{i,6}-A{i,4};
    end

    %for i=1:length(A(:,1))
    %    plot(A{i,6}(:,1),A{i,3}(:,1));
    %    hold on;
    %end
    %t=0:1:200;
    %y=a+b*t;
    %plot(t,y,'g');
  

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
                diff(i)=A{pat,3}(i,1)-(a+b*A{pat,9}(i,1));
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

    % update parameters of exponential function
    fte=fit(Time',Dmax',ft);
    a=fte.p2;
    b=fte.p1;
    
    Sum=0;
    for i=1:length(A(:,1))
        Sum=Sum+(A{i,4})^2;
    end
    
    T_AVE=sqrt(Sum)/length(A(:,1))
    counter=counter+1

end
%%

figure;
for i=1:length(A(:,1))
    plot(A{i,6}(:,1),A{i,3}(:,1),'linewidth',1.0);
    text(A{i,6}(length(A{i,6}(:,1)),1),A{i,3}(length(A{i,6}(:,1)),1),A{i,1},...
        'HorizontalAlignment','right',...
        'FontSize',9)
    hold on;
end
t=-50:1:200;
y=a+b*t;
plot(t,y,'-.g','linewidth',2.0);
%plot the final fitting curve with the new parameters after shifting each
%of the patients time diameter curves to minimize the difference to make it
%fit best ie, minimize the value from the fun1
grid on;
residual=0;
for i=1:length(Dmax)
    Res(i)=(a+(b*Time(i))-Dmax(i))^2;
    residual=Res(i)+residual;
end
%Res(i), Time and Dmax are all column vectors I think
%residual has the sum of all the difference squares
Sigma=var(Res)
residual=residual/Sigma^2
xlabel(x_label);
ylabel(parameter);
txt=strcat('a=', num2str(a), ', b=', num2str(b), ', counter=', num2str(counter));
title(txt)
fileName=strcat('../output/growth_curve/' ,parameter, 'NonlinearFitting');
print(fileName,'-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% written by Emrah to plot and calculate r-square for linear regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pred = y;
pred_time=t;
index=1;
for k=1:length(A(:,1))
    for j=1:length(A{k,6}(:,1))
        obs_time(index) = A{k,6}(j,1);
        obs(index) = A{k,3}(j,1);
        index = index + 1;
    end
end
%figure;
%plot(pred_time,pred,'-.g','linewidth',2.0);
%hold on;
%scatter(obs_time, obs);

% This is required for the making the size of observation and prediction
% the same
for i=1:length(obs_time)
    pred_by_time(i)=a+(b*obs_time(i));
end


% r-square calculation
Rsq = 1 - sum((obs - pred_by_time).^2)/sum((obs - mean(obs)).^2);
% if we want to plot observation versus prediction, use below codes
%figure;
%scatter(obs, pred_by_time);

% find correlation and its significance
[RHO, PVAL]=corrcoef(pred_by_time, obs);
corr_coef=RHO(1,2);
p_val=PVAL(1,2);

figure;
plot(pred_time,pred,'-.g','linewidth',2.0);
xlabel(x_label);
ylabel(parameter);
txt=strcat('r-square=', num2str(Rsq),' corr-coef=', num2str(corr_coef), ' p-val=', num2str(p_val))
title(txt)
hold on;
scatter(obs_time, obs);
fileName=strcat('../output/growth_curve/' ,parameter, 'LinearRegression');
print(fileName,'-dpng');