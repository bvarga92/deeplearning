clear all;
clc;

%% PARAMETEREK
learningRate=0.8;      % tanulasi rata
trainingSessions=1000; % epochszam
numStates=9;           % allapotok szama
goalState=9;           % celallapot
initialState=3;        % kezdoallapot a szimulaciohoz

%% JUTALOMFUGGVENY
R=[-1  0 -1 -1 -1  -1 -1  -1  -1;
    0 -1  0 -1  0  -1 -1  -1  -1;
   -1  0 -1 -1 -1  -1 -1  -1  -1;
   -1 -1 -1 -1  0  -1  0  -1  -1;
   -1  0 -1  0 -1 100 -1  -1  -1;
   -1 -1 -1 -1  0  -1 -1  -1 100;
   -1 -1 -1 0  -1  -1 -1 100  -1;
   -1 -1 -1 -1 -1  -1  0  -1 100;
   -1 -1 -1 -1 -1   0 -1   0 100];
reward=@(from,to) R(from,to);

%% TANITAS
Q=zeros(numStates,numStates);
for ii=1:trainingSessions
    currentState=ceil(numStates*rand);
    while 1
        reachableStates=[];
        for jj=1:numStates
            if reward(currentState,jj)~=-1
                reachableStates(end+1)=jj;
            end
        end
        nextState=reachableStates(ceil(length(reachableStates)*rand));
        Q(currentState,nextState)=reward(currentState,nextState)+learningRate*max(Q(nextState,:));
        if currentState~=goalState; break; end
        currentState=nextState;
    end
end
Q=Q/max(max(Q))

%% SZIMULACIO
transitions=initialState;
while transitions(end)~=goalState
    [m,s]=max(Q(transitions(end),:));
    transitions(end+1)=s(ceil(length(s)*rand));
end
transitions

%% ANIMACIO
figure(1);
clf(1);
axis([0 3 0 3]);
axis equal off;
for ii=0:2
    for jj=0:2
        rectangle('Position',[ii jj 1 1],'FaceColor','w');
    end
end
for ii=0:2
    for jj=1:2
        if reward(ii*3+jj,ii*3+jj+1)~=-1
            rectangle('Position',[jj-0.2 2.3-ii 0.4 0.4],'FaceColor','w','EdgeColor','none');
        end
        if reward((jj-1)*3+ii+1,jj*3+ii+1)~=-1
            rectangle('Position',[ii+0.3 2.8-jj 0.4 0.4],'FaceColor','w','EdgeColor','none');
        end
    end
end
rectangle('Position',[mod((transitions(1))-1,3)+0.4 floor((9-transitions(1))/3)+0.4 0.2 0.2],'FaceColor','k','Curvature',[1 1]);
for ii=2:length(transitions)
    pause(0.5);
    rectangle('Position',[mod((transitions(ii-1))-1,3)+0.35 floor((9-transitions(ii-1))/3)+0.35 0.3 0.3],'FaceColor','w','EdgeColor','none','Curvature',[1 1]);
    rectangle('Position',[mod((transitions(ii))-1,3)+0.4 floor((9-transitions(ii))/3)+0.4 0.2 0.2],'FaceColor','k','Curvature',[1 1]);
end