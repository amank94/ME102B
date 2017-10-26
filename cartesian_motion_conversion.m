function [cartesian_position, cartesian_accel] = cartesian_motion_conversion(path_motion, path_accel, pt_A, pt_B, leg)

x_component = pt_B(1) - pt_A(1);
y_component = pt_B(2) - pt_A(2);
z_component = pt_B(3) - pt_A(3);

cartesian_position(1,:) = pt_A(1) + (x_component/leg).*path_motion;
cartesian_position(2,:) = pt_A(2) + (y_component/leg).*path_motion;
cartesian_position(3,:) = pt_A(3) + (z_component/leg).*path_motion;

cartesian_accel(1,:) = (x_component/leg).*path_accel;
cartesian_accel(2,:) = (y_component/leg).*path_accel;
cartesian_accel(3,:) = (z_component/leg).*path_accel;

end