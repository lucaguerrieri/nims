function coefcompanion=companion(coefb,const)

nvars = size(coefb,1);
varlag = size(coefb,3);

coefcompanion = [coefb(:,:,1)];

for i = 2:varlag
coefcompanion = [coefcompanion coefb(:,:,i)];
end

coefcompanion = [coefcompanion; [eye(nvars*(varlag-1)),zeros(nvars*(varlag-1),nvars) ] ];

% append constant at the end of the state space (initialize constant to 1 when hooking up to the kalman filter)
coefcompanion = [[coefcompanion [const;zeros(nvars*(varlag-1),1)]]; [zeros(1,nvars*varlag) 1] ];
