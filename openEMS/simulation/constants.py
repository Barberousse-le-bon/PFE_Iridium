import numpy as np

# parameters 

target_frequency = 1622e6 # MHz
f_min = 1200e6
f_max = 2000e6

substrate_thikness = 1.5 # millimeters
trace_thikness = 0.0035
trace_width = 0.5 
trace_gap = 0.5
extra_width_gnd = 5

epsilon_r = 4.8 #fr4 /!\ frquency 
epsilon_0 = 8.854e-12 # air 
c_0 = 3e8 #m/s
pi = np.pi
sigma_cu = 5.8e7       # conductivity S/m
substrate_kappa  = 1e-3 * 2*pi*2.45e9 * epsilon_0*epsilon_r # from the example Simple_patch antenna of openEMS

n_turns = 50 # just for generating the base spiral
n_points = 10000  # number of points by arms

#formulas 

r_out = c_0/(2*pi*f_min)*1000 # meter
r_in = c_0/(2*pi*f_max)*1000
f_center = (f_max+f_min)/2
f_c = f_max-f_min

# others 


sim_path='/home/lucas/iridium/openEMS/simulation/sim'