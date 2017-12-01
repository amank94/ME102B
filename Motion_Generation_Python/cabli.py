
import time
import numpy as np
import tkinter as tk
from tkinter import filedialog
from gcode_interpreter import gcode_interpreter
from setup_sequence import setup_sequence

# GPIO SETUP
setup_sequence()

# HOMING SEQUENCE
print('Ready to home system?')
time.sleep(1)
raw_input("Press Enter to continue...")
time.sleep(1)
print('Homing system...')
# REEL IN WINCHES
print('Homing complete.')
time.sleep(1)

# SELECT AND RUN G-CODE
pt_A = np.array([0,0,0]) # begin with pt_A at home
while True:
	print('Select G-Code')
	time.sleep(1)
	root = tk.Tk()
	root.withdraw()
	gcode = filedialog.askopenfilename()
	print('beginning at', pt_A)
	pt_B = gcode_interpreter(gcode, pt_A)
	pt_A = np.copy(pt_B)