def setup_sequence():
	import RPi.GPIO as GPIO
	GPIO.setwarnings(False)
	GPIO.setmode(GPIO.BCM) # not sure if it should be BCM or BOARD
	output_pins = [2,3,4,14,15,18,17,27,22,23,24,25,8,7,5,6,13,19,16,20,21,26]
	for pin in output_pins:
		GPIO.setup(pin, GPIO.OUT)
