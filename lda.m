clear all;
clc;

%% TANITO ADATOK
classes=[0 1];
data=[
  %  x   y   osztaly
    21  46  classes(1);
    18  55  classes(1);
    25  40  classes(1);
    22  39  classes(1);
    18  31  classes(2);
    15  43  classes(2);
    23  25  classes(2)
];

%% STATISZTIKAI PARAMETEREK SZAMITASA
mu_global=mean(data(:,1:end-1)); % teljes adatsor atlaga
mu=zeros(length(classes),size(data,2)-1); % az egyes osztalyok atlagai
p=zeros(size(classes)); % az egyes osztalyok gyakorisagai
C=zeros(size(data,2)-1,size(data,2)-1); % a teljes kovarianciamatrix
for ii=1:length(classes)
    mask=data(:,3)==classes(ii);
    p(ii)=sum(mask)/size(data,1); % az i-edik osztaly gykorisaga
    curData=data(mask,1:(end-1)); % az i-edik osztalyba tartozo adatok
    mu(ii,:)=mean(curData,1); % az i-edik osztalyba tartozo adatok atlaga
    curData=curData-ones(size(curData,1),1)*mu_global; % a teljes atlaggal korrigalt adatok
    C=C+curData.'*curData; % az i-edik osztaly jaruleka a kovarianciamatrixhoz
end
C=C/size(data,1)
p

%% DISZKRIMINANCIAFUGGVENY KIERTEKELESE
data=[data ; 20 33 -1; 20 55 -1]; % plusz ket uj adat, amivel nem tanitottunk
f=zeros(size(data,1),length(classes));
for ii=1:length(classes)
    f(:,ii)=mu(ii,:)*(C\data(:,1:(end-1)).')-0.5*mu(ii,:)*(C\mu(ii,:).')+log(p(ii));
end
[fmax,idx]=max(f,[],2);
output=classes(idx)' % osztalyozas kimenete

%% VIZUALIZACIO (2D adatok es 2 osztaly eseten)
figure(1);
subplot(211);
plot(data(:,1),data(:,2),'o');
title('Adatok');
subplot(212);
plot(f(:,1),f(:,2),'o');
hold on;
plot(f(:),f(:),'r')
hold off;
title('Transzformalt adatok es a dontesi hatar');
