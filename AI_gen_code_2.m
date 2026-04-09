clear;
clc;
close all;

%% GEOMETRY (Hinge at leading edge = 0% chord)
R = 0.10;       % [m] Lever arm (hinge to actuator connection)
D = 0.085;      % [m] Fixed distance (hinge to actuator mount)
Bo_deg = 60;    % [degrees] Initial angle
Bo = Bo_deg * pi/180;

c = 0.4;        % [m] Aileron chord
S = 1.2;        % [m^2] Aileron area (estimate)
rho = 1.225;    % [kg/m^3] Air density

%% DEFLECTION RANGE
theta_deg = linspace(-25, 25, 100);
theta_rad = theta_deg * pi/180;

%% ACTUATOR LENGTH & EFFICIENCY
P = zeros(size(theta_rad));
for i = 1:length(theta_rad)
    B = Bo + theta_rad(i);
    P(i) = sqrt(R^2 + D^2 - 2*R*D*cos(B));
end

beta_rad = Bo + theta_rad;
sin_gamma = D * sin(beta_rad) ./ P;
sin_gamma = max(0, min(1, sin_gamma));

%% XFOIL DATA 
delta_data = [15; 10; 5; 0; -5; -10; -15];
CL_data = [1.1221; 0.7740; 0.3204; 0; -0.3362; -1.0186; -1.5390];
Cm_ac_data = [-0.1664; -0.1224; -0.0531; 0; 0.0565; 0.1719; 0.2491];

% Interpolate for smooth curves
CL = interp1(delta_data, CL_data, theta_deg, 'pchip');
Cm_ac = interp1(delta_data, Cm_ac_data, theta_deg, 'pchip');

%% CONVERT Cm FROM AC (25% chord) TO HINGE (0% chord)
Cm_hinge = Cm_ac - 0.25 * CL;

%% GRAPH 1: Aerodynamic Coefficients (LIGHT MODE)
figure('Position', [100, 100, 800, 500]);
set(gcf, 'Color', 'white');           % White figure background
set(gca, 'Color', 'white');           % White axes background
set(gca, 'XColor', 'black', 'YColor', 'black');  % Black axes lines
set(gca, 'GridColor', 'black');       % Black grid lines
grid on;

yyaxis left;
plot(theta_deg, CL, 'b-', 'LineWidth', 2);  % Blue for CL
ylabel('C_L', 'Color', 'blue', 'FontSize', 12);
ylim([-2, 2]);

yyaxis right;
plot(theta_deg, Cm_hinge, 'r-', 'LineWidth', 2);  % Red for Cm
ylabel('C_m (about hinge)', 'Color', 'red', 'FontSize', 12);
ylim([-0.8, 0.4]);

xlabel('Aileron Deflection \theta [deg]', 'Color', 'black', 'FontSize', 12);
title('Aerodynamic Coefficients (Hinge at Leading Edge)', 'Color', 'black', 'FontSize', 14);
legend('C_L', 'C_m', 'Location', 'best');

%% GRAPH 2: Actuator Force at Different Speeds (LIGHT MODE)
V_list = [50, 70, 100, 150];
colors = {'b', 'r', 'g', 'k'};  % Blue, Red, Green, Black
labels = {'50 m/s', '70 m/s', '100 m/s', '150 m/s'};

figure('Position', [100, 100, 800, 500]);
set(gcf, 'Color', 'white');
set(gca, 'Color', 'white');
set(gca, 'XColor', 'black', 'YColor', 'black');
set(gca, 'GridColor', 'black');
hold on;
grid on;

for j = 1:length(V_list)
    V = V_list(j);
    M_hinge = 0.5 * rho * V^2 * S * c * (Cm_hinge + 0.25 * CL);
    Fp = M_hinge ./ (R * sin_gamma);
    Fp(sin_gamma < 0.05) = NaN;
    plot(theta_deg, Fp, '-', 'Color', colors{j}, 'LineWidth', 2);
end

xlabel('Aileron Deflection \theta [deg]', 'Color', 'black', 'FontSize', 12);
ylabel('Actuator Force F_p [N]', 'Color', 'black', 'FontSize', 12);
title('Actuator Force at Different Airspeeds', 'Color', 'black', 'FontSize', 14);
legend(labels, 'Location', 'best');
hold off;

%% PRINT RESULTS TO COMMAND WINDOW
fprintf('\n===== ACTUATOR FORCE RESULTS (Hinge at 0%% chord) =====\n');
fprintf('  θ(deg)    C_L       C_m       Fp@70m/s\n');
fprintf('--------------------------------------------\n');

for i = 1:length(delta_data)
    [~, idx] = min(abs(theta_deg - delta_data(i)));
    V = 70;
    M_hinge = 0.5 * rho * V^2 * S * c * (Cm_hinge(idx) + 0.25 * CL(idx));
    if sin_gamma(idx) > 0.05
        Fp_val = M_hinge / (R * sin_gamma(idx));
    else
        Fp_val = NaN;
    end
    fprintf('  %5.1f     %6.4f   %7.4f   %8.0f\n', ...
            theta_deg(idx), CL(idx), Cm_hinge(idx), Fp_val);
end
fprintf('==================================================\n');