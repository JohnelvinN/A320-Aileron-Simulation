clear;
clc;
close all;
%% Data
load("data.mat");

c = 0.4;
rho = 1.225;
S = 1.2;
b = S/c;
Vel = linspace(130, 230, 10);

function cl = C_L(alpha, v)
    cl = alpha*0.09*pi/180 + v/230;
end

function cm = C_M(alpha, v)
    cm = (alpha*0.09*pi/180 + v/230)*0.00001 + 0.01;
end

%% Load
F_p = zeros(length(theta_deg), length(Vel));

for i = 1:length(theta_deg)
    for k = 1:length(Vel)
        F_p_denom = 2*r*sqrt(1 - ((r^2 - D^2 + P(i)^2)/(2*r*P(i)))^2);
        F_p(i, k) = (rho * Vel(k)^2 * S *(b * C_M(theta_deg(i),Vel(k)) + 0.25*c*C_L(theta_deg(i),Vel(k)))) / F_p_denom;
    end
end

mesh(F_p);

