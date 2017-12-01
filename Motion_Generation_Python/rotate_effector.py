def rotate_effector(c):
	import RPi.GPIO as GPIO
	c_axis = GPIO.PWM(8, 100) # pin 8, 100Hz
        dc = 10 + (((float(c))/180)*10)
        c_axis.start(dc)
        print('c', c)
        print('duty cycle', dc)
            
            
	
	