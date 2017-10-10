function [x_position,y_position,z_position,t] = sigmoidShit(pt_A, pt_B, V_max, A_max, leg, time_step, V_tol, height_factor)

% This take two points in 3D space, a max velocity, a max acceleration, and
% a minimum velocity, and generates a sigmoid path along the line
% connecting the two points. It then turns it into X, Y, and Z profiles,
%  profiles for cables, and discretizes each cable path into steps.

%% Initial Values of Parameters and Time
a = (4*V_max)/leg; % steepness (limited by V_max initially)
c = 0; % location of mid-path (inflection point)
t = 0:time_step:100;

sig_num = -leg./(1 + exp(-a.*(c-t))) + leg;
d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
dd_sig_num = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;

%% Revised Parameters Accomodating A_max
while abs(min(dd_sig_num)) > A_max % iteratively reduce a if acceleration exceeds abs(A_max)
    a = a - 0.01;
    sig_num = -leg./(1 + exp(-a.*(c-t))) + leg;
    d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
    dd_sig_num = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
end

%% Shifting and Cropping Time Period
d_sig_tol = d_sig_num - V_tol;
end_index = find(d_sig_tol<=0, 1, 'first');
c = t(end_index);
t = 0:time_step:2*t(end_index);

sig_num = -leg./(1 + exp(-a.*(c-t))) + leg;
d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
dd_sig_num = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;

%% Find X & Y Components
x_component = pt_B(1) - pt_A(1);
y_component = pt_B(2) - pt_A(2);
z_component = pt_B(3) - pt_A(3);

x_position = pt_A(1) + (x_component/leg).*sig_num;

y_position = pt_A(2) + (y_component/leg).*sig_num;

z_position = pt_A(3) + (z_component/leg).*sig_num;

%% Ideal Cable Lengths
w = 1000; % width (X-dimension) of working area (mm)
l = 1000; % length (Y-dimension) of working area (mm)
h = 1000*height_factor; % height (Z-dimension) of working area (mm)
%f = 0.05; % half-width (X-dimension) of effector (m)
f = 62.5; % mm
%e = 0.05; % half-length (Y-dimension) of effector (m)
e = 62.5; %mm
g = 25; %mm


A_length = sqrt((x_position-f).^2 + (y_position-e).^2 + (h-z_position-g).^2); % Pythagorean calculation for ideal cable length
B_length = sqrt((x_position-f).^2 + (l-y_position-e).^2) + (h-z_position-g).^2;
C_length = sqrt((w-x_position-f).^2 + (l-y_position-e).^2) + (h-z_position-g).^2;
D_length = sqrt((w-x_position-f).^2 + (y_position-e).^2) + (h-z_position-g).^2;

%% Winch Calculations

spr = 200; % steps per revolution
drive_ratio = 1; % gear reduction on stepper (input:output)
spool_radius = 20; % spool radius (mm)
step_length = (pi*2*spool_radius)/(spr*drive_ratio); % arc length swept by each step (i.e. cable length change)

%% Round to Nearest Step

A_stepped = ceil((A_length - A_length(1))./step_length).*step_length + A_length(1);
B_stepped = ceil((B_length - B_length(1))./step_length).*step_length + B_length(1);
C_stepped = ceil((C_length - C_length(1))./step_length).*step_length + C_length(1);
D_stepped = ceil((D_length - D_length(1))./step_length).*step_length + D_length(1);
toc

%% Plot Stepped Cable Lengths

figure(5)

subplot(2,2,3)
plot(t, A_stepped)
hold on
plot(t,x_position,'r')
title('Stepped A-Cable Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(2,2,1)
plot(t, B_stepped)
title('Stepped B-Cable Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(2,2,2)
plot(t, C_stepped)
title('Stepped C-Cable Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(2,2,4)
plot(t, D_stepped)
title('Stepped D-Cable Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

%% Create Array for Stepper Drivers

step_array = zeros(4,length(A_stepped));

for i = 2:length(step_array)
    if A_stepped(i) > A_stepped(i-1)
       step_array(1,i) = 1; 
    end
    if A_stepped(i) < A_stepped(i-1)
       step_array(1,i) = -1; 
    end
    
    if B_stepped(i) > B_stepped(i-1)
       step_array(2,i) = 1; 
    end
    if B_stepped(i) < B_stepped(i-1)
       step_array(2,i) = -1; 
    end
    
    if C_stepped(i) > C_stepped(i-1)
       step_array(3,i) = 1; 
    end
    if C_stepped(i) < C_stepped(i-1)
       step_array(3,i) = -1; 
    end
    
    if D_stepped(i) > D_stepped(i-1)
       step_array(4,i) = 1; 
    end
    if D_stepped(i) < D_stepped(i-1)
       step_array(4,i) = -1; 
    end
end