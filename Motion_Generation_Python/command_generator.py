def command_generator(stepped_cables):
	import numpy as np

	command_array = np.zeros([16, len(stepped_cables[0]-1)]);

	for i in range(8):
		for j in range(1,len(stepped_cables[0])):

			diff = stepped_cables[i,j] -  stepped_cables[i,j-1]
			if diff > 0 :
				step = 1
				direction = 1

			if diff < 0 :
				step = 1
				direction = 0

			else :
				step = 0
				direction = 0 

			command_array[2*i,j] = step
			command_array[2*i+1,j] = direction
        	command_array.astype(int)
	
	return command_array


