import numpy as np
from distance_3d import distance_3d
from sigmoid_motion_generator import sigmoid_motion_generator
from cartesian_motion_conversion import cartesian_motion_conversion
from ideal_cable_length import ideal_cable_length
from stepped_cable_lengths import stepped_cable_lengths
from command_generator import command_generator
from execute_command import execute_command
from setup_sequence import setup_sequence

pt_A = np.array([200, 200, 200]);
pt_B = np.array([0, 0, 0]);
V_max = 100;

leg=distance_3d(pt_A, pt_B)
#def motion_generator(pt_A, pt_B, V_max):
#    distance_3d(pt_A, pt_B);
#    return leg
#print(leg)
A_max = 400; # max allowable effector acceleration (mm/s^2)
V_tol = 100; # velocity tolerance (mm/s) for start and end of motion with sigmoid
time_step = 0.01; # interval between points, i.e. resolution of model
path_position = sigmoid_motion_generator(leg, V_max, A_max, V_tol, time_step)

cartesian_position = cartesian_motion_conversion(path_position, pt_A, pt_B, leg)

w = 800; # width (X-dimension) of working area (mm)
l = 800; # length (Y-dimension) of working area (mm)
ht = 780; # height (Z-dimension) of top winches (mm)
hb = 450; # height (Z-dimension of bottom winches (mm)
e = 54; # half-length (Y-dimension) of effector (mm)
f = 54; # half-width (X-dimension) of effector (mm)
g = 50; # half-height (Z-dimension) of effector (mm)
spool_ratio=0.0269;

real_cable_delta = ideal_cable_length(w, l, ht, hb, e, f, g, spool_ratio, cartesian_position)

spr = 200; # steps per revolution
drive_ratio = 1; # gear reduction on stepper (input:output)
spool_radius = 20; # spool radius (mm)
step_length = (np.pi*2*spool_radius)/(spr*drive_ratio); # arc length swept by each step (i.e. cable length change)

stepped_cables = stepped_cable_lengths(real_cable_delta, step_length);
command_array = command_generator(stepped_cables);

setup_sequence()

raw_input("Press Enter to continue...")

execute_command(command_array)