clear all;
clc;

%% PARAMETEREK
C=3;    %klaszterek szama (az algoritmus nem ismeri)
N=100;  %pontok szama klaszterenkent
cs=10;  %kozeppontok kivalasztasanak szorasa (egyenletes)
s=0.1;  %szoras egy klaszterben (Gauss)
K=3;    %ennyi klasztert feltetelez az algoritmus
J=5000; %iteracioszam

%% PONTOK GENERALASA
x=zeros(C*N,1);
y=zeros(C*N,1);
for ii=1:C
    x(((ii-1)*N+1):(ii*N))=randn(N,1)*s+rand(1)*cs;
    y(((ii-1)*N+1):(ii*N))=randn(N,1)*s+rand(1)*cs;
end
figure(1);
plot(x,y,'.','Color',[.5 1 .6]);

%% K-MEANS ALGORITMUS
ind=randperm(length(x));
ind=ind(1:K);
cx=x(ind);
cy=y(ind);
figure(1);
hold on;
plot(cx,cy,'ro','MarkerFaceColor','r','MarkerSize',5);
hold off;
d2=@(x1,y1,x2,y2) (x1-x2)^2+(y1-y2)^2;
closest=ones(size(x));
for j=1:J
    for p=1:N*C
        mindist=d2(x(p),y(p),cx(1),cy(1));
        for k=2:K 
            dist=d2(x(p),y(p),cx(k),cy(k));
            if mindist>dist
                mindist=dist;
                closest(p)=k;
            end
        end
    end
    for k=1:K
        if sum(closest==k)==0; continue; end;
        cx(k)=mean(x(closest==k));
        cy(k)=mean(y(closest==k));
    end
end
figure(1);
hold on;
plot(cx,cy,'o','MarkerFaceColor','b','MarkerSize',5);
hold off;
title('piros: kezdeti becsles      kek: vegso kozeppontok');
