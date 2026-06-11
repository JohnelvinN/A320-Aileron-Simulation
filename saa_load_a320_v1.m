clear;
clc;
close all;

%% Data
load("data.mat");
load("Coefficients_CL.txt");
load("Coefficients_CM.txt");

%% Parameters
c   = 0.4;
rho = 0.38;
S   = 1.2;

%% Velocity
vel_min = 115;
vel_max = 250;

Vel = linspace(vel_min, vel_max, 101);

%% Original database
def_orig = -15:5:15;    %rows
vel_orig = 115:15:250;  %columns

%% Interpolation
FCL = griddedInterpolant({def_orig, vel_orig}, Coefficients_CL, 'linear');

FCM = griddedInterpolant({def_orig, vel_orig}, Coefficients_CM, 'linear');

%% Output matrix
F_p = zeros(length(theta_deg), length(Vel));

%% Main calculation
for i = 1:length(theta_deg)
    denom = r * sqrt(1 - ((r^2 - D^2 + P(i)^2)/(2*r*P(i)))^2);
    for k = 1:length(Vel)
        v = Vel(k);
        % Interpolated coefficients
        cl = FCL(theta_deg(i), v);
        cm = FCM(theta_deg(i), v);
        % Lift force
        Lift = 0.5 * rho * v^2 * S * cl;
        % Aerodynamic moment
        Moment = 0.5 * rho * v^2 * S * c * cm;
        % Pushrod force
        F_p(i,k) = (Moment + 0.25*c*Lift) / denom;
    end
end

%% Plot
[Vmesh, THmesh] = meshgrid(Vel, theta_deg);

figure;
surf(Vmesh, THmesh, F_p);

xlabel('Velocity');
ylabel('Deflection Angle');
zlabel('Pushrod Force');

title('Pushrod Force Surface');
shading interp;
colorbar;
grid on;