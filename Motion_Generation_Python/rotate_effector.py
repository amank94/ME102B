def rotate_effector(c):
	import RPi.GPIO as GPIO
	c_axis = GPIO.PWM(8, 100) # pin 8, 100Hz
	