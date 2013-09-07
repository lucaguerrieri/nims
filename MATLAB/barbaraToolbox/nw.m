function result = nw(y,qn);
%input: y is a T*k vector and qn is the truncation lag
%output: the newey west HAC covariance estimator 
%Formulas are from Hayashi

[T,k]=size(y); ybar=ones(T,1)*((sum(y))/T);
dy=y-ybar;
G0=dy'*dy/(T-1); 
for j=1:qn-1;
   gamma=(dy(j+1:T,:)'*dy(1:T-j,:))./(T-1);
   G0=G0+(gamma+gamma').*(1-abs(j/qn));
end;
result=G0;