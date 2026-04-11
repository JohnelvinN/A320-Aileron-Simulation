clear;
clc;
close all;

%!!!!!!!!!!!!!!!!! For all this to work smothly I must change the range of
%the theta_deg in the inital geometry.
%Initial data

c=0.4;   % Chord length
v=233; % To be changed based on the values of speed used in Xfoil
S=1.2;
rho=1.225;
b=2.4;


%geometry for the aileron saved data.mat in the geometry code

load("data.mat");

%addition of the Aerodynamic coefficients, (to be changed based on the
%format)
delta_data=[15; 10; 5; 0; -5; -10; -15];
Cl=[1.1221; 0.7740; 0.3204; 0; -0.3362; -1.0186; -1.5390];
Cm=[-0.1664; -0.1224; -0.0531; 0; 0.0565; 0.1719; 0.2491];

%preallocating space for top and bottom variables
top=zeros(size(Cm));
bottom=zeros(size(Cm));

%Now the numerator of the fp function

for i=1:length(delta_data)

top(i)= rho*v^2*S*((b*Cm(i))+(0.25*c*Cl(i)));
bottom(i)= 2*r*sqrt(1-(P(i)/(D*sin(B(i)))));

end

Fp=top./bottom;

%To plot the graphs

plot    (theta_deg,Fp,'b-','LineWidth',2);
xlabel('Theta (degrees)');
ylabel('Fp ');
title('Actuator force vs deflection');
grid on;






