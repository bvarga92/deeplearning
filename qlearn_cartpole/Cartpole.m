classdef Cartpole < handle
    properties
        M
        m
        L
        x
        theta
        v
        omega
        g=9.81
    end

    methods
        function obj = Cartpole(M, m, L, x0, theta0)
            obj.M = M;
            obj.m = m;
            obj.L = L;
            obj.x = x0;
            obj.theta = theta0;
            obj.v = 0;
            obj.omega = 0;
        end

        function state = dState(obj, state, F)
            state = [state(3) ;
                     state(4) ;
                    (F-obj.m*obj.L*state(4)^2*sin(state(2))+obj.m*obj.g*sin(state(2))*cos(state(2)))/(obj.M+obj.m-obj.m*cos(state(2))^2)
                    (obj.g*sin(state(2))+cos(state(2))/(obj.m+obj.M)*(F-obj.m*obj.L*state(4)^2*sin(state(2))))/(obj.L-cos(state(2))^2*obj.m*obj.L/(obj.m+obj.M))
            ];
        end

        function step(obj, F, Ts)
            state = [obj.x ; obj.theta ; obj.v ; obj.omega];
            a = obj.dState(state, F);
            b = obj.dState(state+0.5*Ts*a, F);
            c = obj.dState(state+0.5*Ts*b, F);
            d = obj.dState(state+Ts*c, F);
            state = state + Ts*(a+2*b+2*c+d)/6;
            obj.x = state(1);
            obj.theta = state(2);
            obj.v = state(3);
            obj.omega = state(4);
        end

        function [x, theta, v, omega] = simulate(obj, F, Ts)
            x = zeros(1, length(F));
            theta = zeros(1, length(F));
            v = zeros(1, length(F));
            omega = zeros(1, length(F));
            for ii=1:length(F)
                x(ii) = obj.x;
                theta(ii) = obj.theta;
                v(ii) = obj.v;
                omega(ii) = obj.omega;
                obj.step(F(ii), Ts);
            end
        end

        function plot(obj)
            xlims = obj.x + [-max(0.5, obj.L) max(0.5, obj.L)];
            xlims = xlims*1.1;
            plot([obj.x-0.5 obj.x+0.5],[-0.2 -0.2]);
            hold on;
            plot(xlims, [-0.3 -0.3], 'k')
            plot([obj.x-0.5 obj.x+0.5], [0 0]);
            plot([obj.x-0.5 obj.x-0.5], [-0.2 0]);
            plot([obj.x+0.5 obj.x+0.5], [-0.2 0]);
            t=linspace(0,2*pi,100);
            plot(obj.x+0.05*cos(t)-0.25, 0.05*sin(t)-0.25);
            plot(obj.x+0.05*cos(t)+0.25, 0.05*sin(t)-0.25);
            plot([obj.x obj.x-obj.L*sin(obj.theta)], [0 obj.L*cos(obj.theta)], 'r');
            plot(obj.x-obj.L*sin(obj.theta), obj.L*cos(obj.theta), 'ro', 'markerfacecolor', 'r');
            hold off;
            axis equal;
            axis([xlims -obj.L*1.1 obj.L*1.1]);
        end

        function animate(obj, x, theta)
            xlims = minmax(x(:)') + [-max(0.5, obj.L) max(0.5, obj.L)];
            for ii=1:length(x)
                plot([x(ii)-0.5 x(ii)+0.5],[-0.2 -0.2]);
                hold on;
                plot(xlims, [-0.3 -0.3], 'k')
                plot([x(ii)-0.5 x(ii)+0.5], [0 0]);
                plot([x(ii)-0.5 x(ii)-0.5], [-0.2 0]);
                plot([x(ii)+0.5 x(ii)+0.5], [-0.2 0]);
                t=linspace(0,2*pi,100);
                plot(x(ii)+0.05*cos(t)-0.25, 0.05*sin(t)-0.25);
                plot(x(ii)+0.05*cos(t)+0.25, 0.05*sin(t)-0.25);
                plot([x(ii) x(ii)-obj.L*sin(theta(ii))], [0 obj.L*cos(theta(ii))], 'r');
                plot(x(ii)-obj.L*sin(theta(ii)), obj.L*cos(theta(ii)), 'ro', 'markerfacecolor', 'r');
                hold off;
                axis equal;
                axis([xlims -obj.L*1.1 obj.L*1.1]);
                pause(0.01);
            end
        end

    end

end