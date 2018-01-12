clear all;
clc;

%% TANITO ADATOK (XOR PROBLEMA)
inputs=[ 0, 0, 1, 1;
         0, 1, 0, 1];
%        |  |  |  |
targets=[0, 1, 1, 0];

%% PARAMETEREK
hidden=[4 3];   % 2 rejtett reteg, 4 es 3 neuronnal
act='tansig';   % aktivacios fuggveny (minden retegben ez)
maxepochs=1000; % maximalis epochszam

%% HALO KONFIGURALASA ES TANITASA
net=newff(inputs,targets,hidden);
net.layers{1}.transferFcn=act;
net.layers{2}.transferFcn=act;
net.layers{3}.transferFcn=act;
net.outputs{3}.processFcns={};
net.inputs{1}.processFcns={};
net.trainParam.epochs=maxepochs;
net.trainParam.min_grad=1e-10;
net.divideParam.trainRatio=1;
net.divideParam.valRatio=0;
net.divideParam.testRatio=0;
net=train(net,inputs,targets);

%% ABRAZOLAS
[A,B]=meshgrid(-1:0.01:2,-1:0.01:2);
O=reshape(net([A(:)' ; B(:)']),size(A));
contourf(A,B,O);
hold on;
plot(inputs(1,:),inputs(2,:),'ko','MarkerFaceColor','k','MarkerSize',10);
hold off;
grid on;

%% PARAMETEREK KINYERESE
W01=[net.IW{1} net.b{1}]
fprintf('%f, ',W01(:)); fprintf('\n\n');
W12=[net.LW{2,1} net.b{2}]
fprintf('%f, ',W12(:)); fprintf('\n\n');
W23=[net.LW{3,2} net.b{3}]
fprintf('%f, ',W23(:)); fprintf('\n\n');

in=[1.123 ; 1.234];
error=sim(net,in) - tansig( W23*[ tansig( W12*[ tansig(W01*[in ; 1]) ; 1]) ; 1])
