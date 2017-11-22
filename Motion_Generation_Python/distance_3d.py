def distance_3d(pt_A, pt_B):
    x_del = pt_B[0] - pt_A[0];
    y_del = pt_B[1] - pt_A[1];
    z_del = pt_B[2] - pt_A[2];

def leg():
    leg = (x_del**2 + y_del**2 + z_del**2)**(1/2);
    return(leg)
