import os
import numpy as np
from CSXCAD import CSXCAD, CSPrimitives, CSProperties

# Création du document CSX
csx = CSXCAD.ContinuousStructure() 

# Propriétés (par exemple matériau cuivre)
mat = csx.AddMaterial('substrate', epsilon=1, kappa=5e7)
mat2 = csx.AddMaterial('substrate', epsilon=1, kappa=5e7)

# Création du polyèdre
poly = mat.AddPolyhedron()

# Ajout des sommets (exemple d’un prisme triangulaire)
v0 = poly.AddVertex(0.0, 0.0, 0.0)
v1 = poly.AddVertex(10.0, 0.0, 0.0)
v2 = poly.AddVertex(0.0, 10.0, 0.0)
v3 = poly.AddVertex(0.0, 0.0, 10.0)
#v4 = poly.AddVertex(10.0, 0.0, 2.0)
#v5 = poly.AddVertex(5.0, 8.0, 2.0)

# Ajout des faces (triangles uniquement, comme précisé dans la doc)
# Face « base » (triangle 0-1-2)
#poly.AddFace([0, 1, 2])
# Face « top » (triangle 3-4-5)
#poly.AddFace([0, 1, 3])
# Face « côté » 1 (0-1-4)
#poly.AddFace([1, 2, 3])
# Face « côté » 2 (0-4-3)
#poly.AddFace([0, 2, 3])




theta = np.linspace(0, 2*np.pi*50, 50)
x = 1 * np.cos(theta)
y = 1 * np.sin(theta)
z = np.full_like(x, 0.0035e-3 + 1.5e-3)  # décale la spirale en z
points = np.column_stack((x, y, z))
array_points = []
for point in points:
    array_point = np.array(point)
    array_points.append(array_point)

print(array_points[0][0])
print(array_points[0][1])
print(array_points[0][2])

curve = mat2.AddCurve(points=[array_points[0], array_points[1], array_points[2]])
curve.ClearPoints()
for point in array_points:
    curve.AddPoint(point)





# Eventuellement appliquer une transformation (translation, rotation)
poly.SetCoordinateSystem(0)  # 0 = cartésien
# Exemple : translation
# poly.AddTransform(<transformation matrix or object>)

# Poursuite du reste (grille, solveur…) selon votre configuration
csx.Write2XML('spiral_arm_polyhedron.xml')
os.system("AppCSXCAD " + "spiral_arm_polyhedron.xml")