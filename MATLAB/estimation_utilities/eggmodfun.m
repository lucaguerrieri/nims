function  [cofb,endog_,scof,eqtype_]=eggmodfun(modnam,parnam,defmodnam)
% modnam is the name of the model file
% the model file resides in the model directory whose path is hardwired
% below

% parnam is the name of the parameter file
% the parameter file sits in the calling directory, that is recorded under
% currentdir below

% Based on /mq/home/aim/utility/solve.m
% Edited for use with PC AIM - CM 8/98

% Solve a linear rational expectations model with AIM.  Check the 
% accuracy of the solution, display the roots of the system, and
% compute the observable structure.  Uses Matlab version of parser.

currentdir = cd;

directory = [currentdir,'\'];
%eval(['chdir ',directory])
%olddirnam = dirnam;

%  Parse model

parseflag = 1;

% clean up old model files
if parseflag
    eval(['!del ',modnam,'_*']);
end

%parnam = 'parmmod1';
parmflag = 1;


%  Request printflag
printflag = 1;

%  Modelez syntax parser:
pcparsem;

%  Define the parameter vector (always execute definitions file)
if( length(param_) )
   if( parmflag )
       %capture the parameter file from the launching directory
       %then revert to the model directory
       eval(['chdir ',currentdir]);
	   eval(parnam);
       eval(['chdir ',directory])
   end
   if (nargin==3)
	eval(defmodnam)
   end 
   [npar,ncols] = size(param_);
end



% Numerical tolerances for aim
epsi   = 2.2e-16;
condn  = 1.e-8;
uprbnd = 1 + 1.e-6;

if (printflag)
   space;
	disp('Numerical Tolerances:');
	space
	disp([' epsi       = ',num2str(epsi)]);
	disp([' condn      = ',num2str(condn)]);
	disp([' uprbnd - 1 = ',num2str(uprbnd-1)]);
   space;
end

if(printflag & length(param_) )
   space(2)
   disp('Parameter values:')
   space
   disp('Name          Value')
   tabulator(param_);
   space(2)
end

% ---------------------------------------------------------------------
% Construct structural coefficient matrix.
% ---------------------------------------------------------------------

%  When using pcparsem run compute_aim_matrices directly as a script.
eval([modnam,'_aim_matrices']);

% Construct cof matrix from cofg, cofh
[rh,ch] = size(cofh);
[rg,cg] = size(cofg);
cof = zeros(rh,ch);
cof(1:rg,1:cg) = cofg;
cof = cof + cofh;

% ---------------------------------------------------------------------
% Run AIM
% ---------------------------------------------------------------------
%flops(0);
t0 = clock;
rcof = reshape(cof,size(cof,1)*size(cof,2),1);
%save M:\fortran\AIM\houtan.txt -ascii -double rcof
%save G:\fortran\AIM\cof.txt -ascii -double rcof
%save U:\TQS\houtan\smallrbcDeriv\cof.txt -ascii -double rcof

[cofb,rts,ia,nex,nnum,lgrts,aimcode] = ...
			pcaim_eig(cof,neq,nlag,nlead,condn,uprbnd);

        
% h=0.0000000001;
% cofp = cof;
% cofm = cof;
% cofp(4,5) = cofp(4,5) + h;
% cofm(4,5) = cofm(4,5) - h;
        

% [cofbp,rts,ia,nex,nnum,lgrts,aimcode] = ...
% 			pcaim_eig(cofp,neq,nlag,nlead,condn,uprbnd);
% 
%         
% [cofbm,rts,ia,nex,nnum,lgrts,aimcode] = ...
% 			pcaim_eig(cofm,neq,nlag,nlead,condn,uprbnd);        
%         
%         
% cofbd=(cofbp-cofbm)/(2*h)
        
%save U:\TQS\houtan\smallrbcDeriv\cofb.txt -ascii -double cofb

%[cofb returnarg] = callsparseaimg(cof,nlag,nlead);
            
            
if (printflag)
   disp(aimerr(aimcode));
	space
	disp(['Elapsed time                         = ',num2str(etime(clock,t0))]);
	%disp(['Flops                                = ',num2str(flops)]);
	space
	disp(['Number of exact shiftrights (nex)    = ',num2str(nex)]);
	disp(['Number of numeric shiftrights (nnum) = ',num2str(nnum)]);
	disp(['Number of large roots (lgrts)        = ',num2str(lgrts)]);
	disp(['(nex + nnum + lgrts) - neq*nlead     = ',num2str(nex+nnum+lgrts-neq*nlead)]);
	disp(['Dimension of companion matrix (ia)   = ',num2str(ia)]);
end

% ---------------------------------------------------------------------
% Display roots, magnitude of roots and period
% ---------------------------------------------------------------------
if (printflag)
   pcvibes(rts,0);
end

% ---------------------------------------------------------------------
% Check accuracy of solution
% ---------------------------------------------------------------------
if (printflag)
   err = pccheckaim(neq,nlag,nlead,cof,cofb);
end

% ---------------------------------------------------------------------
% Compute observable structure
% ---------------------------------------------------------------------
scof = pcobstruct(cof,cofb,neq,nlag,nlead);

% The End
%eval(['chdir ',currentdir])