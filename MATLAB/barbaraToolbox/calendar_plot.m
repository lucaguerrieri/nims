function tds=calendar(fyds,fmds,nds,f)
%f=frequency; 'm' for monthly, 'q' for quarterly
if f=='m';
    calds=zeros(nds,2); calds(1,1)=fyds; calds(1,2)=fmds;
    yr=fyds; mt=fmds;
    i=2; for i=2:nds;
     mt=mt+1;
     if mt > 12; mt=1; yr=yr+1; end; 
     calds(i,1)=yr; calds(i,2)=mt;
     end; %tds=calds(:,1)+(calds(:,2)-ones(length(calds),1))/12;
    tds=calds(:,1)+(calds(:,2)-ones(size(calds,1),1))/12;
end;
if f=='q';
        calds=zeros(nds,2); calds(1,1)=fyds; calds(1,2)=fmds;
    yr=fyds; mt=fmds;
    i=2; for i=2:nds;
     mt=mt+1;
     if mt > 4; mt=1; yr=yr+1; end; 
     calds(i,1)=yr; calds(i,2)=mt;
     end; %tds=calds(:,1)+(calds(:,2)-ones(length(calds),1))/12;
    tds=calds(:,1)+(calds(:,2)-ones(size(calds,1),1))/4;
end;