clear;
clc;
close all;

%% The Main Variables Declared
r=0.10;  % [m] Distance from hinge to actuator connection 
D=0.059;   % [m] Distance from hinge to the actuator fixed point
Bo_deg=70;  % [degrees] Initial Angle between D and r

Bo=Bo_deg*pi/180;

%% Now to Claculate the Initial Length of the actuator (Lo) using the cosine rule
Po=sqrt(r^2+D^2-2*r*D*cos(Bo));
fprintf('Neutral actuator length Lo =%.1f mm\n',Po*1000);

%% Now just to declare the ranges of the aileron deflection
theta_min_deg=-25;
theta_max_deg=25;
theta_deg=linspace(theta_min_deg,theta_max_deg,101);

theta_rad=theta_deg*pi/180;

P=zeros(size(theta_rad));  % Array that will hold the values of P (new Lengths of the actuator) as they are being calculated in the for loop


for i=1:length(theta_rad)
    B =Bo+theta_rad(i);               % New Angle calculated
    P(i)=sqrt(r^2+D^2-2*r*D*cos(B));     %New Actuator length
end

save("data.mat", "Bo_deg", "theta_deg", "Po", "P", "r", "D");
x=P - min(P);  % The Extension
x_mm=x *1000;

%% Now the plot commences
figure('Position',[100 100 800 500]);
hold on;
plot(x_mm,theta_deg,'b-','LineWidth',2);
xlabel('Actuator Extension x [mm]');
ylabel('Aileron Deflection \theta [deg]');
title('A320 Aileron: Actuator Extension vs Deflection Angle');
grid on;
hold off;