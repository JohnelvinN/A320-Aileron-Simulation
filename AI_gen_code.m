clear;
clc;
close all;

%% ============================================
%% PART 1: GEOMETRY & KINEMATICS
%% ============================================

% Geometry constants
r = 0.10;       % [m] Lever arm (hinge to actuator connection)
D = 0.085;      % [m] Fixed distance (hinge to actuator mount)
Bo_deg = 60;    % [degrees] Initial angle at neutral
Bo = Bo_deg * pi/180;  % [rad]

% Deflection range
theta_deg = linspace(-25, 25, 100);
theta_rad = theta_deg * pi/180;

% Calculate actuator length P for each angle
P = zeros(size(theta_rad));
for i = 1:length(theta_rad)
    B = Bo + theta_rad(i);
    P(i) = sqrt(r^2 + D^2 - 2*r*D*cos(B));
end

% Calculate sin(gamma) - actuator efficiency
beta_rad = Bo + theta_rad;
sin_gamma = D * sin(beta_rad) ./ P;
sin_gamma = max(0, min(1, sin_gamma));  % Clamp between 0 and 1

%% ============================================
%% PART 2: AERODYNAMIC DATA FROM XFOIL
%% ============================================

% Bertuğ's XFOIL data
delta_data_deg = [15; 10; 5; 0; -5; -10; -15];
CL_data = [1.1221; 0.7740; 0.3204; 0; -0.3362; -1.0186; -1.5390];
Cm_data = [-0.1664; -0.1224; -0.0531; 0; 0.0565; 0.1719; 0.2491];

% Interpolate for smooth curves
CL = interp1(delta_data_deg, CL_data, theta_deg, 'pchip', 'extrap');
Cm = interp1(delta_data_deg, Cm_data, theta_deg, 'pchip', 'extrap');

%% ============================================
%% PART 3: AERODYNAMIC CONSTANTS
%% ============================================

rho = 1.225;    % [kg/m^3] Air density
S = 1.2;        % [m^2] Aileron area
c = 0.4;        % [m] Aileron chord
R = r;          % [m] Lever arm

%% ============================================
%% GRAPH 1: AERODYNAMIC COEFFICIENTS (CL and Cm)
%% ============================================

figure('Position', [100, 100, 900, 600]);
set(gcf, 'Color', 'black');           % Black background for figure
set(gca, 'Color', 'black');           % Black background for axes
set(gca, 'XColor', 'white', 'YColor', 'white');  % White axes lines
set(gca, 'GridColor', 'white');       % White grid lines
grid on;

% Plot CL on left Y-axis (bright cyan)
yyaxis left;
plot(theta_deg, CL, 'c-', 'LineWidth', 2.5);
ylabel('Lift Coefficient C_L', 'Color', 'cyan', 'FontSize', 12);
ylim([-1.8, 1.8]);

% Plot Cm on right Y-axis (bright magenta)
yyaxis right;
plot(theta_deg, Cm, 'm-', 'LineWidth', 2.5);
ylabel('Moment Coefficient C_m', 'Color', 'magenta', 'FontSize', 12);
ylim([-0.3, 0.3]);

xlabel('Aileron Deflection \theta [deg]', 'Color', 'white', 'FontSize', 12);
title('Aerodynamic Coefficients from XFOIL (Aileron Only)', 'Color', 'white', 'FontSize', 14);
legend('C_L', 'C_m', 'TextColor', 'white', 'Color', 'black', 'Location', 'best');
grid on;

%% ============================================
%% GRAPH 2: ACTUATOR FORCE AT DIFFERENT AIRSPEEDS
%% ============================================

% Airspeeds to plot
V_list = [50, 70, 100, 150];  % m/s
% Bright colors for black background
colors = {'#00FF00', '#00FFFF', '#FF00FF', '#FFFF00'};  % Green, Cyan, Magenta, Yellow
speed_labels = {'V = 50 m/s', 'V = 70 m/s', 'V = 100 m/s', 'V = 150 m/s'};

figure('Position', [100, 100, 900, 600]);
set(gcf, 'Color', 'black');
set(gca, 'Color', 'black');
set(gca, 'XColor', 'white', 'YColor', 'white');
set(gca, 'GridColor', 'white');
hold on;
grid on;

% Calculate and plot Fp for each speed
for j = 1:length(V_list)
    V_current = V_list(j);
    
    % Hinge moment from aerodynamics
    M_hinge = 0.5 * rho * V_current^2 * S * c * (Cm + 0.25 * CL);
    
    % Actuator force
    Fp = M_hinge ./ (R * sin_gamma);
    
    % Handle invalid points (where sin_gamma is too small)
    Fp(sin_gamma < 0.05) = NaN;
    
    % Plot with bright color
    plot(theta_deg, Fp, '-', 'Color', colors{j}, 'LineWidth', 2.5);
end

hold off;
xlabel('Aileron Deflection \theta [deg]', 'Color', 'white', 'FontSize', 12);
ylabel('Actuator Force F_p [N]', 'Color', 'white', 'FontSize', 12);
title('Actuator Force vs Aileron Deflection at Different Airspeeds', 'Color', 'white', 'FontSize', 14);
legend(speed_labels, 'TextColor', 'white', 'Color', 'black', 'Location', 'best');
grid on;

%% ============================================
%% OPTIONAL: Print numerical results to command window
%% ============================================

fprintf('\n==================================================\n');
fprintf('ACTUATOR FORCE RESULTS\n');
fprintf('==================================================\n');
fprintf('  θ (deg)    C_L        C_m       Fp@50   Fp@70   Fp@100  Fp@150\n');
fprintf('--------------------------------------------------\n');

for i = 1:length(delta_data_deg)
    [~, idx] = min(abs(theta_deg - delta_data_deg(i)));
    
    % Calculate forces at this deflection for each speed
    forces = zeros(1, 4);
    for j = 1:4
        V_current = V_list(j);
        M_hinge = 0.5 * rho * V_current^2 * S * c * (Cm(idx) + 0.25 * CL(idx));
        if sin_gamma(idx) > 0.05
            forces(j) = M_hinge / (R * sin_gamma(idx));
        else
            forces(j) = NaN;
        end
    end
    
    fprintf('  %5.1f     %6.4f   %7.4f   %7.0f  %7.0f  %7.0f  %7.0f\n', ...
            theta_deg(idx), CL(idx), Cm(idx), forces(1), forces(2), forces(3), forces(4));
end
fprintf('==================================================\n');