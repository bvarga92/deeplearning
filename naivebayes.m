clear all;
clc;

%% parameterek
dataset={ % a kiindulo adathalmaz, minden eleme egy matrix, amelynek sorai tartalmaznak egy-egy pontot
    [randn(100,1)-6  randn(100,1)+2]
    [randn(100,1)    randn(100,1)  ]
    [randn(100,1)+6  randn(100,1)-2]
};
colors={'r','g','b'};  % az egyes osztalyokat ilyen szinekkel abrazoljuk
x=[randn*6 2*randn];   % ezt a pontot szeretnenk besorolni
r=3;                   % kiindulo sugar
dr=1;                  % ha egy pont sem esik a korbe, ennyivel noveljuk a sugarat

%% a priori valoszinusegek: P(C1), P(C2), ..., P(CN)
numClasses=length(dataset);
numDatapoints=0;
P_Ci=zeros(1,numClasses);
for ii=1:numClasses
    P_Ci(ii)=size(dataset{ii},1);
    numDatapoints=numDatapoints+size(dataset{ii},1);
end
P_Ci=P_Ci/numDatapoints;

%% likelihood ertekek: P(x|C1), P(x|C2), ..., P(x|CN)
P_x_Ci=zeros(1,numClasses);
while ~any(P_x_Ci)
    for ii=1:numClasses
        for jj=1:size(dataset{ii},1)
            if sum((x-dataset{ii}(jj,:)).^2)<=r^2
                P_x_Ci(ii)=P_x_Ci(ii)+1/size(dataset{ii},1);
            end
        end
    end
    r=r+dr;
end
fprintf('Final radius: %.2f\n\n',r-dr);

%% dontes az a posteriori valoszinusegek alapjan: P(C1|x), P(C2|x), ..., P(CN|x)
P_Ci_x=P_x_Ci.*P_Ci/sum(P_x_Ci.*P_Ci);
[~,output]=max(P_Ci_x);
fprintf('Predicted class: %d\n\n',output);

%% abrazolas
figure(1);
for ii=1:numClasses
    plot(dataset{ii}(:,1),dataset{ii}(:,2),'.','Color',colors{ii});
    hold on;
end
plot(x(:,1),x(:,2),'ko','MarkerFaceColor',colors{output});
hold off;