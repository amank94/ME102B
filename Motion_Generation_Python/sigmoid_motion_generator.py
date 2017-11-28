def sigmoid_motion_generator(leg, V_max, A_max, V_tol, time_step):
    
    import numpy as np
    
    ## Initial Values of Parameters and Time
    a = (4*V_max)/leg; # steepness (limited by V_max initially)
    c = 0; # location of mid-path (inflection point)
    t = np.arange(0,10,time_step);

    #sig_num = -leg/(1+np.exp(-a*(c-t))) + leg;
    #d_sig_num = (leg*a**2*np.exp(-a*(c-t)))/(np.exp(-a*(c-t))+1)**2;
    dd_sig_num = np.array(-(2*leg*a**2*np.exp(-2*2*(c-t)))/(np.exp(-a*(c-t))+1)**3 + (leg*a**2*np.exp(-a*(c-t)))/(np.exp(-a*(c-t))+1)**2);

    ## Revised Parameters Accomodating A_max
    while (abs(max(dd_sig_num)) > A_max):
        a = a - 0.1;
        dd_sig_num = -(2*leg*a**2*np.exp(-2*2*(c-t)))/(np.exp(-a*(c-t))+1)**3 + (leg*a**2*np.exp(-a*(c-t)))/(np.exp(-a*(c-t))+1)**2;

    ## Shifting and Cropping Time Period
    d_sig_num = np.array((leg*a**2*np.exp(-a*(c-t)))/(np.exp(-a*(c-t))+1)**2);
    d_sig_tol = d_sig_num - V_tol;
    end_index = [end_index for end_index,value in enumerate(d_sig_tol) if value <= 0][0]
    c = t[end_index];
    t = np.arange(0, 2*t[end_index], time_step);

    path_position = np.array(-leg/(1+np.exp(-a*(c-t))) + leg);
    print('path position',path_position)

    #path_accel = np.array(-(2*leg*a**2.*np.exp(-2*a*(c - t)))/(np.exp(-a*(c - t)) + 1)**3 + (leg*a**2.*np.exp(-a*(c - t)))/(np.exp(-a*(c - t)) + 1)**2);

    return path_position


