def stepped_cable_lengths(ideal_cable_length, step_length):
    
    import numpy as np

    stepped_cables = np.zeros([8, len(ideal_cable_length[0])]);

    
    for i in range (8):
        #stepped_cables[i,:] = np.ceil((ideal_cable_length[i,:] - ideal_cable_length[i,0])/step_length)*step_length + ideal_cable_length[i,0];
        stepped_cables[i,:] = np.ceil((ideal_cable_length[i,:])/step_length)*step_length
    
    print('stepped cable lengths', stepped_cables)
    print('stepped cable length array shape', stepped_cables.shape)
    return stepped_cables