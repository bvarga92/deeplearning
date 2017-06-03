clear all;
clc;

%% PARAMETEREK
file='boci.wav'; %a WAV fajl neve (mono!)
Tstart=0.0;      %kottazas kezdete (s)
Tseg=0.4;        %egy szegmens hossza (s)
ol=0.0;          %szegmensek kozti atlapolodas (s)
NFFT=16384;      %DFT pontszam
fn=@(n) 2.^((n-49)/12)*440; %n-edik zongorabillentyu frekvenciaja (Hz)
keys=40:62;      %ezeket a hangokat szeretnenk felismerni (1...88, 40 a kozepso C)
fmin=200;        %a vizsgalt frekvenciatartomany also hatara (Hz)
fmax=1000;       %a vizsgalt frekvenciatartomany felso hatara (Hz)

%% BETOLTES, SZEGMENTALAS
[y,fs,b]=wavread(file);
yseg=segm(y((1+round(fs*Tstart)):end),round(fs*Tseg),round(fs*ol));
Nseg=size(yseg,1);
fprintf('%d szegmenst sikerult kivagni.\n',Nseg);

%% SPEKTRUM
fprintf('A spektrum felbontasa %.2f Hz.\n',fs/NFFT);
f=(ceil(fmin*NFFT/fs):floor(fmax*NFFT/fs))*fs/NFFT;
spect=zeros(Nseg,length(f));
figure(1);
subplot(211);
hold on;
for ii=1:Nseg
    p=psd(yseg(ii,:),NFFT,fs,hanning(NFFT));
    p=p(ceil(fmin*NFFT/fs):floor(fmax*NFFT/fs));
    if max(p)~=0; p=p/max(p); end;
    spect(ii,:)=p;
    plot(f,p);
end
hold off;
xlim([fmin fmax]);
title('A spektrumok');
xlabel('f [Hz]');
ylabel('|S|');

%% FUZZY RENDSZER LETREHOZASA
fis=newfis('kottazo','mamdani');
fis=addvar(fis,'input','freq',[fmin fmax]);
fis=addvar(fis,'input','amp',[0 1]);
fis=addvar(fis,'output','key',[min(keys)-6 max(keys)+1]);
for ii=1:length(keys)
    fis=addmf(fis,'input',1,num2str(keys(ii)),'gaussmf',[0.4*2^(keys(ii)/12) fn(keys(ii))]);
end
fis=addmf(fis,'input',2,'quiet','zmf',[0.7 1]);
fis=addmf(fis,'input',2,'loud','smf',[0.7 1]);
for ii=1:length(keys)
    fis=addmf(fis,'output',1,num2str(keys(ii)),'trimf',[keys(ii)-1 keys(ii) keys(ii)+1]);
end
fis=addmf(fis,'output',1,'invalid','trimf',[min(keys)-6 min(keys)-5 min(keys)-4]);
for ii=1:length(keys)
    R(2*ii-1,:)=[ii   1   length(keys)+1   1   1]; %ha halk, akkor invalid
    R(2*ii+0,:)=[ii   2         ii         1   1];
end
fis=addrule(fis,R);
fis=setfis(fis,'defuzzmethod','mom');
figure(1);
subplot(212);
plotmf(fis,'input',1,10000);
title('Tagsagi fuggvenyek a freq bemenethez');
figure(2);
subplot(211);
plotmf(fis,'input',2,10000);
title('Tagsagi fuggvenyek az amp bemenethez');
figure(2);
subplot(212);
plotmf(fis,'output',1,10000);
title('Tagsagi fuggvenyek a key kimenethez');
figure(3);
plotfis(fis);

%% A FUZZY RENDSZER MUKODTETESE
output=zeros(Nseg,1);
for ii=1:Nseg
    output(ii)=round(max(evalfis([f' spect(ii,:)'],fis)));
end
figure(4);
stairs(output);
axis([1 Nseg+1 min(output)-1 max(output)+1]);
grid on;
title('A fuzzy rendszer kimenete');
xlabel('szegmens');
ylabel('hang');
fprintf('A becsult kotta:\n%s',noteFromKey(output(output~=(keys(1)-5))));
