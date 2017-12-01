def initialize_effector():
	import RPi.GPIO as GPIO
	c_axis = GPIO.PWM(8, 100) # pin 8, 100Hz
	c_axis.start(15) #1.5 ms (center servo)