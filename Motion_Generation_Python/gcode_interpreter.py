def gcode_interpreter(gcode, pt_A):

	import numpy as np
	import time
	from rotate_effector import rotate_effector
	from switch_electromagnet import switch_electromagnet
	from motion_generator import motion_generator

	pt_B = np.copy(pt_A) # begin with unfilled pt_B array
	v_max = 0 # begin with max velocity set to 0
	v_rapid = 100 # velocity for rapid (G00) movements
	unit_multiplier = 1 # for mm/inch conversion

	x_max = 400
	y_max = 400
	z_max = 500

	print('Ready to run G-Code')
	input("Press Enter to continue...")
	print('Running G-Code...')
	with open(gcode) as f:
		for line in f: # go line by line
			if (line[0] == 'G'): # if it's a G command

				if(line[1] + line[2] == '20'): # if it's a G20 (programming in inches) // Default is G21 (programming in mm)
					unit_multiplier = 25.4

				if(line[1] + line[2] == '21'): # if it's a G20 (programming in inches) // Default is G21 (programming in mm)
					unit_multiplier = 1

				if(line[1] + line[2] == '01' or line[1] + line[2] == '00'): # if it's a G01 or a G00
					if (line.find('X') != -1):
						if(line.find(' ', line.index('X'), len(line)) == -1): # if no space after X, read to line ending
							pt_B[0] = unit_multiplier*int(line[line.index('X')+1:len(line)])
						else: # if space after X, i.e. more info on line
							pt_B[0] = unit_multiplier*int(line[line.index('X')+1:line.index(' ', line.index('X'), len(line))])
					if (line.find('Y') != -1):
						if(line.find(' ', line.index('Y'), len(line)) == -1): # if no space after X, read to line ending
							pt_B[1] = unit_multiplier*int(line[line.index('Y')+1:len(line)])
						else: # if space after X, i.e. more info on line
							pt_B[1] = unit_multiplier*int(line[line.index('Y')+1:line.index(' ', line.index('Y'), len(line))])
					if (line.find('Z') != -1):
						if(line.find(' ', line.index('Z'), len(line)) == -1): # if no space after X, read to line ending
							pt_B[2] = unit_multiplier*int(line[line.index('Z')+1:len(line)])
						else: # if space after X, i.e. more info on line
							pt_B[2] = unit_multiplier*int(line[line.index('Z')+1:line.index(' ', line.index('Z'), len(line))])
					if (line.find('F') != -1):
						if(line.find(' ', line.index('F'), len(line)) == -1): # if no space after X, read to line ending
							v_max = unit_multiplier*int(line[line.index('F')+1:len(line)])
						else: # if space after X, i.e. more info on line
							v_max = unit_multiplier*int(line[line.index('F')+1:line.index(' ', line.index('F'), len(line))])
					if ((line.find('X') != -1) or (line.find('Y') != -1) or (line.find('Z') != -1)):
						if (pt_B[0] > x_max):
							pt_B[0] = x_max
						if (pt_B[0] < 0):
							pt_B[0] = 0
						if (pt_B[1] > y_max):
							pt_B[1] = y_max
						if (pt_B[1] < 0):
							pt_B[1] = 0
						if (pt_B[2] > z_max):
							pt_B[2] = z_max
						if (pt_B[2] < 0):
							pt_B[2] = 0			# make sure pt_B is within work volume and correct if not

						if (line[1] + line[2] == '00'):
							print('rapid from', pt_A, 'to', pt_B, 'at', v_rapid, 'mm/min')
							motion_generator(pt_A, pt_B, v_rapid)
						else:
							print('move from', pt_A, 'to', pt_B, 'at', v_max, 'mm/min')
							motion_generator(pt_A, pt_B, v_max)
					if ((line.find('X') == -1) and (line.find('Y') == -1) and (line.find('Z') == -1) and line.find('F') != -1):
						print('feed rate changed to', v_max, 'mm/min')

					if (line.find('C') != -1):
						if(line.find(' ', line.index('C'), len(line)) == -1): # if no space after X, read to line ending
							c = int(line[line.index('C')+1:len(line)])
						else: # if space after X, i.e. more info on line
							c = int(line[line.index('C')+1:line.index(' ', line.index('C'), len(line))])
						print('rotate effector to', c, 'degrees')
						if (c > 180):
							c = 180
						if (c < 0):
							c = 0
						rotate_effector(c)

				if(line[1] + line[2] == '04'): # if it's a G04
					if (line.find('P') != -1):
						if(line.find(' ', line.index('P'), len(line)) == -1): # if no space after X, read to line ending
							dwell = int(line[line.index('P')+1:len(line)])
						else: # if space after X, i.e. more info on line
							dwell = int(line[line.index('P')+1:line.index(' ', line.index('P'), len(line))])
						print('dwell for', dwell, 'milliseconds')
						time.sleep(dwell/1000)
			pt_A = np.copy(pt_B)
			if (line[0] == 'M'): # if it's an M command
				if (line[1] + line[2] == '00'): # compulsory stop
					print('Compulsory Stop')
					input("Press Enter to continue...")
					print('Resuming G-Code')

				if (line[1] + line[2] == '10'):
					print('turn on electromagnet')
					switch_electromagnet(1)
				if (line[1] + line[2] == '11'):
					print('turn off electromagnet')
					switch_electromagnet(0)
				if (line[1] + line[2] == '30'):
					print('End of program.')
					break

	return(pt_B)