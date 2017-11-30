def command_generator(stepped_cables):
	import numpy as np

	command_array = np.zeros([16, len(stepped_cables[0]-1)]);

	for i in range(8):
		for j in range(1,len(stepped_cables[0])):

			diff = np.sign(stepped_cables[i,j] -  stepped_cables[i,j-1])
			print(diff)
			if int(diff) == 1 :
				step = 1
				direction = 1

			if int(diff) < -0.5 :
				step = 1
				direction = 0

			if int(diff) == 0 :
				step = 0
				direction = 0 
			else:
				print('error in command generator', i, j)

			command_array[2*i,j] = direction
			command_array[2*i+1,j] = step
	
	print(command_array.shape)
	print('command array', command_array)
	
	return command_array


