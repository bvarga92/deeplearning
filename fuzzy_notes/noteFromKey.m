%Az atadott billentyuhoz visszaadja a hangot stringkent, MAGYAR rendszerben! (B=A#, H=Cb)
%Ha key vektor, akkor az ismetlodeseket eltavolitva visszaadja a kottat.

function note=noteFromKey(key)
    scale={'G#/Ab','A','A#/B','H','C','C#/Db','D','D#/Eb','E','F','F#/Gb','G'};
    note=[];
    prev=-1;
    for ii=1:length(key)
        if key(ii)==prev; continue; end;
        note=[note,scale{mod(key(ii),12)+1},' (',num2str(floor((key(ii)+8)/12)),sprintf(')\n')];
        prev=key(ii);
    end
