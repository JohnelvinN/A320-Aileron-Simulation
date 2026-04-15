clear;
clc;
close all;
%% Data
load("data.mat");
load("Coefficients_CL.txt")
load("Coefficients_CM.txt")

c = 0.4;
rho = 0.38;
S = 1.2;
b = S/c;
Vel = flip(175:15:250);

function cl = C_L(alpha, k, Coeff)
    def = flip(-15:5:15);
    cl_data = Coeff(:,k);    
    line = polyfit(def, cl_data, 1);
    cl = alpha*line(1) + line(2);
end

function cm = C_M(alpha, k, Coeff)
    def = flip(-15:5:15);
    cm_data = Coeff(:,k);    
    line = polyfit(def, cm_data, 1);
    cm = alpha*line(1) + line(2);
end

%% Load
F_p = linspace(0, 1, length(theta_deg));

function fl=F_L(v, rho, S, cl)
    fl = rho * v^2 *0.5 * S * cl;
end

function ma=Ma(v, rho, S, ch, ca)
    ma = rho * v^2 *0.5 * S * ch * ca;
end

for i = 1:length(theta_deg)
    for k = 1:length(Vel)
        F_p_denom = r*sqrt(1 - ((r^2 - D^2 + P(i)^2)/(2*r*P(i)))^2);
        F_p(i) = (Ma(Vel(k), rho, S, C_M(theta_deg(i), k, Coefficients_CM), c) + 0.25*c*F_L(Vel(k), rho, S, C_L(theta_deg(i), k, Coefficients_CL))) / F_p_denom;
    end
end

plot(theta_deg, F_p,'b-','LineWidth',2);

