clear all;
clc;

%% PARAMETEREK
N1=1000;       % 1. osztaly elemeinek szama
N2=500;        % 2. osztaly elemeinek szama (N2<N1)
m1=[0    0];   % 1. osztaly kozeppontja
m2=[-0.2 0];   % 2. osztaly kozeppontja
s1=[0.1 0.05]; % 1. osztalyba tartozo adatok koordinatainak szorasa
s2=[0.01 0.1]; % 2. osztalyba tartozo adatok koordinatainak szorasa
K=50;

%% PONTOK GENERALASA
C1(:,1)=m1(1)+s1(1)*randn(N1,1);
C1(:,2)=m1(2)+s1(2)*randn(N1,1);
C2(:,1)=m2(1)+s2(1)*randn(N2,1);
C2(:,2)=m2(2)+s2(2)*randn(N2,1);
figure(1);
plot(C1(:,1),C1(:,2),'r.','DisplayName',sprintf('C1 (%d)',N1));
hold on;
plot(C2(:,1),C2(:,2),'b.','DisplayName',sprintf('C2 (%d)',N2));
hold off;
legend('-DynamicLegend');

%% ADASYN
dist2=@(x,y) sum((x-y).^2);
r=zeros(N2,1);
for ii=1:N2
    D=zeros(N1+N2-1,2);
    for jj=1:N1
        D(jj,:)=[dist2(C2(ii,:),C1(jj,:)) 1];
    end
    for jj=1:ii-1
        D(jj+N1,:)=[dist2(C2(ii,:),C2(jj,:)) 2];
    end
    for jj=ii+1:N2
        D(jj+N1-1,:)=[dist2(C2(ii,:),C2(jj,:)) 2];
    end
    [D(:,1),ord]=sort(D(:,1));
    D(:,2)=D(ord,2);
    D=D(1:K,:); % C2(ii)-nek a K db legkozelebbi szomszedja
    r(ii)=sum(D(:,2)==1)/K; % hanyadresze esik a tobbsegi osztalyba
end
if sum(r)~=0
    r=r/sum(r);
end
g=round(r*(N1-N2));
CS=[];
for ii=1:N2
    for kk=1:g(ii)
        D=zeros(N1+N2-1,2);
        for jj=1:N1
            D(jj,:)=[dist2(C2(ii,:),C1(jj,:)) 1];
        end
        for jj=1:ii-1
            D(jj+N1,:)=[dist2(C2(ii,:),C2(jj,:)) 2];
        end
        for jj=ii+1:N2
            D(jj+N1-1,:)=[dist2(C2(ii,:),C2(jj,:)) 2];
        end
        [D(:,1),ord]=sort(D(:,1));
        idx=ord(ceil(K*rand)); % valasztunk egyet a K szomszedbol
        if idx<=N1
            p=C1(idx,:);
        else
            p=C2(idx-N1,:);
        end
        CS=[CS ; C2(ii,:)+(p-C2(ii))*rand];
    end
end
if ~isempty(CS)
    figure(1);
    hold on;
    plot(CS(:,1),CS(:,2),'g.','DisplayName',sprintf('CS (%d)',sum(g)));
    hold off;
end