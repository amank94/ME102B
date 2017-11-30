def ideal_cable_length(w,l,ht,hb,e,f,g,spool_ratio,cartesian_position):
    import numpy as np
    x_position = cartesian_position[0,:];
    y_position = cartesian_position[1,:];
    z_position = cartesian_position[2,:];

    winch_a=40.9+2.2
    winch_b=44.6
    wao=200

    gt=98
    gb=53

    # offset=np.array(())
    # stepper_position=np.array(
    #     (x_position+wao-winch_a,y_position+wao-winch_b),
    #     (l-x_position-winch_b,y+wao-winch_a)
    #     (l-x_position-winch_a,w-wao-y_position-winch_b)
    #     (x+wao-b, l-wao-y_position-winch_a)

    #     )
    
    T1_cable_ideal = np.array(((x_position+wao-winch_a-f)**2 + (y_position+wao-winch_b-e)**2 + (ht-z_position-gt)**2)**(0.5));
    T2_cable_ideal = np.array(((w-x_position-winch_b-f-wao)**2 + (y_position+wao-winch_a-e)**2 + (ht-z_position-gt)**2)**(0.5));
    T3_cable_ideal = np.array(((w-x_position-winch_a-f-wao)**2 + (l-wao-y_position-winch_b-e)**2 + (ht-z_position-gt)**2)**(0.5));
    T4_cable_ideal = np.array(((x_position+wao-winch_b-f)**2 + (l-wao-y_position-winch_a-e)**2 + (ht-z_position-gt)**2)**(0.5));
    
    B1_cable_ideal = np.array(((x_position+wao-winch_a-f)**2 + (y_position+wao-winch_b-e)**2 + (hb-z_position-gb)**2)**(0.5));
    B2_cable_ideal = np.array(((w-x_position-winch_b-f-wao)**2 + (y_position+wao-winch_a-e)**2 + (hb-z_position-gb)**2)**(0.5));
    B3_cable_ideal = np.array(((w-x_position-winch_a-f-wao)**2 + (l-wao-y_position-winch_b-e)**2 + (hb-z_position-gb)**2)**(0.5));
    B4_cable_ideal = np.array(((x_position+wao-winch_b-f)**2 + (l-wao-y_position-winch_a-e)**2 + (hb-z_position-gb)**2)**(0.5));

    ideal_cable_delta = np.array([(T1_cable_ideal-T1_cable_ideal[0]),
                             (T2_cable_ideal-T2_cable_ideal[0]),
                             (T3_cable_ideal-T3_cable_ideal[0]),
                             (T4_cable_ideal-T4_cable_ideal[0]),
                             (B1_cable_ideal-B1_cable_ideal[0]),
                             (B2_cable_ideal-B2_cable_ideal[0]),
                             (B3_cable_ideal-B3_cable_ideal[0]),
                             (B4_cable_ideal-B4_cable_ideal[0])]);
    
    #print("ideal cable delta",ideal_cable_delta)
    real_cable_delta=ideal_cable_delta+(ideal_cable_delta*spool_ratio)

    print("T2 ideal cable",T2_cable_ideal*0.0393701)
    print("real cable delta",real_cable_delta)


    return real_cable_delta
