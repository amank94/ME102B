function [leg] = distance_3d(pt_A, pt_B)

% calculate deltas
x_del = pt_B(1) - pt_A(1);
y_del = pt_B(2) - pt_A(2);
z_del = pt_B(3) - pt_A(3);

% calculate path length (the "leg" of the triangle)
leg = sqrt(x_del^2 + y_del^2 + z_del^2);

