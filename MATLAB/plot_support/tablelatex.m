function table=tablelatex(resultmat,columnlabels,rowlabels)


nrows = size(resultmat,1);
ncols = size(resultmat,2);


header = char('\begin{table}','\center');
header = cellstr(header);

tabular = ['\begin{tabular}{|l|']

for i=1:ncols
    tabular = [tabular,'c|'];
end
tabular = [tabular,'}'];

cellarray='';
for i=1:ncols
    cellarray=[cellarray,'&',columnlabels(i,:)];
end
cellarray = [cellarray,'\\'];


table = cellstr(header);
table = [table;cellstr(tabular);cellstr('\hline');cellstr(cellarray);cellstr('\hline')];
for i=1:nrows
    line = rowlabels(i,:);
    for j=1:ncols
        if (~isempty(strmatch('s.e.',rowlabels(i,:))))
            line = [line,'& (',num2str(resultmat(i,j),'%5.3f'),')'];   
        
        else 
            line = [line,'&',num2str(resultmat(i,j),'%5.3f')];   
        end
    end
    line = [line,'\\'];
    table = [table;cellstr(line)];
end
table = [table;cellstr('\hline')]
footer = char('\end{tabular}','\end{table}')

table = [table;cellstr(footer)];



