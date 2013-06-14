function  [cofb,scof,endog_,eqtype_,eqname_,aimcode,err]=eggmodfunestim(modnam,parnam1,parnam2,parseflag,params,paramlabels)
% modnam is the name of the model file
% it sits in the calling directory

% parnam is the name of the parameter file
% the parameter file sits in the calling directory

% Based on /mq/home/aim/utility/solve.m
% Edited for use with PC AIM - CM 8/98

% Solve a linear rational expectations model with AIM.  Check the 
% accuracy of the solution, display the roots of the system, and
% compute the observable structure.  Uses Matlab version of parser.

currentdir = cd;

directory = [currentdir,'\'];

%  Parse model
if nargin<5
parseflag = 1;
end

% clean up old model files
if parseflag
    eval(['!del ',modnam,'_*']);
end

parmflag = 1;


%  Request printflag
% if nargin>4
%     printflag = 0;
% else
%     printflag = 1;
% end
printflag=0;

%  Modelez syntax parser:
pcparsem;

%  Define the parameter vector (always execute definitions file)
if( length(param_) )
   if( parmflag )
	   eval(parnam1);
       if nargin>4
          nestims = max(size(params));
          for paramindx = 1:nestims
              eval([paramlabels(paramindx,:),'=params(paramindx);'])
          end
       end
       eval(parnam2);
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


[cofb,rts,ia,nex,nnum,lgrts,aimcode] = ...
			pcaim_eig(cof,neq,nlag,nlead,condn,uprbnd);

if (printflag)
   disp(aimerr(aimcode));
	space
	disp(['Elapsed time                         = ',num2str(etime(clock,t0))]);
%	disp(['Flops                                = ',num2str(flops)]);
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
err = pccheckaim_luca(neq,nlag,nlead,cof,cofb);

% ---------------------------------------------------------------------
% Compute observable structure
% ---------------------------------------------------------------------
scof = pcobstruct(cof,cofb,neq,nlag,nlead);

% The End
