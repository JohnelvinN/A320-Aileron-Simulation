clear;
clc;
close all;

%!!!!!!!!!!!!!!!!! For all this to work smothly I must change the range of
%the theta_deg in the inital geometry.
%Initial data

c=0.4;   % Chord length
%v=250; % To be changed based on the values of speed used in Xfoil
S=1.2;
rho=0.38;
b=2.4;


%geometry for the aileron saved data.mat in the geometry code

load("data.mat");

load("Aero_data.mat");

R=r;



% To extrapolate Cl and Cm values since they dont match the values from the
% initail geometry with 101 values in array

% First we preallocate variable size for the values that come out of
% interpolation

Cl=zeros(length(theta_deg),length(V));
Cm=zeros(length(theta_deg),length(V));

for k=1:length(V)

    Cl_at_one_speed=Cl_a(:,k);
    Cm_at_one_speed=Cm_a(:,k);

    %Now the interpolation

Cl(:,k)=interp1(delta,Cl_at_one_speed,theta_deg,"pchip","extrap");
Cm(:,k)=interp1(delta,Cm_at_one_speed,theta_deg,"pchip","extrap");

end


%preallocating space for top and bottom variables
top=zeros(size(Cm));
bottom=zeros(size(Cm));

Fp_all=zeros(length(theta_deg),length(V));

%Now the numerator of the fp function

for k=1:length(V)

for i=1:length(theta_deg)

top= rho*V(k)^2*S*((c*Cm(:,k))+(0.25*c*Cl(:,k)));
bottom= 2*r*sqrt(1-((R^2+P(i)^2-D^2)/(2*R*P(i)))^2);

Fp_all(:,k) =top./bottom;

end

end


mesh(Fp_all);
%To plot the graphs






