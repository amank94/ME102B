import setup_sequence as setup_sequence
import numpy as np
#import RPi.GPIO as GPIO
import time

step_pins = np.array([2,3,15,17,22,24,5,13])
dir_pins = np.array([3,14,18,27,23,25,6,19])
names = ('T1', 'T2', 'T3', 'T4', 'B1', 'B2', 'B3', 'B4')

for i in range(8):
	print('moving', names[i])
	for j in range(10):
		print('stepping forward')
		#GPIO.output(dir_pins[i], 1)
		#GPIO.output(step_pins[i], 1)
		#GPIO.output(step_pins[i],0)
		time.sleep(0.5)
	for j in range(10):
		print('stepping backward')
		#GPIO.output(dir_pins[i], 0)
		#GPIO.output(step_pins[i], 1)
		#GPIO.output(step_pins[i],0)
		time.sleep(0.5)