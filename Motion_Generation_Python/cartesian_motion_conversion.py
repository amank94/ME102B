def cartesian_motion_conversion(path_position, pt_A, pt_B, leg):
    
    import numpy as np
    
    x_component = pt_B[0] - pt_A[0];
    y_component = pt_B[1] - pt_A[1];
    z_component = pt_B[2] - pt_A[2];
    cartesian_position = np.zeros((3, len(path_position)));
 
    cartesian_position[0,:] = pt_A[0] + (x_component**2/leg**2)*path_position;
    cartesian_position[1,:] = pt_A[1] + (y_component**2/leg**2)*path_position;
    cartesian_position[2,:] = pt_A[2] + (z_component**2/leg**2)*path_position;
    print('cartesian position',cartesian_position)

    return cartesian_position