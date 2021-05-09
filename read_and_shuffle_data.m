function interestOfArr = read_and_shuffle_data (input_file, indexOfMeasurement)
    [allParameters, txt, raw] = xlsread(input_file);
    
    % default location
    indexOfYear=3;
    indexOfPatientID=1;
    
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
    
    % Input file has already shuffled previously.
    %interestOfArr = interestOfArr(randperm(size(interestOfArr, 1)), :);

end