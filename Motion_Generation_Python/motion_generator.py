import numpy as np
from distance_3d import distance_3d
from sigmoid_motion_generator import sigmoid_motion_generator
from cartesian_motion_conversion import cartesian_motion_conversion
from ideal_cable_length import ideal_cable_length
from stepped_cable_lengths import stepped_cable_lengths
from command_generator import command_generator
from execute_command import execute_command

pt_A = np.array([0.1, 0.1, 0.1]);
pt_B = np.array([0.9, 0.1, 0.1]);
V_max = 1;

leg=distance_3d(pt_A, pt_B)
#def motion_generator(pt_A, pt_B, V_max):
#    distance_3d(pt_A, pt_B);
#    return leg
#print(leg)
A_max = 4; # max allowable effector acceleration (mm/s^2)
V_tol = 0.1; # velocity tolerance (mm/s) for start and end of motion with sigmoid
time_step = 0.0001; # interval between points, i.e. resolution of model
path_position = sigmoid_motion_generator(leg, V_max, A_max, V_tol, time_step)

cartesian_position = cartesian_motion_conversion(path_position, pt_A, pt_B, leg)

w = 0.800; # width (X-dimension) of working area (mm)
l = 0.800; # length (Y-dimension) of working area (mm)
ht = 0.800; # height (Z-dimension) of top winches (mm)
hb = 0.450; # height (Z-dimension of bottom winches (mm)
e = 0.050; # half-length (Y-dimension) of effector (mm)
f = 0.050; # half-width (X-dimension) of effector (mm)
g = 0.050; # half-height (Z-dimension) of effector (mm)
ideal_cables = ideal_cable_length(w, l, ht, hb, e, f, g, cartesian_position)

spr = 200; # steps per revolution
drive_ratio = 1; # gear reduction on stepper (input:output)
spool_radius = 0.020; # spool radius (mm)
step_length = (np.pi*2*spool_radius)/(spr*drive_ratio); # arc length swept by each step (i.e. cable length change)

stepped_cables = stepped_cable_lengths(ideal_cables, step_length);
command_array = command_generator(stepped_cables);

print(command_array)
#input("Press Enter to continue...")

execute_command(command_array)