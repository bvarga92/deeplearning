%Vektor szegmentalasa
    %y:  a bemeneti vektor
    %L:  ilyen hosszu szegmensekre bontjuk
    %ol: atlapolodas
    %ys: a kimeneti matrix, a szegmensek az egyes sorok
    %Ns: ennyi szegmenst vagtunk ki (ys sorainak szama)

function [ys,Ns]=segm(y,L,ol)
    N=floor((length(y)-L)/(L-ol))+1;
    r=mod((length(y)-L),L-ol);
    if r~=0
        ys=zeros(N+1,L);
        last=y((N*(L-ol)+1):end);
        ys(N+1,1:length(last))=last;
    else
        ys=zeros(N,L);
    end
    for ii=0:N-1
        ys(ii+1,:)=y((ii*(L-ol)+1):(ii*(L-ol)+L));
    end
    Ns=size(ys,1);
