clear;
clc;
close all;

%% The Main Variables Declared
r=0.10;  % [m] Distance from hinge to actuator connection 
D=0.085;   % [m] Distance from hinge to the actuator fixed point
Bo_deg=60;  % [degrees] Initial Angle between D and r

Bo=Bo_deg*pi/180;

%% Now to Claculate the Initial Length of the actuator (Lo) using the cosine rule
Po=sqrt(r^2+D^2-2*r*D*cos(Bo));
fprintf('Neutral actuator length Lo =%.1f mm\n',Po*1000);

%% Now just to declare the ranges of the aileron deflection
theta_min_deg=-25;
theta_max_deg=25;
theta_deg=linspace(theta_min_deg,theta_max_deg,100);

theta_rad=theta_deg*pi/180;

P=zeros(size(theta_rad));  % Array that will hold the values of P (new Lengths of the actuator) as they are being calculated in the for loop


for i=1:length(theta_rad)
    B =Bo+theta_rad(i);               % New Angle calculated
    P(i)=sqrt(r^2+D^2-2*r*D*cos(B));     %New Actuator length
end

x=P-Po;  % The Extension
x_mm=x *1000;

figure('Position',[100 100 800 500]);

hold on;
%Now the plot commences
plot(x_mm,theta_deg,'b-','LineWidth',2);
xlabel('Actuator Extension x [mm]');
ylabel('Aileron Deflection \theta [deg]');
title('A320 Aileron: Actuator Extension vs Deflection Angle');
grid on;
hold off;



%% Actuator Force Calculation
%****************************************************************************************************************

% X-foil data from Sonmetz

delta_data_deg = [15; 10; 5; 0; -5; -10; -15];    % deflection angle
CL_data = [1.1221; 0.7740; 0.3204; 0; -0.3362; -1.0186; -1.5390];    %lift coefficient
Cm_data = [-0.1664; -0.1224; -0.0531; 0; 0.0565; 0.1719; 0.2491];      % Moment coefficient

CL = interp1(delta_data_deg, CL_data, theta_deg, 'pchip', 'extrap');    % Addition of chatyyy for interpolation and get more points for smoother curve
Cm = interp1(delta_data_deg, Cm_data, theta_deg, 'pchip', 'extrap');      % Addition of chatyyy for interpolation and get more points 

rho = 1.225;    % [kg/m^3] Air density at sea level
V = 70;         % [m/s] Airspeed could be changeedddddddddddddddddddddddddd!!!!!!!!!!!!!!!!!

S = 1.2;        % [m^2] Aileron surface area
b = 2.5;        % [m] Aileron span
c = 0.4;        % [m] Aileron chord
R = r;          % [m] Lever arm (same as r) to match what is in the code and the formula everyone happy @misha :)👍


% Calculating beta angle for each deflection
beta_rad = Bo + theta_rad;  % Beta in radians

%sqrt on the denominator simplified
sqrt_term = sqrt(1 - P ./ (D * sin(beta_rad)));

%%%%%%% this point onwards is AIIIIIIIIIIII dont blame me, its late

%% Step 5: Calculate the top half (aerodynamic twist)
Top = rho * V^2 * S * (b * Cm + 0.25 * c * CL);

%% Step 6: Calculate the bottom half (actuator leverage)
Bottom = 2 * R * sqrt_term;

%% Step 7: Calculate actuator force Fp
Fp = Top ./ Bottom;

%% Step 8: Plot actuator force vs deflection
figure('Position',[100 100 800 500]);
plot(theta_deg, Fp, 'r-', 'LineWidth', 2);
xlabel('Aileron Deflection \theta [deg]');
ylabel('Actuator Force F_p [N]');
title(sprintf('Actuator Force vs Deflection at V = %.0f m/s', V));
grid on;

%% Step 9: Plot CL and Cm vs deflection 
figure('Position',[100 100 800 500]);

% Plot CL on left side
yyaxis left;
plot(theta_deg, CL, 'b-', 'LineWidth', 2);
ylabel('Lift Coefficient C_L');

% Plot Cm on right side
yyaxis right;
plot(theta_deg, Cm, 'r-', 'LineWidth', 2);
ylabel('Moment Coefficient C_m');

xlabel('Aileron Deflection \theta [deg]');
title('Aerodynamic Coefficients from XFOIL (Aileron Only)');
grid on;
legend('C_L', 'C_m', 'Location', 'best');

%% Step 10: Print some results to command window
fprintf('\n========================================\n');
fprintf('ACTUATOR FORCE RESULTS AT V = %.0f m/s\n', V);
fprintf('========================================\n');
fprintf('  θ (deg)    CL        Cm        Fp (N)\n');
fprintf('----------------------------------------\n');

% Print at specific angles 
for i = 1:length(delta_data_deg)
    % Find index where theta_deg is closest to delta_data_deg(i)
    [~, idx] = min(abs(theta_deg - delta_data_deg(i)));
    fprintf('  %5.1f     %6.4f   %7.4f   %8.1f\n', ...
            theta_deg(idx), CL(idx), Cm(idx), Fp(idx));
end
fprintf('========================================\n');

%% BONUS: Try different airspeeds (optional)
V_list = [50, 70, 100, 150];
colors = {'r', 'b', 'g', 'k'};

figure('Position',[100 100 800 500]);
hold on;

for j = 1:length(V_list)
    V_current = V_list(j);
    Top_current = rho * V_current^2 * S * (b * Cm + 0.25 * c * CL);
    Fp_current = Top_current ./ Bottom;
    plot(theta_deg, Fp_current, '-', 'Color', colors{j}, 'LineWidth', 2);
end

hold off;
xlabel('Aileron Deflection \theta [deg]');
ylabel('Actuator Force F_p [N]');
title('Actuator Force at Different Airspeeds');
legend('V = 50 m/s', 'V = 70 m/s', 'V = 100 m/s', 'V = 150 m/s', 'Location', 'best');
grid on;