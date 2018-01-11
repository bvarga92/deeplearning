clear all;
clc;

%% JELEK GENERALASA
C=3; % komponensek szama
t=0:1e-4:1;
S=[sin(2*pi*10*t) ; sawtooth(2*pi*13*t+1,0.5) ; square(2*pi*16*t+2)]; % forrasok
A=[3 2 1 ; -1 -2 5 ; 0 5.1 1.7]; % keveromatrix
X=A*S; % megfigyelt jelek

%% FEHERITES
cov(X')
V=sqrtm(cov(X'))\(X-mean(X,2)*ones(1,size(X,2)));
cov(V') % ez mar diagonalis

%% INDEPENDENT COMPONENT ANALYSIS (FastICA)
B=zeros(C,C);
for c=1:C
    rng(1234,'twister'); % megismetelhetoseg miatt
    w=rand(C,1); % random inicializalas
    w=w-B*B'*w; % elozo vetuletek levonasa
    w=w/norm(w); % normalas
    for ii=1:10
        ev=zeros(size(w));
        for k=1:size(X,2); ev=ev+V(:,k)*(w'*V(:,k))^3; end; ev=ev/size(X,2); % E{v(w'v)^3}
        wnew=(ev-3*w); % w[k]=E{v(w[k-1]'v)^3}-3w[k-1]
        wnew=wnew-B*B'*wnew; % elozo vetuletek levonasa
        wnew=wnew/norm(wnew); % normalas
        if abs(wnew'*w)>0.995 % konvergalt
            w=wnew;
            B(:,c)=w;
            fprintf('Konvergencia %d lepesben.\n',ii)
            break;
        end
        w=wnew;
    end
end

%% ABRAZOLAS
figure(1);
subplot(3,1,1);
plot(t,X');
title('Megfigyelt jelek');
subplot(3,1,2);
plot(t,S');
title('Eredeti komponensek');
subplot(3,1,3);
plot(t,B'*V);
title('Visszaallitott komponensek');
