import numpy as np
import CSXCAD



import os



def create_sprial(theta_offset=0.0, invert_r=False):
    theta = np.linspace(0, 2*np.pi*n_turns, n_points) + theta_offset
    r = r_in+ trace_gap*theta
    valid_r = []
    for r_value in r :
        if r_value < r_out:
            valid_r.append( float(r_value))
    valid_r = np.array(valid_r) # conversion en tableau numpy
    theta = theta[:len(valid_r)] # égaliser la longueur
    if invert_r:
        valid_r = -valid_r # inversion pour le second bras


    x = valid_r * np.cos(theta)
    y = valid_r * np.sin(theta)
    z = np.full_like(x, trace_thikness + substrate_thikness)  # décale la spirale en z
    points = np.column_stack((x, y, z))

    return 0






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

n_turns = 50 # just for generating the base spiral
n_points = 10000  # number of points by arms

#formulas 

r_out = c_0/(2*pi*f_min) # meter
r_in = c_0/(2*pi*f_max)



print(f"outer radius in millimeter = {r_out*1000}")
print(f"inner radius in millimeter = {r_in*1000}")


# create the CAD object 

CSX = CSXCAD.ContinuousStructure() 


# simulation box
SimBox = np.array([r_out*4, r_out*4, r_out*3])

mesh = CSX.GetGrid()
mesh.SetDeltaUnit(1)
mesh_res = c_0/(target_frequency+f_min)/1e-3/20

### Generate properties, primitives and mesh-grid
#initialize the mesh with the "air-box" dimensions
mesh.AddLine('x', [-SimBox[0]/2, SimBox[0]/2])
mesh.AddLine('y', [-SimBox[1]/2, SimBox[1]/2]          )
mesh.AddLine('z', [-SimBox[2]/3, SimBox[2]*2/3]        )





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

# creating tht spiral

create_sprial()


antenna = CSX.AddMaterial('spiral')
#pt_1 = .AddVertex([0,0,0])



# export substrate and display it using the CAD
CSX.Write2XML("patch_antenna.xml")
os.system("AppCSXCAD " + "patch_antenna.xml")



