import numpy as np
import CSXCAD
from CSXCAD.CSProperties import CSPropConductingSheet
from CSXCAD.ParameterObjects import ParameterSet

import os
# parameters 

target_frequency = 1622e6 # MHz
f_min = 1200e6
f_max = 2000e6

substrate_thikness = 1.5e-3 # meters
trace_thikness = 0.0035e-3
trace_width = 0.0005 
trace_gap = 0.0005

epsilon_r = 4.8 #fr4 /!\ frquency 
epsilon_0 = 8.854e-12 # air 
c_0 = 3e8 #m/s
pi = np.pi
sigma_cu = 5.8e7       # conductivity S/m
substrate_kappa  = 1e-3 * 2*pi*2.45e9 * epsilon_0*epsilon_r # from the example Simple_patch antenna of openEMS


#formulas 

r_out = c_0/(2*pi*f_min) # meter
r_in = c_0/(2*pi*f_max)



print(f"outer radius in millimeter = {r_out*1000}")
print(f"inner radius in millimeter = {r_in*1000}")


# create the CAD object 

CSX = CSXCAD.ContinuousStructure() # create the object 

# create ground plan :

ground_start = [-r_out-0.005, -r_out-0.005, 0]
gound_stop = [+r_out+0.005, +r_out+0.005, trace_thikness]

ground_plan = CSX.AddMetal('ground plan') # create a metal property with name "ground plan"
ground_plan.AddBox(priority=10, start=ground_start, stop=gound_stop)


# create the subtrate


substrat_start = [-r_out-0.005, -r_out-0.005, trace_thikness]
substrat_stop = [+r_out+0.005, +r_out+0.005, trace_thikness+substrate_thikness]

substrate_plan = CSX.AddMaterial('substrate', epsilon=epsilon_r, kappa=substrate_kappa)
substrate_plan.AddBox(priority=10, start=substrat_start, stop=substrat_stop )


# export substrate and display it using the CAD
CSX.Write2XML("patch_antenna.xml")
os.system("AppCSXCAD " + "patch_antenna.xml")
