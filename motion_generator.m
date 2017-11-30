
%%
pt_A = [0.1, 0.8, 0.2]; % x & y coordinates of starting point
pt_B = [0.9, 0.2, 0.8]; % x & y coordinates of ending point
leg = distance_3d(pt_A, pt_B);
%%
V_max = 1; % max allowable effector velocity (m/s)
A_max = 4; % max allowable effector acceleration (m/s^2)
V_tol = 0.01; % velocity tolerance (m/s) for start and end of motion with sigmoid
time_step = 0.0001; % interval between points, i.e. resolution of model
[path_motion, path_accel, t] = sigmoid_motion_generator(leg, V_max, A_max, V_tol, time_step);
%%
[cartesian_position, cartesian_accel] = cartesian_motion_conversion(path_motion, path_accel, pt_A, pt_B, leg);
%%
w = 1; % width (X-dimension) of working area (m)
l = 1; % length (Y-dimension) of working area (m)
ht = 1; % height (Z-dimension) of top winches (m)
hb = 0.5; % height (Z-dimension of bottom winches (m)
e = 0.05; % half-length (Y-dimension) of effector (m)
f = 0.05; % half-width (X-dimension) of effector (m)
g = 0.05; % half-height (Z-dimension) of effector (m)
[ideal_cables] = ideal_cable_length(w, l, ht, hb, e, f, g, cartesian_position);
%%
spr = 200; % steps per revolution
drive_ratio = 1; % gear reduction on stepper (input:output)
spool_radius = 0.02; % spool radius (m)
step_length = (pi*2*spool_radius)/(spr*drive_ratio); % arc length swept by each step (i.e. cable length change)
%%
stepped_cables = stepped_cable_lengths(ideal_cables, step_length);
%%

clf
figure(1)

subplot(5,3,1)
plot(t, stepped_cables(4,:))
title('Stepped T4 Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(5,3,4)
plot(t, stepped_cables(8,:))
title('Stepped B4 Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(5,3,3)
plot(t, stepped_cables(3,:))
title('Stepped T3 Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(5,3,6)
plot(t, stepped_cables(7,:))
title('Stepped B3 Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(5,3,12)
plot(t, stepped_cables(2,:))
title('Stepped T2 Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(5,3,15)
plot(t, stepped_cables(6,:))
title('Stepped B2 Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(5,3,10)
plot(t, stepped_cables(1,:))
title('Stepped T1 Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])

subplot(5,3,13)
plot(t, stepped_cables(5,:))
title('Stepped B1 Length vs time');
xlabel('time (s)');
ylabel('length (m)');
xlim([0,t(end)])
