clear variables
close all
clc

%------------- INPUT PARAMETERS (USER INPUTS HERE) ---------------%

a = 1; % Radius of inner surface (m)

b = 1.5; % Radius of outer surface (m)

P = 1000000; % Applied loading (N)

Elastic_mod = 210000000000; % Elastic modulus (Pa)

Rigidity_mod = 79000000000; % Modlulus of rigidity (Pa)

v = 0.3; % Poisson's ratio (dimensionless)

S_y = 250000000; % Yield strength (Pa)

m = 100; % Defines the number of iterations, increment, etc.


%------------- DEFINING BASIC VARIABLES ---------------%

r = linspace(a,b,m); % Radius of any given point

theta = linspace(0,0.5*pi,m); % Angle (from horizontal) of any given point


%------------- DEFINING AND COMPUTING CONSTANTS USED IN STRESS DISTRIBUTIONS ---------------%

N = (a^2 - b^2) + (a^2 + b^2)*log(b/a);

A = P/(2*N);

B = -(P*a^2*b^2)/(2*N);

C = -(P*(a^2+b^2))/N;

D = 0;

%------------- VARIABLE PRE-ALLOCATION (PROGRAM PERFORMANCE ONLY) ---------------%

sigma_rr = zeros(m,m);

tau_rt = zeros(m,m);

sigma_tt = zeros(m,m);

x = zeros(m,m);

y = zeros (m,m);

sigma_x = zeros(m,m);

sigma_y = zeros(m,m);

tau_xy = zeros(m,m);

sigma_vm = zeros(m,m);

e_x = zeros(m,m);

e_y = zeros(m,m);

gamma_xy = zeros(m,m);

%------------- FOR-LOOP FOR DATA COMPUTATION AT ALL POINTS ---------------%

for i = 1:m
    
    for j = 1:m
        
        % Define the cartesian coordinates in terms of polar coordinates
        
        x(i,j) = r(i)*cos(theta(j));
        
        y(i,j) = r(i)*sin(theta(j));
        
        % Computation of the radial noraml stress distribution
        
        sigma_rr(i,j) = (2*A*r(i)-2*B*r(i)^(-3)+C*r(i)^(-1)-2*D*r(i)^(-1))*cos(theta(j));
        
        % Computation of the circumferential normal stress distribution
        
        sigma_tt(i,j) = (-2*A*r(i)+2*B*r(i)^(-3)-C*r(i)^(-1))*sin(theta(j));
    
        % Computation of the tangental (shear) stress distribution
        
        tau_rt(i,j) = (6*A*r(i)+2*B*r(i)^(-3)+C*r(i)^(-1))*cos(theta(j));
        
        % Converting the polar stresses to cartesian representation

        sigma_x(i,j) = sigma_rr(i,j)*(cos(theta(j)))^2+sigma_tt(i,j)*(sin(theta(j)))^2-2*tau_rt(i,j)*sin(theta(j))*cos(theta(j));
        
        sigma_y(i,j) = sigma_rr(i,j)*(sin(theta(j)))^2+sigma_tt(i,j)*(cos(theta(j)))^2+2*tau_rt(i,j)*sin(theta(j))*cos(theta(j));
        
        tau_xy(i,j) = (sigma_rr(i,j)-sigma_tt(i,j))*sin(theta(j))*cos(theta(j))+tau_rt(i,j)*((cos(theta(j)))^2-(sin(theta(j)))^2);
        
        % Computation of the Von Mises stress distribution

        sigma_vm(i,j) = sqrt((sigma_x(i,j))^2+(sigma_y(i,j))^2-(sigma_x(i,j))*(sigma_y(i,j))+3*(tau_xy(i,j))^2);
        
        % Strain computation (for the assumption of plane stress)
        
        e_x(i,j) = (1/Elastic_mod)*(sigma_x(i,j)-v*(sigma_y(i,j)));
        
        e_y(i,j) = (1/Elastic_mod)*(sigma_y(i,j)-v*(sigma_x(i,j)));
        
        gamma_xy(i,j) = tau_xy(i,j)/Rigidity_mod;
        
    end
   
    
end

%------------- COMPUTATION OF MAXIMUM STRESS VALUES ---------------%

sigma_x_max = max(sigma_x, [], 'all');

sigma_y_max = max(sigma_y, [], 'all');

sigma_vm_max = max(sigma_vm, [], 'all');

%------------- SAFETY FACTOR ANALYSIS (DISTORTION ENERGY) ---------------%

safety_factor = S_y/sigma_vm_max;

fprintf(' Applied loading: %f kN \n Maximum equivilent stress: %f MPa \n Saftey factor: %f',P/1000 ,sigma_vm_max/1000000, safety_factor);

%------------- RADIAL NORMAL STRESS PLOTTING ---------------%
figure;
contour(x,y,sigma_x,m);
hold on
cylinder(a,m)
cylinder(b,m)
hold off
axis equal
xlim([0,b+0.5])
ylim([0,b+0.5])
grid on
colorbar
title 'Horizontal Normal Stress Contour Plot'

figure;
surf(x,y,sigma_x)
colorbar
title 'Horizontal Normal Stress Surface'

%------------- CIRCUMFERENTIAL NORMAL STRESS PLOTTING ---------------%
figure;
contour(x,y,sigma_y,m);
hold on
cylinder(a,m)
cylinder(b,m)
hold off
axis equal
xlim([0,b+0.5])
ylim([0,b+0.5])
grid on
colorbar
title 'Vertical Normal Stress Contour Plot'

figure;
surf(x,y,sigma_y)
colorbar
title 'Vertical Normal Stress Surface'

%------------- TANGENTIAL SHEAR STRESS PLOTTING ---------------%
        
figure;
contour(x,y,tau_xy,m);
hold on
cylinder(a,m)
cylinder(b,m)
hold off
axis equal
xlim([0,b+0.5])
ylim([0,b+0.5])
grid on
colorbar
title 'Shear Stress Contour Plot'

figure;
surf(x,y,tau_xy)
colorbar
title 'Tangential Shear Stress Surface'

%------------- VON MISES STRESS DISTRIBUTION PLOTTING ---------------%
        
figure;
contour(x,y,sigma_vm,m);
hold on
cylinder(a,m)
cylinder(b,m)
hold off
axis equal
xlim([0,b+0.5])
ylim([0,b+0.5])
grid on
colorbar
title 'Von Mises Equivilent Stress Contour Plot'

figure;
surf(x,y,sigma_vm)
colorbar
title 'Von Mises Equivilent Stress Surface'

%------------- HORIZONTAL STRAIN DISTRIBUTION ---------------%
        
figure;
contour(x,y,e_x,m);
hold on
cylinder(a,m)
cylinder(b,m)
hold off
axis equal
xlim([0,b+0.5])
ylim([0,b+0.5])
grid on
colorbar
set(gca, 'clim', [-0.0001 0.00025])
title 'Horizontal Strain Distribution Contour Plot'

figure;
surf(x,y,e_x)
colorbar
title 'Horizontal Strain Distribution Surface'

%------------- VERTICAL STRAIN DISTRIBUTION ---------------%

figure;
contour(x,y,e_y,m);
hold on
cylinder(a,m)
cylinder(b,m)
hold off
axis equal
xlim([0,b+0.5])
ylim([0,b+0.5])
grid on
colorbar
set(gca, 'clim', [-0.00015 0.0002])
title 'Vertical Strain Distribution Contour Plot'

figure;
surf(x,y,e_y)
colorbar
title 'Vertical Strain Distribution Surface'

%------------- SHEAR STRAIN DISTRIBUTION ---------------%

figure;
contour(x,y,gamma_xy,m);
hold on
cylinder(a,m)
cylinder(b,m)
hold off
axis equal
xlim([0,b+0.5])
ylim([0,b+0.5])
grid on
colorbar
set(gca, 'clim', [-0.0002 0.0003])
title 'Shear Strain Distribution Contour Plot'

figure;
surf(x,y,gamma_xy)
colorbar
title 'Shear Strain Distribution Surface'