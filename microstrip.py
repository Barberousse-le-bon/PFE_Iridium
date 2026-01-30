import numpy as np
import CSXCAD
from openEMS.openEMS import openEMS
import os
from pylab import *
import time


################################################################################
#                            CONSTANTS                                         #
################################################################################
only_display = 0 # mettre à 1 pour afficher simplement les résultats sans relancer la simulation

f0 = 2e9
fc = f0/2    # corner frequ
epsilon = 4.4
substrate_width = 20
substrate_length = 40
substrate_height = 1.6
trace_thikness = 0.030
z0 = 50 #ohm
c = 3e11 # mm/s



#calcul de la lageur de la ligne qui est liée à l'impédance, l'épaisseur du substrat, de la ligne et la permittivité du substrat
line_width = ((7.48*substrate_height)/np.exp(z0*(np.sqrt(epsilon+1.41)/87)))-1.25*trace_thikness


#résolution du maillage déendant de la vitesse de proagation de l'onde dnass le substrat
resolution = c/((f0+fc)*np.sqrt(epsilon))/20

################################################################################
#                            CREATION DU MODELE                                #
################################################################################
# init de la structure 
CSX = CSXCAD.ContinuousStructure()


# creation du modèle de silulation FDTD
FDTD = openEMS(EndCriteria=1e-6)
FDTD.SetCSX(CSX)


#création des objets à positionner dans l'espace les métaux sont considérés comme des conducteurs parfaits
ground = CSX.AddMetal('ground')
microstrip = CSX.AddMetal('microstip')
substrate = CSX.AddMaterial('substrate', epsilon = epsilon)
# pour les autres matériaux on les définit en leurs donnant leurs permittivité électromagnétque



# Chaque objet d'une ligne peut être décrite comme un pavé en leurs donnant les coordonnées de dux coins opposés 
start_substrate = [-substrate_width/2,-substrate_length/2,-substrate_height]
stop_substrate = [substrate_width/2,substrate_length/2,0]
substrate.AddBox(start=start_substrate, stop=stop_substrate )

# add ground
start_gnd = [-substrate_width/2,-substrate_length/2,-substrate_height]
stop_gnd = [substrate_width/2,substrate_length/2,-substrate_height-trace_thikness]
ground.AddBox(start = start_gnd, stop = stop_gnd)

# create line :
start_line = [-line_width/2, -substrate_length/2, 0]
stop_line = [line_width/2, substrate_length/2, trace_thikness]
microstrip.AddBox(start= start_line, stop = stop_line)


################################################################################
#                            ENVIRONMENT CAD                                   #
################################################################################
# récupération de la gille de maillage 

mesh = CSX.GetGrid()


# définition des dimentions du maillage

mesh.AddLine('x',[-substrate_width, substrate_width]) #plan YZ
mesh.AddLine('y',[-substrate_length, substrate_length]) # plan XZ
mesh.AddLine('z',[-substrate_height-10, substrate_height+10]) # plan XY



# on rafine les objets aux endroits intéressants (properties) dans toutes les directions 
FDTD.AddEdges2Grid(dirs='all', properties=ground)
FDTD.AddEdges2Grid(dirs='all', properties=substrate)
FDTD.AddEdges2Grid(dirs='all', properties=microstrip)

# augmentation de la résolution du maillage 

mesh.SmoothMeshLines('all',resolution, 1.25) # axes, max res, ratio


# définition des unités de la gille, ici millimètres 
mesh.SetDeltaUnit(1e-3)

################################################################################
#                            FDTD PARAMETERS                                   #
################################################################################


# définition des condions aux limites du maillage 
# PEC pour un conducteur électrique parfait qui absorbera une majorité du signal
# PML pour une approximaion mathématique pour annuler le signal
FDTD.SetBoundaryCond(['PML_8', 'PML_8', 'PML_8', 'PML_8', 'PML_8', 'PML_8'])

# définition de l'excitation électromagnétique de f0-fc jusqu'à f0+fc 
FDTD.SetGaussExcite(f0, fc)



# les ports sont définis géométriquement de la même manière que les éléments précédents par un pavé
start_lumped1 = [-line_width/2,-substrate_length/2,-substrate_height-trace_thikness]
stop_lumped1 = [line_width/2,-substrate_length/2,trace_thikness]
port1 = FDTD.AddLumpedPort(
    port_nr=1,              # numéro du port pour l'identifier  
    R=50,                   # impédance du port
    start=start_lumped1,    # premier point de coordonnée 
    stop=stop_lumped1,      # deuxième point de coordonnée 
    p_dir='z',              # direction du port
    excite=1                # amplitude de l'excitation du port
)

# le deuxième port sert juste à pouvoir calculer s21 et s22
start_lumped2 = [-line_width/2,substrate_length/2,-substrate_height-trace_thikness]
stop_lumped2 = [line_width/2,substrate_length/2,trace_thikness]
port2 = FDTD.AddLumpedPort(
    port_nr=2,
    R=50,
    start=start_lumped2,
    stop=stop_lumped2,
    p_dir='z',
    excite=0
)




# sauvegarde le modèle dans un ficher xml 
CSX.Write2XML("microstrip.xml")
# lance le CAD pour afficher le modèle 
os.system("AppCSXCAD " + "microstrip.xml")
sim_path = os.path.join(os.getcwd(), "microstrip_simulation")
# lance la simulation et sauvegrade tout les fichiers dans un le dossier microstip_simulation
if not only_display :
    FDTD.Run(sim_path=sim_path)


# calcule affiche les résultats 
# Frequency vector 
f = np.linspace(f0-fc, f0+fc)

# Calculate S11
port1.CalcPort(sim_path, f)
s11 = port1.uf_ref / port1.uf_inc
s11_dB = 20*np.log10(np.abs(s11))

figure()
plot(f/1e9, s11_dB, 'k-', linewidth=2)
xlabel('Frequency (GHz)')
ylabel('S11 (dB)')
title('Reflection Coefficient S11')
#grid(True)
show()



# la simulation génère les fichiers suivants : 
# et qui représente les calculs du champ électrique 
# ht qui rempréssente les calculs du champ magnétique 
# port_it_x qui représente le courant dans le port x au cours du temps
# port_ut_x qui représente la tension dans le port x au cours du temps




