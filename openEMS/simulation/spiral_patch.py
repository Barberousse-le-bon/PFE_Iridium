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


grid = CSX.GetGrid()
grid.SetLines('x', np.arange(-50,50,1))
grid.SetLines('y', np.arange(-50,50,1))
grid.SetLines('z', np.arange(-2,2.1,1))
grid.SetDeltaUnit(1e-3)

# export substrate and display it using the CAD
CSX.Write2XML("patch_antenna.xml")
os.system("AppCSXCAD " + "patch_antenna.xml")


# simulation part 




FDTD = openEMS(NrTS=1e8, EndCriteria=1e-5) # number of timesteps, end if the energy is below 

FDTD.SetCSX(CSX)


FDTD.SetBoundaryCond(['MUR', 'MUR', 'MUR', 'MUR', 'MUR', 'MUR']) # mur absorbs everything
FDTD.SetGaussExcite(const.f_center, const.f_max-const.f_min) #center freq, -20dB bandwidth
FDTD.AddLumpedPort(port_nr=1, R=50, start=[10, 0, -2], stop=[10, 0, 2], p_dir='z', excite=1)

FDTD.AddEdges2Grid(dirs='all', properties=ground_plan)
FDTD.AddEdges2Grid(dirs='all', properties=substrate_plan)
FDTD.AddEdges2Grid(dirs='all', properties=arm_material)

FDTD.Run(sim_path='/home/lucas/iridium/openEMS/simulation/sim')