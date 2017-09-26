% This take two points in 2D space, a max velocity, a max acceleration, and
% a minimum velocity, and generates a sigmoid path along the line
% connecting the two points. It then turns it into X and Y profiles,
%  profiles for cables, and discretizes each cable path into steps.

%% Length Determination and Inputs
tic
pt_A = [0.05,.5];
pt_B = [.1,.1];
leg = EPP(pt_A, pt_B); % POINTS GO HERE
V_max = 1; % max allowable effector velocity (m/s)
A_max = 4; % max allowable effector acceleration (m/s^2)
V_tol = 0.01; % velocity tolerance (m/s) for start and end of motion with sigmoid

%% Initial Values of Parameters and Time
a = (4*V_max)/leg; % steepness (limited by V_max initially)
c = 0; % location of mid-path (inflection point)
t = 0:0.001:10;

sig_num = -leg./(1 + exp(-a.*(c-t))) + leg;
d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
dd_sig_num = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
%ddd_sig_num = -(6.*a.^3.*leg.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ... 
%   + (a.^3.*leg.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2 ...
%   + (6.*a.^3.*leg.*exp(-3.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^4;

%% Revised Parameters Accomodating A_max
while abs(min(dd_sig_num)) > A_max % iteratively reduce a if acceleration exceeds abs(A_max)
    a = a - 0.01;
    sig_num = -leg./(1 + exp(-a.*(c-t))) + leg;
    d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
    dd_sig_num = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
%    ddd_sig_num = -(6.*a.^3.*leg.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ... 
%   + (a.^3.*leg.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2 ...
%   + (6.*a.^3.*leg.*exp(-3.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^4;
end

%% Shifting and Cropping Time Period
d_sig_tol = d_sig_num - V_tol;
end_index = find(d_sig_tol<=0, 1, 'first');
c = t(end_index);
t = 0:0.001:2*t(end_index);

sig_num = -leg./(1 + exp(-a.*(c-t))) + leg;
d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
dd_sig_num = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
%ddd_sig_num = -(6.*a.^3.*leg.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ... 
%   + (a.^3.*leg.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2 ...
%   + (6.*a.^3.*leg.*exp(-3.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^4;

%% Plotting Along Path
%{
figure(1)

subplot(2,2,1)
plot(t, sig_num)
title('position along path vs time');
xlabel('time (s)');
ylabel('position (m)');
xlim([0,t(end)])

subplot(2,2,2)
plot(t, d_sig_num)
title('velocity along path vs time');
xlabel('time (s)');
ylabel('velocity (m/s)');
xlim([0,t(end)])

subplot(2,2,3)
plot(t, dd_sig_num)
title('acceleration along path vs time');
xlabel('time (s)');
ylabel('acceleration (m/s^2)');
xlim([0,t(end)])

subplot(2,2,4)
plot(t, ddd_sig_num)
title('jerk along path vs time');
xlabel('time (s)');
ylabel('jerk (m/s^3)');
xlim([0,t(end)])
%}
%% Find X & Y Components
x_component = pt_B(1) - pt_A(1);
y_component = pt_B(2) - pt_A(2);

x_position = pt_A(1) + (x_component/leg).*sig_num;
%x_velocity = (x_component/leg).*d_sig_num;
%x_accel = (x_component/leg).*dd_sig_num;
%x_jerk = (x_component/leg).*ddd_sig_num;

y_position = pt_A(2) + (y_component/leg).*sig_num;
%y_velocity = (y_component/leg).*d_sig_num;
%y_accel = (y_component/leg).*dd_sig_num;
%y_jerk = (y_component/leg).*ddd_sig_num;

%% Plotting X & Y Components
%{
figure(2)

subplot(2,2,1)
plot(t, x_position)
title('X position along path vs time');
xlabel('time (s)');
ylabel('position (m)');
xlim([0,t(end)])

subplot(2,2,2)
plot(t, x_velocity)
title('X velocity along path vs time');
xlabel('time (s)');
ylabel('velocity (m/s)');
xlim([0,t(end)])

subplot(2,2,3)
plot(t, x_accel)
title('X acceleration along path vs time');
xlabel('time (s)');
ylabel('acceleration (m/s^2)');
xlim([0,t(end)])

subplot(2,2,4)
plot(t, x_jerk)
title('X jerk along path vs time');
xlabel('time (s)');
ylabel('jerk (m/s^3)');
xlim([0,t(end)])

figure(3)

subplot(2,2,1)
plot(t, y_position)
title('Y position along path vs time');
xlabel('time (s)');
ylabel('position (m)');
xlim([0,t(end)])

subplot(2,2,2)
plot(t, y_velocity)
title('Y velocity along path vs time');
xlabel('time (s)');
ylabel('velocity (m/s)');
xlim([0,t(end)])

subplot(2,2,3)
plot(t, y_accel)
title('Y acceleration along path vs time');
xlabel('time (s)');
ylabel('acceleration (m/s^2)');
xlim([0,t(end)])

subplot(2,2,4)
plot(t, y_jerk)
title('Y jerk along path vs time');
xlabel('time (s)');
ylabel('jerk (m/s^3)');
xlim([0,t(end)])
%}

%% Ideal Cable Lengths
w = 1; % width (X-dimension) of working area (m)
l = 1; % length (Y-dimension) of working area (m)
f = 0.05; % half-width (X-dimension) of effector (m)
e = 0.05; % half-length (Y-dimension) of effector (m)

A_length = sqrt((x_position-f).^2 + (y_position-e).^2); % Pythagorean calculation for ideal cable length
B_length = sqrt((x_position-f).^2 + (l-y_position-e).^2);
C_length = sqrt((w-x_position-f).^2 + (l-y_position-e).^2);
D_length = sqrt((w-x_position-f).^2 + (y_position-e).^2);


%% Plotting Ideal Cable Lengths
%{
figure(4)

subplot(2,2,3)
plot(t, A_length)
title('A-Cable Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(2,2,1)
plot(t, B_length)
title('B-Cable Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(2,2,2)
plot(t, C_length)
title('C-Cable Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(2,2,4)
plot(t, D_length)
title('D-Cable Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])
%}

%% Winch Calculations

spr = 200; % steps per revolution
drive_ratio = 1; % gear reduction on stepper (input:output)
spool_radius = 0.02; % spool radius (m)
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