def execute_command(command_array, time_step):
	from datetime import timedelta
	import time
	import RPi.GPIO as GPIO
	for i in range(len(command_array[0])):

        start = time.time

		GPIO.output(3, int(command_array[0,i])) # T1 DIR
		GPIO.output(14, int(command_array[2,i])) # T2 DIR
		GPIO.output(18, int(command_array[4,i])) # T3 DIR
		GPIO.output(27, int(command_array[6,i])) # T4 DIR
		GPIO.output(23, int(command_array[8,i])) # B1 DIR
		GPIO.output(25, int(command_array[10,i])) # B2 DIR
		GPIO.output(6, int(command_array[12,i])) # B3 DIR
		GPIO.output(19, int(command_array[14,i])) # B4 DIR

		GPIO.output(2, int(command_array[1,i])) # T1 STP
		GPIO.output(4, int(command_array[3,i])) # T2 STP
		GPIO.output(15, int(command_array[5,i])) # T3 STP
		GPIO.output(17, int(command_array[7,i])) # T4 STP
		GPIO.output(22, int(command_array[9,i])) # B1 STP
		GPIO.output(24, int(command_array[11,i])) # B2 STP
		GPIO.output(5, int(command_array[13,i])) # B3 STP
		GPIO.output(13, int(command_array[15,i])) # B4 STP

		GPIO.output(2, 0) # T1 STP
		GPIO.output(4, 0) # T2 STP
		GPIO.output(15, 0) # T3 STP
		GPIO.output(17, 0) # T4 STP
		GPIO.output(22, 0) # B1 STP
		GPIO.output(24, 0) # B2 STP
		GPIO.output(5, 0) # B3 STP
		GPIO.output(13, 0) # B4 STP
		

		elapsed = start - time.time
		
		time.sleep(time_step - elapsed)		
# =======
# 		end = time.time()
# 		elapsed = end-start
		
# 		time.sleep(0.001-0.0003)
