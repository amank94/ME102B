def execute_command(command_array):
	import time
	import RPi.GPIO as GPIO
	time_step = 1
	for i in range(len(command_array)):
		start_time = time.perf_couter();

		GPIO.output(3, command_array[1,i]) # T1 DIR
		GPIO.output(14, command_array[3,i]) # T2 DIR
		GPIO.output(18, command_array[5,i]) # T3 DIR
		GPIO.output(27, command_array[7,i]) # T4 DIR
		GPIO.output(23, command_array[9,i]) # B1 DIR
		GPIO.output(25, command_array[11,i]) # B2 DIR
		GPIO.output(6, command_array[13,i]) # B3 DIR
		GPIO.output(19, command_array[15,i]) # B4 DIR

		GPIO.output(2, command_array[2,i]) # T1 STP
		GPIO.output(4, command_array[4,i]) # T2 STP
		GPIO.output(15, command_array[6,i]) # T3 STP
		GPIO.output(17, command_array[8,i]) # T4 STP
		GPIO.output(22, command_array[10,i]) # B1 STP
		GPIO.output(24, command_array[12,i]) # B2 STP
		GPIO.output(5, command_array[14,i]) # B3 STP
		GPIO.output(13, command_array[16,i]) # B4 STP

		GPIO.output(2, 0) # T1 STP
		GPIO.output(4, 0) # T2 STP
		GPIO.output(15, 0) # T3 STP
		GPIO.output(17, 0) # T4 STP
		GPIO.output(22, 0) # B1 STP
		GPIO.output(24, 0) # B2 STP
		GPIO.output(5, 0) # B3 STP
		GPIO.output(13, 0) # B4 STP

		time.sleep(time_step - time.perf_couter() + start_time)
		