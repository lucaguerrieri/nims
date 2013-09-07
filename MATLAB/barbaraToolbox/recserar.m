function y = recserar(x,y0,a);
%Computes a vector of autoregressive recursive series (Gauss translation)
%y(t,:)=x(t,:)+a(1,:)*y(t-,:)+...+a(P,:)*y(t-P,:)  for t=P+1,...,N
%and y(t,:)=y0(t,:) for t=1,...,P 
[N,K]=size(x);
[P,k]=size(y0); %a is P*K
y=y0;
for t=[P+1:1:N];
   yhere=x(t,:);
   for i=1:P; yhere=yhere+a(i,:).*y(t-i,:);
   end;
   y=[y;yhere];
end;

