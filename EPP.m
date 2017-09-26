function [leg] = EPP(pt_A, pt_B)

% unpackage point arrays to invidual X and Y coords
x_A = pt_A(1);
y_A = pt_A(2);
x_B = pt_B(1);
y_B = pt_B(2);

% calculate deltas
x_del = x_B - x_A;
y_del = y_A - y_B;

% calculate path length (the "leg" of the triangle)
leg = sqrt(x_del^2 + y_del^2);

