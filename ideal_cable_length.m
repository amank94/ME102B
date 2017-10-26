function [ideal_cables] = ideal_cable_length(w, l, ht, hb, e, f, g, cartesian_position)

x_position = cartesian_position(1,:);
y_position = cartesian_position(2,:);
z_position = cartesian_position(3,:);

T1_cable_ideal = sqrt((x_position-f).^2 + (y_position-e).^2 + (ht-z_position-g).^2); % Pythagorean calculation for ideal cable length
T2_cable_ideal = sqrt((x_position-f).^2 + (l-y_position-e).^2 + (ht-z_position-g).^2);
T3_cable_ideal = sqrt((w-x_position-f).^2 + (l-y_position-e).^2 + (ht-z_position-g).^2);
T4_cable_ideal = sqrt((w-x_position-f).^2 + (y_position-e).^2) + (ht-z_position-g).^2;

B1_cable_ideal = sqrt((x_position-f).^2 + (y_position-e).^2 + (hb-z_position+g).^2);
B2_cable_ideal = sqrt((x_position-f).^2 + (l-y_position-e).^2 + (hb-z_position+g).^2);
B3_cable_ideal = sqrt((w-x_position-f).^2 + (l-y_position-e).^2 + (hb-z_position+g).^2);
B4_cable_ideal = sqrt((w-x_position-f).^2 + (y_position-e).^2) + (hb-z_position+g).^2;

ideal_cables = [T1_cable_ideal;
                T2_cable_ideal;
                T3_cable_ideal;
                T4_cable_ideal;
                B1_cable_ideal;
                B2_cable_ideal;
                B3_cable_ideal;
                B4_cable_ideal];

end