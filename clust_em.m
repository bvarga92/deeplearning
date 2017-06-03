clear all;
clc;

%% PARAMETEREK
C=3;      %klaszterek (generatorok) szama
N=200;    %pontok szama klaszterenkent
cs=30;    %kozeppontok kivalasztasanak szorasa
smin=0.1; %minimalis szoras egy klaszterben
smax=2;   %maximalis szoras egy klaszterben
J=500;    %iteracioszam

%% PONTOK GENERALASA
x=zeros(C,N);
mu=rand(C,1)*cs
sigma=rand(C,1)*(smax-smin)+smin
for ii=1:C
    x(ii,:)=randn(N,1)*sigma(ii)+mu(ii);
end
plot(x',zeros(size(x')),'.');

%% EM ALGORITMUS
x=x'; x=x(:); %osszekeverjuk a pontokat egy vektorba
mu_est=rand(C,1)*cs;
sigma_est=rand(C,1)*(smax-smin)+smin;
P=@(n,k) exp(-(x(n)-mu_est(k)).^2/(2*sigma_est(k)^2))/(sqrt(2*pi)*sigma_est(k));
Pa=ones(C,1)/C;
Z=zeros(C,C*N);
for j=1:J
    %EXPECTATION
    for n=1:C*N
        sumP=0;
        for k=1:C
            sumP=sumP+P(n,k)*Pa(k);
        end
        for k=1:C
            Z(k,n)=P(n,k)*Pa(k)/sumP;
        end
    end
    %MAXIMIZATION
    for k=1:C
        mu_est(k)=sum(x.*Z(k,:)')/sum(Z(k,:));
        sigma_est(k)=sqrt(sum((x-mu_est(k)).^2.*Z(k,:)')/sum(Z(k,:)));
        Pa(k)=sum(Z(k,:))/(N*C); %ha a forrasok a priori valoszinuseget is tanulni akarjuk
    end
end
mu_est
sigma_est
Pa
Z'
