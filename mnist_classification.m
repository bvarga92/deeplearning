clear all;
close all;
clc;

%% adatok beolvasasa
f=fopen('train_60k_labels.dat','r');
if f==-1
    error('Error opening training set labels file.');
end
if sum(fread(f,2,'2*int32','ieee-be')==[2049;60000])~=2
    error('Error reading training set labels file.');
end
[train_labels, bcnt]=fread(f,60000,'uint8');
if bcnt~=60000
    error('Error loading training set labels.');
end
fclose(f);
f=fopen('test_10k_labels.dat','r');
if f==-1
    error('Error opening test set labels file.');
end
if sum(fread(f,2,'2*int32','ieee-be')==[2049;10000])~=2
    error('Error reading test set labels file.');
end
[test_labels, bcnt]=fread(f,10000,'uint8');
if bcnt~=10000
    error('Error loading test set labels.');
end
fclose(f);
f=fopen('train_60k_images.dat','r');
if f==-1
    error('Error opening training set images file.');
end
if sum(fread(f,4,'4*int32','ieee-be')==[2051;60000;28;28])~=4
    error('Error reading training set images file.');
end
train_images=zeros([28 28 60000]);
for ii=1:60000
    [img, bcnt]=fread(f,[28 28],'784*uint8');
    if bcnt~=784
        error('Error loading training set images.');
    end
    train_images(:,:,ii)=img';
end
fclose(f);
f=fopen('test_10k_images.dat','r');
if f==-1
    error('Error opening test set images file.');
end
if sum(fread(f,4,'4*int32','ieee-be')==[2051;10000;28;28])~=4
    error('Error reading test set images file.');
end
test_images=zeros([28 28 10000]);
for ii=1:10000
    [img, bcnt]=fread(f,[28 28],'784*uint8');
    if bcnt~=784
        error('Error loading test set images.');
    end
    test_images(:,:,ii)=img';
end
fclose(f);

%% nehany veletlenszeruen valasztott kep abrazolasa
figure(1);
idx=randperm(60000);
idx=idx(1:9);
for ii=1:9
    subplot(3,3,ii);
    imshow(train_images(:,:,idx(ii)));
    title(sprintf('%d (training set)',train_labels(idx(ii))));
end
figure(2);
idx=randperm(10000);
idx=idx(1:9);
for ii=1:9
    subplot(3,3,ii);
    imshow(test_images(:,:,idx(ii)));
    title(sprintf('%d (test set)',test_labels(idx(ii))));
end
drawnow;

%% neuralis halo tanitasa
hidden=200; % rejtett retegbeli neuronok szama
lrate=5;    % tanulasi rata
epochs=10;  % tanitasi lepesek szama

train_images=reshape(permute(train_images,[2 1 3]),[784 60000]);
W12=2*rand(784+1,hidden)-1;
W23=2*rand(hidden+1,10)-1;
activation=@(x) 1./(1+exp(-0.01*x)); % szigmoid aktivacios fuggveny
dactivation=@(x) 0.01*exp(-0.01*x)./(1+exp(-0.01*x)).^2; % az aktivacios fuggveny derivaltja
tic;
for ii=1:epochs
    err_cum=0;
    for jj=1:60000
        % a bemenet vegigterjesztese
        layer1=[train_images(:,jj) ; 1];
        layer2=[activation(W12'*layer1) ; 1];
        layer3=activation(W23'*layer2);
        % gradiensek szamitasa
        err=layer3-((0:9)'==train_labels(jj));
        err_cum=err_cum+sum(err.^2);
        delta23=err.*dactivation(layer3);
        delta12=(W23(1:end-1,:)*delta23).*dactivation(layer2(1:end-1));
        % sulymodositas
        W12=W12-lrate*(layer1*delta12');
        W23=W23-lrate*(layer2*delta23');
    end
    fprintf('Step %d, error: %.2f.\n',ii,err_cum);
end
secs=toc;
fprintf('Training done in %.2f minutes.\n\n',secs/60);

%% a halo tesztelese
output=zeros(size(test_labels));
for ii=1:10000
    layer1=[reshape(test_images(:,:,ii)',[784 1]) ; 1];
    layer2=[activation(W12'*layer1) ; 1];
    layer3=activation(W23'*layer2);
    [m,argmax]=max(layer3);
    output(ii)=argmax-1;
end
errors=find(output-test_labels);
accuracy=1-length(errors)/10000;
fprintf('Neural network accuracy: %.1f%%\n\n',accuracy*100);
for ii=1:min(length(errors),45)
    figure(100+floor((ii-1)/9)+1);
    subplot(3,3,mod(ii-1,9)+1);
    imshow(test_images(:,:,errors(ii)));
    title(sprintf('Class %d, classified as %d',test_labels(errors(ii)),output(errors(ii))));
end
drawnow;

%% osztalyozas a legkozelebbi szomszed alapjan
output=zeros(size(test_labels));
tic;
for ii=1:10000
    cur=reshape(test_images(:,:,ii)',[784 1]);
    d=zeros(1,60000);
    for jj=1:60000
        d(jj)=sum((cur-train_images(:,jj)).^2);
    end
    [m,closest]=min(d);
    output(ii)=train_labels(closest);
end
secs=toc;
fprintf('Nearest neighbor classification done in %.2f minutes.\n\n',secs/60);
errors=find(output-test_labels);
accuracy=1-length(errors)/10000;
fprintf('Nearest neighbor accuracy: %.1f%%\n\n',accuracy*100);