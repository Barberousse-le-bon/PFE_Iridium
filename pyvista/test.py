import numpy as np
import pyvista as pv

# ===============================
# variables
# ===============================
r_min= 0.028        # rayon initial (m)
gap = 0.0003        # espacement entre les spires (m)
n_turns = 50      # nombre de tours
n_points = 10000  # nombre de points par bras
r_max = 0.031 # rayon max de la spirale

trace_width = 0.0005       # largeur du trace (m)
trace_thickness = 0.00005   # épaisseur trace (m)
gnd_thikness = 0.0002           # offset au-dessus du plan de masse (m)
substrate_thikness = 0.005 # épasseur substrat (m)

# ===============================
# Fonction pour créer une spirale 3D en rectangle
# ===============================
def create_spiral_mesh(theta_offset=0.0, invert_r=False): # offset pour démarrer la spirale plus tard
    theta = np.linspace(0, 2*np.pi*n_turns, n_points) + theta_offset
    r = r_min+ gap*theta
    valid_r = []
    for r_value in r :
        if r_value < r_max:
            valid_r.append( float(r_value))
    valid_r = np.array(valid_r) # conversion en tableau numpy
    theta = theta[:len(valid_r)] # égaliser la longueur
    if invert_r:
        valid_r = -valid_r # inversion pour le second bras


    x = valid_r * np.cos(theta)
    y = valid_r * np.sin(theta)
    z = np.full_like(x, gnd_thikness + substrate_thikness)  # décale la spirale en z
    points = np.column_stack((x, y, z))

    vertices = []
    faces = []

    for i in range(len(points)-1):
        p0 = points[i]
        p1 = points[i+1]

        tangent = p1 - p0
        tangent[2] = 0
        tangent /= np.linalg.norm(tangent[:2])

        normal = np.array([-tangent[1], tangent[0], 0]) * trace_width/2

        v0 = p0 + normal
        v1 = p0 - normal
        v2 = p1 - normal
        v3 = p1 + normal
        base = [v0, v1, v2, v3]
        top  = [v + np.array([0,0,trace_thickness]) for v in base]

        idx = len(vertices)
        vertices.extend(base)
        vertices.extend(top)
        faces.extend([
            [4, idx, idx+1, idx+2, idx+3],
            [4, idx+4, idx+5, idx+6, idx+7],
            [4, idx, idx+1, idx+5, idx+4],
            [4, idx+1, idx+2, idx+6, idx+5],
            [4, idx+2, idx+3, idx+7, idx+6],
            [4, idx+3, idx, idx+4, idx+7]
        ])

    return pv.PolyData(np.array(vertices), faces)

# Créer les deux bras avec le même z_offset
spiral1 = create_spiral_mesh(theta_offset=0.0, invert_r=False)
spiral2 = create_spiral_mesh(theta_offset=0.0, invert_r=True)

# ===============================
# Substrat et plan de masse
# ===============================
substrate_w, substrate_l, substrate_h = r_max*2+0.01, r_max*2+0.01, substrate_thikness  # m

substrate = pv.Box(bounds=[-substrate_w/2, substrate_w/2,
                           -substrate_l/2, substrate_l/2,
                           gnd_thikness, substrate_h])
gnd = pv.Box(bounds=[-substrate_w/2, substrate_w/2,
                     -substrate_l/2, substrate_l/2,
                     0, gnd_thikness])

# ===============================
# Visualisation
# ===============================
plotter = pv.Plotter()
plotter.add_mesh(substrate, color='green', opacity=0.7, label='Substrate')
plotter.add_mesh(gnd, color='blue', label='Ground')
plotter.add_mesh(spiral1, color='red', label='Spiral Arm 1')
plotter.add_mesh(spiral2, color='orange', label='Spiral Arm 2')
plotter.add_legend()
plotter.show()


# === Combiner toutes les pièces ===
antenna = spiral1 + spiral2

# === Export STL ===
antenna.save("antenne_spirale.stl")
print("stl exporté")