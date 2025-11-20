import numpy as np
import CSXCAD
from openEMS.openEMS import openEMS
import os


import constants as const
from create_spiral import create_sprial



print(f"outer radius in millimeter = {const.r_out*1000}")
print(f"inner radius in millimeter = {const.r_in*1000}")


# create the CAD object 

CSX = CSXCAD.ContinuousStructure() 


# simulation box
SimBox = np.array([const.r_out*4, const.r_out*4, const.r_out*3])

mesh = CSX.GetGrid()
mesh.SetDeltaUnit(1)
mesh_res = const.c_0/(const.target_frequency+const.f_min)/1e-3/20

### Generate properties, primitives and mesh-grid
#initialize the mesh with the "air-box" dimensions
mesh.AddLine('x', [-SimBox[0]/2, SimBox[0]/2])
mesh.AddLine('y', [-SimBox[1]/2, SimBox[1]/2]          )
mesh.AddLine('z', [-SimBox[2]/3, SimBox[2]*2/3]        )





# create ground plan :

ground_start = [-const.r_out-0.005, -const.r_out-0.005, 0]
gound_stop = [+const.r_out+0.005, +const.r_out+0.005, const.trace_thikness]

ground_plan = CSX.AddMetal('ground plan') # create a metal property with name "ground plan"
ground_plan.AddBox(priority=10, start=ground_start, stop=gound_stop)


# create the subtrate


substrat_start = [-const.r_out-0.005, -const.r_out-0.005, const.trace_thikness]
substrat_stop = [+const.r_out+0.005, +const.r_out+0.005, const.trace_thikness+const.substrate_thikness]

substrate_plan = CSX.AddMaterial('substrate', epsilon=const.epsilon_r, kappa=const.substrate_kappa)
substrate_plan.AddBox(priority=10, start=substrat_start, stop=substrat_stop )

# creating tht spiral

arm_material = CSX.AddMetal('arm')

spiral_arm = create_sprial(False, arm_material)
spiral_arm2 = create_sprial(True, arm_material)


antenna = CSX.AddMaterial('spiral')
#pt_1 = .AddVertex([0,0,0])



# export substrate and display it using the CAD
CSX.Write2XML("patch_antenna.xml")
os.system("AppCSXCAD " + "patch_antenna.xml")


