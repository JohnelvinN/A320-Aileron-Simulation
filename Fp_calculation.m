clear;
clc;
close all;

%!!!!!!!!!!!!!!!!! For all this to work smothly I must change the range of
%the theta_deg in the inital geometry.
%Initial data

c=0.4;   % Chord length
v=250; % To be changed based on the values of speed used in Xfoil
S=1.2;
rho=0.38;
b=2.4;


%geometry for the aileron saved data.mat in the geometry code

load("data.mat");

load("Aero_data.mat");

R=r;



%addition of the Aerodynamic coefficients, (to be changed based on the
%format)
delta_data_o=[15; 10; 5; 0; -5; -10; -15];
Cl_d_o=[1.84540; 1.49730; 1.04370;0.72330;0.38710;-0.29530;-0.81570];
Cm_d_o=[-0.20800;-0.16400;-0.09470;-0.04160;0.01490;0.13030;0.20750];

%To flip the data
delta_data=flipud(delta_data_o);
Cl_d=flipud(Cl_d_o);
Cm_d=flipud(Cm_d_o);

% To extrapolate Cl and Cm values since they dont match the values from the
% initail geometry with 101 values in array
Cl=interp1(delta_data,Cl_d,theta_deg,"pchip","extrap");
Cm=interp1(delta_data,Cm_d,theta_deg,"pchip","extrap");

%preallocating space for top and bottom variables
top=zeros(size(Cm));
bottom=zeros(size(Cm));

%Now the numerator of the fp function

for i=1:length(theta_deg)

top(i)= rho*v^2*S*((c*Cm(i))+(0.25*c*Cl(i)));
bottom(i)= 2*r*sqrt(1-((R^2+P(i)^2-D^2)/(2*R*P(i)))^2);

end

Fp=top./bottom;

%To plot the graphs

plot    (theta_deg,Fp,'b-','LineWidth',2);
xlabel('Theta (degrees)');
ylabel('Fp ');
title('Actuator force vs deflection');
grid on;

mesh(v,theta_deg,Fp);





