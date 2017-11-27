def gcode_interpreter(gcode):

	import numpy as np
	import time

	pt_A = np.array([0,0,0]) # begin with pt_A at home
	pt_B = np.array([0,0,0]) # begin with unfilled pt_B array
	v_max = 0 # begin with max velocity set to 0
	v_rapid = 1000 # velocity for rapid (G00) movements
	unit_multiplier = 1 # for mm/inch conversion
	print('Ready to run G-Code')
	input("Press Enter to continue...")
	print('Running G-Code...')
	with open(gcode) as f:
		for line in f: # go line by line
			#print(line)

			if (line[0] == 'G'): # if it's a G command

				#print('  G command found') #debug
				if(line[1] + line[2] == '20'): # if it's a G20 (programming in inches) // Default is G21 (programming in mm)
					unit_multiplier = 25.4
				if(line[1] + line[2] == '21'): # if it's a G20 (programming in inches) // Default is G21 (programming in mm)
					unit_multiplier = 1

				if(line[1] + line[2] == '01' or line[1] + line[2] == '00'): # if it's a G01 or a G00
					#print('    linear interpolation found') #debug
					if (line.find('X') != -1):
						#print('      X found') #debug
						if(line.find(' ', line.index('X'), len(line)) == -1): # if no space after X, read to line ending
							pt_B[0] = unit_multiplier*int(line[line.index('X')+1:len(line)])
						else: # if space after X, i.e. more info on line
							pt_B[0] = unit_multiplier*int(line[line.index('X')+1:line.index(' ', line.index('X'), len(line))])
					if (line.find('Y') != -1):
						#print('      Y found') #debug
						if(line.find(' ', line.index('Y'), len(line)) == -1): # if no space after X, read to line ending
							pt_B[1] = unit_multiplier*int(line[line.index('Y')+1:len(line)])
						else: # if space after X, i.e. more info on line
							pt_B[1] = unit_multiplier*int(line[line.index('Y')+1:line.index(' ', line.index('Y'), len(line))])
					if (line.find('Z') != -1):
						#print('      Z found') #debug
						if(line.find(' ', line.index('Z'), len(line)) == -1): # if no space after X, read to line ending
							pt_B[2] = unit_multiplier*int(line[line.index('Z')+1:len(line)])
						else: # if space after X, i.e. more info on line
							pt_B[2] = unit_multiplier*int(line[line.index('Z')+1:line.index(' ', line.index('Z'), len(line))])
					if (line.find('F') != -1):
						#print('      F found') #debug
						if(line.find(' ', line.index('F'), len(line)) == -1): # if no space after X, read to line ending
							v_max = unit_multiplier*int(line[line.index('F')+1:len(line)])
						else: # if space after X, i.e. more info on line
							v_max = unit_multiplier*int(line[line.index('F')+1:line.index(' ', line.index('F'), len(line))])
					if ((line.find('X') != -1) or (line.find('Y') != -1) or (line.find('Z') != -1)):
						if (line[1] + line[2] == '00'):
							print('rapid from', pt_A, 'to', pt_B, 'at', v_rapid, 'mm/min')
							#CALL FUNCTION TO MOVE EFFECTOR
						else:
							print('move from', pt_A, 'to', pt_B, 'at', v_max, 'mm/min')
							#CALL FUNCTION TO MOVE EFFECTOR
					if ((line.find('X') == -1) and (line.find('Y') == -1) and (line.find('Z') == -1) and line.find('F') != -1):
						print('feed rate changed to', v_max, 'mm/min')
						

					if (line.find('C') != -1):
						#print('      C found') #debug
						if(line.find(' ', line.index('C'), len(line)) == -1): # if no space after X, read to line ending
							c = int(line[line.index('C')+1:len(line)])
						else: # if space after X, i.e. more info on line
							c = int(line[line.index('C')+1:line.index(' ', line.index('C'), len(line))])
						print('rotate effector to', c, 'degrees')

						# CALL FUNCTION TO ROTATE EFFECTOR

				if(line[1] + line[2] == '04'): # if it's a G04
					#print('    dwell found')
					if (line.find('P') != -1):
						#print('      time found')
						if(line.find(' ', line.index('P'), len(line)) == -1): # if no space after X, read to line ending
							dwell = int(line[line.index('P')+1:len(line)])
						else: # if space after X, i.e. more info on line
							dwell = int(line[line.index('P')+1:line.index(' ', line.index('P'), len(line))])
						print('dwell for', dwell, 'milliseconds')
						time.sleep(dwell/1000)
			time.sleep(1) # temporary, to simulate runtime of each command
			pt_A = np.copy(pt_B)
			if (line[0] == 'M'): # if it's an M command
				#print('M command')
				if (line[1] + line[2] == '00'): # compulsory stop
					print('Compulsory Stop')
					input("Press Enter to continue...")
					print('Resuming G-Code')

				if (line[1] + line[2] == '10'):
					print('turn on electromagnet')
					# TURN ON ELECTROMAGNET
				if (line[1] + line[2] == '11'):
					print('turn off electromagnet')
					# TURN OFF ELECTROMAGNET
				if (line[1] + line[2] == '30'):
					print('End of program.')
					break




