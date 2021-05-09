function X=fun1(t,D,a,b,T)

X=0;
for i=1:length(t)
    %number of values in the time column
    
    X=X+(a*exp(b*(t(i)-T))-D(i))^2;
    %what is T? t(i) is the time sum V should be volume logically but it is
    %diameter in this case 
    
end

end