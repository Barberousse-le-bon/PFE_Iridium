import CSXCAD
from CSXCAD.CSProperties import CSPropConductingSheet
from CSXCAD.ParameterObjects import ParameterSet

from openEMS import openEMS


# creating a metal box 

CSX = CSXCAD.ContinuousStructure() # creatie the object 
metal = CSX.AddMetal('metal') # create a metal property with name "metal"
start = [0,0,0] #coordinates of points
stop  = [1,2,1]
box   = metal.AddBox(start, stop) # Assign a box to propety "metal"


# creating a metal sheet 

# metal parameters
sigma_cu = 5.8e7       # conductivity S/m
thickness_cu = 35e-6   # thikness 35 µm = 35e-6 m
params = ParameterSet()

# set properties on ne peut pas set les propritétés ??????

sheet_prop = CSPropConductingSheet(params)
sheet_prop.SetConductivity(sigma_cu)
sheet_prop.SetThickness(thickness_cu)


# rectangular trace 
z_offset = 0.001
trace = CSX.AddMetal('sheet')            # créer un métal (il faut associer la propriété)
start = [ -0.010, 0.0, z_offset ]        # en mètres
stop  = [  0.010, 0.005, z_offset ]      # en mètres
trace.AddBox(priority=10, start=start, stop=stop)

