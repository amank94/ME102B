
from setup_sequence import setup_sequence
from rotate_effector import rotate_effector
import time
setup_sequence()
import RPi.GPIO as GPIO
c_axis = GPIO.PWM(8, 100) # pin 8, 100Hz
c_axis.start(20)
#while(True):
#    time.sleep(2)
#    rotate_effector(0)
#    print('forward')
#    time.sleep(2)
#    rotate_effector(120)
#    print('backward')