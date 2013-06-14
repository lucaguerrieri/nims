function [listdrop]=makelistdrop(listkeep,listfull)

nfull = size(listfull,1);
rowdrop = [];

% create list of variables in the state space to be dropped
rowindx = 0;
for indxi = 1:nfull
    if (isempty(strmatch(deblank(listfull(indxi,:)),listkeep,'exact')))
       rowindx = rowindx+1;
       rowdrop(rowindx)=indxi;
    end
end

listdrop = listfull(rowdrop,:);
