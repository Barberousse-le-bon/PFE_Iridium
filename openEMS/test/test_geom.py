import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

# Paramètres de l'antenne (mètres)
patch_width  = 32e-3
patch_length = 40e-3
substrate_width  = 60e-3
substrate_length = 60e-3
substrate_thickness = 1.524e-3
feed_pos = -6e-3

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# Fonction pour dessiner un rectangle en 3D (boîte simplifiée)
def draw_box(ax, start, stop, color, label=None):
    # coins du rectangle
    x = [start[0], stop[0], stop[0], start[0], start[0]]
    y = [start[1], start[1], stop[1], stop[1], start[1]]
    z = [start[2]]*5
    ax.plot(x, y, z, color=color, label=label)
    # côté supérieur
    z = [stop[2]]*5
    ax.plot(x, y, z, color=color)
    # vertical edges
    for i in range(4):
        ax.plot([x[i], x[i]], [y[i], y[i]], [start[2], stop[2]], color=color)

# Patch
draw_box(ax,
         start=[-patch_width/2, -patch_length/2, substrate_thickness],
         stop=[ patch_width/2,  patch_length/2, substrate_thickness+0.01e-3],
         color='red', label='Patch')

# Substrate
draw_box(ax,
         start=[-substrate_width/2, -substrate_length/2, 0],
         stop=[ substrate_width/2,  substrate_length/2, substrate_thickness],
         color='green', label='Substrate')

# Ground plane
draw_box(ax,
         start=[-substrate_width/2, -substrate_length/2, 0],
         stop=[ substrate_width/2,  substrate_length/2, 0.001e-3],
         color='blue', label='GND')

# Port (alimentation)
ax.scatter(feed_pos, 0, substrate_thickness/2, color='black', s=50, label='Port')

ax.set_xlabel('X (m)')
ax.set_ylabel('Y (m)')
ax.set_zlabel('Z (m)')
ax.legend()
ax.set_box_aspect([1,1,0.3])
plt.title("Visualisation 3D simplifiée de l'antenne patch")
plt.show()
