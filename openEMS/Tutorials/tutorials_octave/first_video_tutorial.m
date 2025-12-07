# inti CSX cad structure

CSX = InitCSX();

# define materials

CSX = AddMetal(CSX, 'my_line');         # microstrip line material
CSX = AddMetal(CSX, 'my_ground');       # gnd line material
CSX = AddMaterial(CSX, 'my_substrate');  # substrate material
# Er = 4.8, permittivity
CSX = SetMaterialProperty(CSX, 'my_substrate', 'Epsilon', 4.8);

# define geometry
start_substrate = [-10,-20,-1];
stop_substrate = [10,20,0];
CSX = AddBox(CSX, 'my_substrate', 0, start_substrate, stop_substrate );


# 50 ohm at 5.8 GHz is 18 mm wide
start_line = [-1.8/2,-20,0];
stop_line = [1.8/2,20,0];
CSX = AddBox(CSX, 'my_line', 0, start_line, stop_line );

# add ground
start_gnd = [-10,-20,-1];
stop_gnd = [10,20,-1];
CSX = AddBox(CSX, 'my_ground', 0, start_gnd, stop_gnd );

# set FDTD parameters

F0 = 5.8*10^9; # center freq = 5.8 GHz
Fc = 3*10^9;    # corner frequ +- 3GHz

FDTD = InitFDTD('End_Criteria', 10^-4);
FDTD = SetGaussExcite(FDTD, F0, Fc);
FDTD = SetBoundaryCond(FDTD, { 'MUR','MUR','MUR','MUR','MUR','MUR'});

# add two lumped ports
start_lumped1 = [-1.8/2,-20,-1];
stop_lumped1 = [1.8/2,-20,0];
[CSX Port{1}] = AddLumpedPort(CSX, 1,1,50, start_lumped1, stop_lumped1,[0,0,1], true);

start_lumped2 = [-1.8/2,20,-1];
stop_lumped2 = [1.8/2,20,0];
[CSX Port{2}] = AddLumpedPort(CSX, 1,2,50, start_lumped2, stop_lumped2,[0,0,1], false);
# slice 3D space using 2D planes through shape edges added with AddBox

mesh = DetectEdges(CSX);


# append mesh with empty space boundaries

mesh.x = [mesh.x, -25, 25]; # two YZ planes at 25 and -25
mesh.y = [mesh.y, -25, 25]; # two XZ planes at 25 and -25
mesh.z = [mesh.z, -15, 15]; # two XY planes at 25 and -25

# increase mesh resolution

mesh = SmoothMesh(mesh, 0.5, 1.25); # mesh, max res, ratio


# define rectangualr grid
# mesh is in millimeters
CSX = DefineRectGrid(CSX, 1/1000, mesh);


# save the file to uste it using openEMS


mkdir('temp');
WriteOpenEMS('temp/test.xml', FDTD, CSX);

# display  3D model

CSXGeomPlot('temp/test.xml');


# sumulation

RunOpenEMS('temp', 'test.xml');

# dispay results

set(0, "defaulttextfontsize", 24); #title
set(0, "defaultaxisfontsize", 16); #♠ axis labels
set(0, "defaultlinelinewidth", 1);

close all;

freq = linspace(F0-fc, F0+Fc, 201);
port = calcPort(port, 'temp', freq);
s11 = port{1}.uf.ref./ port{1}.uf.inc;
s21 = port{2}.uf.ref./ port{1}.uf.inc;


figure

hold on;


plot( freq/1e6, 20*log10(abs(s11)), 'r-');
plot( freq/1e6, 20*log10(abs(s21)), 'b-');
grid on

title({'reflection Coefficients {\color{red}|s_{11}|} and {color{blue}|s_{21}|}
