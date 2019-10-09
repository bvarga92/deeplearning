clear all;
clc;

M = 1;           % kocsi tomege
m = 0.1;         % ingasuly tomege
L = 1;           % inga hossza
Ts = 1e-2;       % mintaveteli idokoz
x0 = 0;          % kocsi kezdeti pozicioja
theta0 = 0.1;    % inga kezdeti szogelfordulasa a fuggolegeshez kepest
F = [-2*ones(1,100) 10*ones(1,20) zeros(1,1000)]; % a kocsira hato ero

cp = Cartpole(M, m, L, x0, theta0);
[x, theta] = cp.simulate(F, Ts);

t = (0:length(x)-1)*Ts;
figure(1);
subplot(311);
plot(t, F);
xlim(minmax(t));
xlabel('t [s]');
ylabel('F [N]');
subplot(312);
plot(t, x);
xlim(minmax(t));
xlabel('t [s]');
ylabel('x [m]');
subplot(313);
plot(t, wrapTo2Pi(theta)/pi*180);
xlim(minmax(t));
xlabel('t [s]');
ylabel('\theta [\circ]');

figure(2);
cp.animate(x, theta);