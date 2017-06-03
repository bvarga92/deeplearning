clear all;
clc;

%% PARAMETEREK
C=3;    %klaszterek szama (az algoritmus nem ismeri)
N=100;  %pontok szama klaszterenkent
cs=10;  %kozeppontok kivalasztasanak szorasa (egyenletes)
s=0.1;  %szoras egy klaszterben (Gauss)

%% PONTOK GENERALASA
x=zeros(C*N,1);
y=zeros(C*N,1);
for ii=1:C
    x(((ii-1)*N+1):(ii*N))=randn(N,1)*s+rand(1)*cs;
    y(((ii-1)*N+1):(ii*N))=randn(N,1)*s+rand(1)*cs;
end
figure(1);
plot(x,y,'.','Color',[.5 1 .6]);

%% KLASZTEREZES
d=@(x1,y1,x2,y2) sqrt((x1-x2)^2+(y1-y2)^2);
D=zeros(C*N,C*N); %D(i,j) az i-edik es j-edik pontok tavolsaga
for ii=1:C*N
    for jj=ii:C*N %nem tarolunk redundansan, D felso haromszog lesz
        D(ii,jj)=d(x(ii),y(ii),x(jj),y(jj));
    end
end
D(D==0)=Inf;
while min(D(:))~=Inf
    [m I]=min(D(:));
    [I1 I2]=ind2sub(size(D),I); %I1<I2
    D(I1,I2)=Inf;
    for ii=(I2+1):C*N
        if D(I1,ii)>D(I2,ii); D(I1,ii)=D(I2,ii); end;
        D(I2,ii)=Inf;
    end
    for ii=1:(I1-1)
        if D(ii,I1)>D(ii,I2); D(ii,I1)=D(ii,I2); end;
        D(ii,I2)=Inf;
    end
    disp(sprintf('C%d es C%d osszevonva %.3f tavolsagnal.',I1,I2,m));
end
