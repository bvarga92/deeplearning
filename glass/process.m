clear all;
clc;

%% PARAMETEREK
fs=44100;         %mintaveteli frekvencia
level=0.8;        %kivagas szintje
L=3000;           %kivagas hossza
NFFT=512;         %DFT ponszama (paros!)
trainSetSize=0.6; %az adatok ekkora reszet hasznaljuk tanitasra
Nneur=5;          %neuronok szama a rejtett retegben
goal=1e-10;       %leallasi feltetel
epochs=100;       %max. epoch szam
min_grad=1e-10;   %min. gradiens
max_fail=6;       %early stopping, ha egymas utan ennyiszer no a validacios hiba

%% BETOLTES, KIVAGAS
data_empty=wavread('ures.wav');
data_full=wavread('teli.wav');
data_empty=data_empty/max(abs(data_empty));
data_full=data_full/max(abs(data_full));
[data_empty_cut,Ne]=cut(data_empty,level,L,5000);
[data_full_cut,Nf]=cut(data_full,level,L,5000);

%% SPEKTRUM
spect_empty=zeros(NFFT/2+1,Ne);
spect_full=zeros(NFFT/2+1,Nf);
figure(1);
subplot(211);
hold on;
for ii=1:Ne
    p=psd(data_empty_cut(ii,:)',NFFT,fs,hanning(NFFT));
    p=10*log10(p/max(p)+1e-3);
    spect_empty(:,ii)=p;
    plot((0:NFFT/2)*fs/NFFT/1000,p);
end
hold off;
grid on;
title('Spektrumok az ures poharhoz');
xlim([0 fs/2000]);
xlabel('f [kHz]');
ylabel('S [dB]');
subplot(212);
hold on;
for ii=1:Nf
    p=psd(data_full_cut(ii,:)',NFFT,fs,hanning(NFFT));
    p=10*log10(p/max(p)+1e-3);
    spect_full(:,ii)=p;
    plot((0:NFFT/2)*fs/NFFT/1000,p);
end
hold off;
grid on;
title('Spektrumok a teli poharhoz');
xlim([0 fs/2000]);
xlabel('f [kHz]');
ylabel('S [dB]');

%% TANITO ADATOK
out_empty=ones(1,Ne);
out_full=-ones(1,Nf);
N_train_e=floor(Ne*trainSetSize);
N_train_f=floor(Nf*trainSetSize);
N_valid_e=floor((Ne-N_train_e)/2);
N_valid_f=floor((Nf-N_train_f)/2);
N_test_e=Ne-N_train_e-N_valid_e;
N_test_f=Nf-N_train_f-N_valid_f;
train_in=[spect_empty(:,1:N_train_e) , spect_full(:,1:N_train_f)];
train_out=[out_empty(1:N_train_e) , out_full(1:N_train_f)];
perm=randperm(N_train_e+N_train_f);
train_in=train_in(:,perm);
train_out=train_out(perm);
valid_in=[spect_empty(:,(N_train_e+1):(N_train_e+N_valid_e)) , spect_full(:,(N_train_f+1):(N_train_f+N_valid_f))];
valid_out=[out_empty((N_train_e+1):(N_train_e+N_valid_e)) , out_full((N_train_f+1):(N_train_f+N_valid_f))];
test_in=[spect_empty(:,(N_valid_e+1):(N_valid_e+N_test_e)) , spect_full(:,(N_valid_f+1):(N_valid_f+N_test_f))];
test_out=[out_empty((N_valid_e+1):(N_valid_e+N_test_e)) , out_full((N_valid_f+1):(N_valid_f+N_test_f))];

%% NEURALIS HALO LETREHOZASA ES TANITASA
net=newff(minmax(train_in),[Nneur 1],{'tansig' 'tansig'});
valid.P=valid_in;
valid.T=valid_out;
test.P=test_in;
test.T=test_out;
net.trainParam.epochs=epochs;
net.trainParam.goal=goal;
net.trainParam.min_grad=min_grad;
net.trainParam.max_fail=max_fail;
net.performFcn='mse';
net.trainFcn='trainlm';
net=init(net);
[net tr]=train(net,train_in,train_out,[],[],valid,test);

%% HALO FUTTATASA
input=[spect_empty , spect_full];
ref=[out_empty , out_full];
output=sim(net,input);
err=sign(output)~=ref;
figure(2);
plot(output);
hold on;
plot(sign(output),'ro','MarkerFaceColor','r');
hold off;
title('A halo kimenete');
fprintf('Hibas osztalyozasok szama: %d\n',sum(err));
