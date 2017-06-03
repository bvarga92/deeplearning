%Kivagja az egyes leuteseket
    %in:    a hangfelvetel
    %level: trigger szint, innen kezdjuk a kivagast
    %L:     ilyen hosszan vagjuk ki a 
    %minD:  minimalis tavolsag ket megutes kozott
    %N:     ennyi leutest sikerult kivagni
    %out:   a kivagott leutesek (NxL meretu matrix)

function [out,N]=cut(in,level,L,minD)
    pos=find(abs(in)>=level);
    start=pos(1);
    jj=1;
    for ii=2:length(pos)-1,
        if pos(ii)>(start+max(minD,L+1))
            start=pos(ii);
            out(jj,:)=in((pos(ii-1)+1):(pos(ii-1)+L));
            jj=jj+1;
        end
    end
    out(jj,:)=in((pos(end)+1):(pos(end)+L));
    N=size(out,1);
    ii=1;
    while ii<=N
        if max(abs(out(ii,:)))>=level
            out(ii,:)=[];
            N=N-1;
        else
            ii=ii+1;
        end
    end
