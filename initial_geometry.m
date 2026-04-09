D = 1;
r = 0.2;
start_angle = 10;

P = D-r;
step = 0.01;
dalpha = (pi/180)*(0:50);
x = 1:length(dalpha);

for f = 1:length(dalpha)
    x(f) = sqrt(P^2 + 4*D*r*sin((dalpha(f)+(start_angle*pi/180))/2)^2) - P;
end

disp = x+P;
angle = (180/pi)*dalpha+start_angle;

plot(disp, angle, "b - o");
