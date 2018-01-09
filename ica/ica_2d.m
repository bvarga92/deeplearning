clear all;
clc;

%% KEPEK BEOLVASASA
C=2; % komponensek szama
x1=imread('ica_2d_in1.jpg');
x2=imread('ica_2d_in2.jpg');
X=[double(x1(:))' ; double(x2(:))'];

%% FEHERITES
cov(X')
V=sqrtm(cov(X'))\(X-mean(X,2)*ones(1,size(X,2)));
cov(V') % ez mar diagonalis

%% INDEPENDENT COMPONENT ANALYSIS (FastICA)
B=zeros(C,C);
for c=1:C
    rng(1,'twister'); % megismetelhetoseg miatt
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

%% VISSZASKALAZAS
out1=B(:,1)'*V;
out1=out1/((max(out1,[],2)-min(out1,[],2)))*255;
out1=out1-min(out1,[],2);
out1=uint8(reshape(out1,400,586));
out2=B(:,2)'*V;
out2=out2/((max(out2,[],2)-min(out2,[],2)))*255;
out2=out2-min(out2,[],2);
out2=uint8(reshape(out2,400,586));

%% ABRAZOLAS
figure(1);
subplot(221);
imshow(x1);
title('Be 1');
subplot(222);
imshow(x2);
title('Be 2');
subplot(223);
imshow(out1);
title('Ki 1');
subplot(224);
imshow(out2);
title('Ki 2');
imwrite(out1,'ica_2d_out1.jpg','jpg');
imwrite(out2,'ica_2d_out2.jpg','jpg');
