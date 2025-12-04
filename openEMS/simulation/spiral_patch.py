import numpy as np
import CSXCAD
from openEMS.openEMS import openEMS
import os
from pylab import *
import time


import constants as const
from create_spiral import create_sprial


start = time.time()

postproc_only = False

print(f"outer radius in millimeter = {const.r_out}")
print(f"inner radius in millimeter = {const.r_in}")


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

ground_start = [-const.r_out-const.extra_width_gnd, -const.r_out-const.extra_width_gnd, 0]
gound_stop = [+const.r_out+const.extra_width_gnd, +const.r_out+const.extra_width_gnd, const.trace_thikness]

ground_plan = CSX.AddMetal('ground plan') # create a metal property with name "ground plan"
ground_plan.AddBox(priority=10, start=ground_start, stop=gound_stop)


# create the subtrate


substrat_start = [-const.r_out-const.extra_width_gnd, -const.r_out-const.extra_width_gnd, const.trace_thikness]
substrat_stop = [+const.r_out+const.extra_width_gnd, +const.r_out+const.extra_width_gnd, const.trace_thikness+const.substrate_thikness]

substrate_plan = CSX.AddMaterial('substrate', epsilon=const.epsilon_r, kappa=const.substrate_kappa)
substrate_plan.AddBox(priority=10, start=substrat_start, stop=substrat_stop )

# creating tht spiral

arm_material1 = CSX.AddMetal('arm1')
arm_material2 = CSX.AddMetal('arm2')

spiral_arm = create_sprial(False, arm_material1)
spiral_arm2 = create_sprial(True, arm_material2)


grid = CSX.GetGrid()
grid.SetLines('x', np.arange(-150,150,1))
grid.SetLines('y', np.arange(-150,150,1))
grid.SetLines('z', np.arange(-80,80,1))
grid.SetDeltaUnit(1e-3)

# export substrate and display it using the CAD
CSX.Write2XML("patch_antenna.xml")
os.system("AppCSXCAD " + "patch_antenna.xml")


# simulation part 


### ---------------- SIMULATION ---------------- ###

# Create FDTD
FDTD = openEMS(NrTS=2e8, EndCriteria=1e-6)
FDTD.SetCSX(CSX)

# Boundary conditions : PML recommended
FDTD.SetBoundaryCond(['PML_8', 'PML_8', 'PML_8', 'PML_8', 'PML_8', 'PML_8'])

# Excitation : Gaussian covering 1.2–2.0 GHz
FDTD.SetGaussExcite(const.f_center, const.f_c)

# Lumped Port : feed at center of spiral
port = FDTD.AddLumpedPort(
    port_nr=1,
    R=50,
    start=[0, 0, 0.05],
    stop=[0, 0, +0.5],
    p_dir='z',
    excite=1
)

# Add mesh refinement based on metallic objects
FDTD.AddEdges2Grid(dirs='all', properties=ground_plan)
FDTD.AddEdges2Grid(dirs='all', properties=substrate_plan)
FDTD.AddEdges2Grid(dirs='all', properties=arm_material1)
FDTD.AddEdges2Grid(dirs='all', properties=arm_material2)

# NF2FF box
nf2ff = FDTD.CreateNF2FFBox()

# Run simulation
if not postproc_only :
    FDTD.Run(sim_path=const.sim_path)
end = time.time()

print("Temps d'exécution :", end - start, "secondes")

### ---------------- POST-PROCESSING ---------------- ###

# Frequency vector : 1.2–2.0 GHz
f = np.linspace(const.f_min, const.f_max, 801)

# Calculate S11
port.CalcPort(const.sim_path, f)
s11 = port.uf_ref / port.uf_inc
s11_dB = 20*np.log10(np.abs(s11))

figure()
plot(f/1e9, s11_dB, 'k-', linewidth=2)
xlabel('Frequency (GHz)')
ylabel('S11 (dB)')
title('Reflection Coefficient S11')
#grid(True)


### --- Find resonance for NF2FF ---
idx = np.argmin(np.abs(s11))
f_res = f[idx]

print(f"Resonance estimated at {f_res/1e9:.3f} GHz")


### ---------------- NF2FF Far-field ---------------- ###

theta = np.arange(-180.0, 180.0, 2.0)
phi = [0., 90.]

nf2ff_res = nf2ff.CalcNF2FF(
    const.sim_path,
    f_res,
    theta,
    phi,
    center=[0, 0, const.substrate_thikness/1000 + const.trace_thikness/2000]
)

# Normalized directivity patterns
E_norm = 20 * np.log10(nf2ff_res.E_norm[0] / np.max(nf2ff_res.E_norm[0])) \
         + 10*np.log10(nf2ff_res.Dmax[0])

figure()
plot(theta, E_norm[:, 0], 'k-', label='xz-plane')
plot(theta, E_norm[:, 1], 'r--', label='yz-plane')
xlabel("Theta (deg)")
ylabel("Directivity (dBi)")
title(f'Far-field Pattern @ {f_res/1e9:.3f} GHz')
legend()
#grid(True)


### ---------------- Input Impedance ---------------- ###

Zin = port.uf_tot / port.if_tot

figure()
plot(f/1e9, np.real(Zin), 'k-', linewidth=2, label='Real(Zin)')
plot(f/1e9, np.imag(Zin), 'r--', linewidth=2, label='Imag(Zin)')
xlabel("Frequency (GHz)")
ylabel("Impedance (Ohm)")
legend()
#grid(True)

show()
