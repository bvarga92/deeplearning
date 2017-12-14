clear all;
clc;

%% PARAMETEREK
N=1000;      %pontok szama
maxslope=10; %maximalis meredekseg
sn=2;        %additiv Gauss-zaj szorasa

%% PONTOK GENERALASA
x=linspace(0,10,N);
m=maxslope*rand()
y=m*x+randn(1,N)*sn;
figure(1);
plot(x,y,'r.');
axis([min(x)-2 max(x)+2 min(y)-2 max(y)+2]);

%% AUTOKORRELACIOS MATRIX SZAMITASA
R=zeros(2,2);
for ii=1:N
    R=R+[x(ii) ; y(ii)]*[x(ii)  y(ii)]/N;
end

%% LEGNAGYOBB SAJATERTEKHEZ TARTOZO SAJATVEKTOR KERESESE
[v,l]=eig(R);
[lmax,I]=max(diag(l));
v1=v(:,I);
v1=v1/v1(1)*max(x);
figure(1);
hold on;
plot([0 v1(1)],[0 v1(2)],'LineWidth',2);
hold off;
m_est=v1(2)/v1(1)
