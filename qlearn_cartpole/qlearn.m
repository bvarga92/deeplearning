clear all;
clc;

%% parameterek
M = 1;           % kocsi tomege
m = 0.1;         % ingasuly tomege
L = 1;           % inga hossza
Ts = 1e-2;       % mintaveteli idokoz
x0 = 0;          % kocsi kezdeti pozicioja
theta0 = 0.01;   % inga kezdeti szogelfordulasa a fuggolegeshez kepest
alpha = 0.2;     % tanulasi rata
p = 0.05;        % veletlen akciovalasztas valoszinusege
maxiter = 10000; % tanitasi lepesek szama
loadQ = false;   % toltsuk-e be fajlbol a matrixot tanitas helyett?
N = 1000;        % szimulacio hossza

%% allapotter diszkretizalasa
limits_theta = [-0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4];
limits_omega = [-2 -1 0 1 2];
F_values = [-10 0 10];

%% tanitas
cp = Cartpole(M, m, L, x0, theta0);
Q = zeros((length(limits_theta)-1)*(length(limits_omega)-1), length(F_values));

get_state = @(theta, omega) (find(wrapToPi(theta)<=limits_theta, 1, 'first')-1)*(find(omega<=limits_omega, 1, 'first')-1);
get_reward = @(theta, omega, theta_prev, omega_prev) -1 + 2*((sign(theta) ~= sign(theta_prev)) || (abs(wrapToPi(theta)) <= abs(wrapToPi(theta_prev))) || (sign(omega) == sign(omega_prev) && abs(omega) <= abs(omega_prev)));

if ~loadQ
    for ii = 1:maxiter
        % aktualis allapot meghatarozasa
        theta = cp.theta;
        omega = cp.omega;
        state = get_state(theta, omega);
        % akcio valasztasa es vegrehajtasa
        if rand<p
            action = randi(length(F_values));
        else
            [~, action] = max(Q(state,:));
        end
        cp.step(F_values(action), Ts);
        new_state = get_state(cp.theta, cp.omega);
        if wrapToPi(cp.theta)<limits_theta(1) || wrapToPi(cp.theta)>limits_theta(end) % eldolt
            cp = Cartpole(M, m, L, x0, theta0);
            continue;
        end
        % tanulas
        reward = get_reward(cp.theta, cp.omega, theta, omega);
        Q(state,action) = reward + alpha*max(Q(new_state,:));
    end
else
    load('Q.mat');
end

%% szimulacio
F = [];
cp = Cartpole(M, m, L, x0, theta0);
for ii = 1:N
    theta = wrapToPi(cp.theta);
    state = get_state(theta, cp.omega);
    if theta<limits_theta(1) || theta>limits_theta(end)
        break;
    end
    [~, action] = max(Q(state,:));
    F(ii) = F_values(action);
    cp.step(F(ii), Ts);
end

cp = Cartpole(M, m, L, x0, theta0);
[x, theta, v, omega] = cp.simulate(F, Ts);

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
