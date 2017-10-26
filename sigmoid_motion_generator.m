function [path_motion, path_accel, t] = sigmoid_motion_generator(leg, V_max, A_max, V_tol, time_step)
%% Initial Values of Parameters and Time
a = (4*V_max)/leg; % steepness (limited by V_max initially)
c = 0; % location of mid-path (inflection point)
t = 0:time_step:10;

%sig_num = -leg./(1 + exp(-a.*(c-t))) + leg;
%d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
dd_sig_num = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
%ddd_sig_num = -(6.*a.^3.*leg.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ... 
%   + (a.^3.*leg.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2 ...
%   + (6.*a.^3.*leg.*exp(-3.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^4;

%% Revised Parameters Accomodating A_max
while abs(min(dd_sig_num)) > A_max % iteratively reduce a if acceleration exceeds abs(A_max)
    a = a - 0.1;
%    sig_num = -leg./(1 + exp(-a.*(c-t))) + leg;
%    d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
    dd_sig_num = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
%    ddd_sig_num = -(6.*a.^3.*leg.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ... 
%   + (a.^3.*leg.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2 ...
%   + (6.*a.^3.*leg.*exp(-3.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^4;
end

%% Shifting and Cropping Time Period
d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
d_sig_tol = d_sig_num - V_tol;
end_index = find(d_sig_tol<=0, 1, 'first');
c = t(end_index);
t = 0:time_step:2*t(end_index);

path_motion = -leg./(1 + exp(-a.*(c-t))) + leg;
%d_sig_num = (leg.*a.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
path_accel = -(2.*leg.*a.^2.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ...
   + (leg.*a.^2.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2;
%ddd_sig_num = -(6.*a.^3.*leg.*exp(-2.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^3 ... 
%   + (a.^3.*leg.*exp(-a.*(c - t)))./(exp(-a.*(c - t)) + 1).^2 ...
%   + (6.*a.^3.*leg.*exp(-3.*a.*(c - t)))./(exp(-a.*(c - t)) + 1).^4;
end