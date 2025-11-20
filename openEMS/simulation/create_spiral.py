import numpy as np


import constants as const

def create_sprial(invert_r=False, material=None):
    if material == None :
        print("wrong material given")
        exit(1)


    theta = np.linspace(0, 2*np.pi*const.n_turns, const.n_points)
    r = const.r_in+ const.trace_gap*theta
    valid_r = []
    for r_value in r :
        if r_value < const.r_out:
            valid_r.append( float(r_value))
    valid_r = np.array(valid_r) # conversion en tableau numpy
    theta = theta[:len(valid_r)] # égaliser la longueur
    if invert_r:
        valid_r = -valid_r # inversion pour le second bras


    x = valid_r * np.cos(theta)
    y = valid_r * np.sin(theta)
    z = np.full_like(x, const.trace_thikness + const.substrate_thikness)  # décale la spirale en z
    points = np.column_stack((x, y, z))

    array_points = []
    for point in points:
        array_point = np.array(point)
        array_points.append(array_point)
    
    curve = material.AddCurve(points=[array_points[0], array_points[1], array_points[2]])
    curve.ClearPoints()
    for point in array_points:
        curve.AddPoint(point)

    return curve
