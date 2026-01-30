################################################################################
#                            CONSTANTS                                         #
################################################################################
clear all;
close all;

only_display = 0;  # mettre à 1 pour afficher simplement les résultats sans relancer la simulation
foldername = 'microstrip_simulation'

f0 = 2e9;
fc = f0/2;    # corner frequ
epsilon = 4.4;
substrate_width = 20;
substrate_length = 40;
substrate_height = 1.6;
trace_thikness = 0.030;
z0 = 50; #ohm
c = 3e11; # mm/s

# line calculations

line_width = ((7.48*substrate_height)/exp(z0*(sqrt(epsilon+1.41)/87)))-1.25*trace_thikness



resolution = c/((f0+fc)*sqrt(epsilon))/20



################################################################################
#                            CREATION OF THE MODEL                             #
################################################################################
# init CSX cad structure

CSX = InitCSX();


# define materials

CSX = AddMetal(CSX, 'microstrip');         # microstrip line material
CSX = AddMetal(CSX, 'ground');       # gnd line material
CSX = AddMaterial(CSX, 'substrate');  # substrate material
CSX = SetMaterialProperty(CSX, 'substrate', 'Epsilon', epsilon);


# define geometry
start_substrate = [-substrate_width/2,-substrate_length/2,-substrate_height];
stop_substrate = [substrate_width/2,substrate_length/2,0];
CSX = AddBox(CSX, 'substrate', 0, start_substrate, stop_substrate );

# add ground
start_gnd = [-substrate_width/2,-substrate_length/2,-substrate_height];
stop_gnd = [substrate_width/2,substrate_length/2,-substrate_height-trace_thikness];
CSX = AddBox(CSX, 'ground', 0, start_gnd, stop_gnd );


# create line :
start_line = [-line_width/2, -substrate_length/2, 0];
stop_line = [line_width/2, substrate_length/2, trace_thikness];
CSX = AddBox(CSX, 'microstrip', 0, start_line, stop_line );



################################################################################
#                            CAD ENVIRONMENT                                   #
################################################################################
# slice 3D space using 2D planes through shape edges added with AddBox

mesh = DetectEdges(CSX);


# append mesh with empty space boundaries

mesh.x = [mesh.x, -substrate_width, substrate_width]; # two YZ planes at 25 and -25
mesh.y = [mesh.y, -substrate_length, substrate_length]; # two XZ planes at 25 and -25
mesh.z = [mesh.z, -substrate_height-10, substrate_height+10]; # two XY planes at 25 and -25

# increase mesh resolution

mesh = SmoothMesh(mesh, resolution, 1.25); # mesh, max res, ratio


# define rectangualr grid
# mesh is in millimeters
CSX = DefineRectGrid(CSX, 1/1000, mesh);
################################################################################
#                            FDTD PARAMETERS                                   #
################################################################################


FDTD = InitFDTD('End_Criteria', 10^-4);
FDTD = SetGaussExcite(FDTD, f0, fc);
FDTD = SetBoundaryCond(FDTD, {'PML_8' 'PML_8' 'MUR' 'MUR' 'PEC' 'MUR'});

# add two lumped ports
start_lumped1 = [-line_width/2,-substrate_length/2,-substrate_height-trace_thikness];
stop_lumped1 = [line_width/2,-substrate_length/2,trace_thikness];
[CSX port{1}] = AddLumpedPort(CSX, 1,1,50, start_lumped1, stop_lumped1,[0,0,1], true);

start_lumped2 = [-line_width/2,substrate_length/2,-substrate_height-trace_thikness];
stop_lumped2 = [line_width/2,substrate_length/2,trace_thikness];
[CSX port{2}] = AddLumpedPort(CSX, 1,2,50, start_lumped2, stop_lumped2,[0,0,1], false);


# save the file to uste it using openEMS


mkdir(foldername);
WriteOpenEMS('microstrip_simulation/microstrip.xml', FDTD, CSX);

# display  3D model

CSXGeomPlot('microstrip_simulation/microstrip.xml');
#comment above for not open the CAD
#uncomment below for not simulating,
#return;
################################################################################
#                                 FDTD SIMULATION                              #
################################################################################

if(only_display ==0 )
  RunOpenEMS(foldername, 'microstrip.xml');
endif;
# dispay results

close all % close existing graph windows if any
freq = linspace(f0-fc, f0+fc, 201);
port = calcPort(port, foldername, freq);
s11 = port{1}.uf.ref./port{1}.uf.inc;
s21 = port{2}.uf.ref./port{1}.uf.inc;

figure
hold on;
plot( freq/1e6, 20*log10(abs(s11)), 'r-');
#plot( freq/1e6, 20*log10(abs(s21)), 'b-');
grid on
title({'Reflection Coefficients {\color{red}|S_{11}|}'});
xlabel('frequency f / MHz');
ylabel('Magnitude, dB');
#ylim([-50 5]);

