function table=tablelatex_testresults(resultmat,columnlabels,rowlabels)


nrows = size(resultmat,1);
ncols = size(resultmat,2)/2;

nmodels = nrows/4;


header = char('\begin{table}','\center');
header = cellstr(header);

tabular = ['\begin{tabular}{|l|l|'];

for i=1:ncols
    tabular = [tabular,'c|'];
end
tabular = [tabular,'}'];

cellarray='&';
for i=1:ncols
    cellarray=[cellarray,'&',columnlabels(i,:)];
end
cellarray = [cellarray,'\\'];


table = cellstr(header);
table = [table;cellstr(tabular);cellstr('\hline');cellstr(cellarray);cellstr('\hline')];
label_counter =0;
for i=1:nrows
    if mod(i,4)==1
    label_counter = label_counter+1;
    line = [rowlabels(label_counter,:),'& DMW'];
    elseif mod(i,4) == 2
    line = '& $\Gamma_P^{(A)}$';    
    elseif mod(i,4) == 3
    line = '& $\Gamma_P^{(B)}$';
    else
    line = '& $\Gamma_P^{(U)}$';
    end
    for j=1:ncols
        if resultmat(i,(j-1)*2+2)
            line = [line,'&',num2str(resultmat(i,(j-1)*2+1),'%5.3f'),'*'];   
        
        else 
            line = [line,'&',num2str(resultmat(i,(j-1)*2+1),'%5.3f')];   
        end
    end
    line = [line,'\\'];
    table = [table;cellstr(line)];
    if mod(i,4) == 0
    table = [table;cellstr('\hline')];
    end
end
footer = char('\end{tabular}','\end{table}');

table = [table;cellstr(footer)];



