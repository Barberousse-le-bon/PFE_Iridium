################################################################################
#                            CONSTANTS                                         #
################################################################################
f0 = 2e9;
fc = 3*10^9;    # corner frequ +- 3GHz
epsilon = 4.8;
substrate_width = 20;
substrate_length = 40;
substrate_height = 1;

z0 = 50; #ohm

# line width calculation

A = (z0/60)*sqrt((epsilon+1)/2)+((epsilon-1)/epsilon+1)*(0.23+0.11/epsilon);
B = (377*pi)/(z0*2*sqrt(epsilon));

wh = (8*exp(A))/(exp(2*A)-2)

if(wh < 2)
  wh = (2/pi)*((B-1-log(2*B-1))+(epsilon-1)/(2*epsilon)*(log(B-1)+0.39-(0.61/epsilon)))
endif;

line_width = wh*substrate_height
################################################################################
#                            CREATION OF THE MODEL                             #
################################################################################
# inti CSX cad structure

CSX = InitCSX();


# define materials

CSX = AddMetal(CSX, 'stripline');         # microstrip line material
CSX = AddMetal(CSX, 'ground');       # gnd line material
CSX = AddMaterial(CSX, 'substrate');  # substrate material
# Er = 4.8, permittivity
CSX = SetMaterialProperty(CSX, 'substrate', 'Epsilon', epsilon);


# define geometry
start_substrate = [-substrate_width/2,-substrate_length/2,-substrate_height];
stop_substrate = [substrate_width/2,substrate_length/2,0];
CSX = AddBox(CSX, 'substrate', 0, start_substrate, stop_substrate );

# add ground
start_gnd = [-substrate_width/2,-substrate_length/2,-substrate_height];
stop_gnd = [substrate_width/2,substrate_length/2,-substrate_height];
CSX = AddBox(CSX, 'ground', 0, start_gnd, stop_gnd );


# create line :






# Field dump for electromagnetic field visualization
start_field_box = [-substrate_width/2,-substrate_length/2,-substrate_height/2];
end_field_box = [substrate_width/2,substrate_length/2,-substrate_height/2];
#field in the middle of the substrate
CSX = AddDump(CSX,'E_field','FileType',1);
CSX = AddBox(CSX,'E_field',10,start_field_box, end_field_box);

################################################################################
#                            CAD ENVIRONMENT                                   #
################################################################################
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
################################################################################
#                            FDTD PARAMETERS                                   #
################################################################################


FDTD = InitFDTD('End_Criteria', 10^-4);
FDTD = SetGaussExcite(FDTD, f0, fc);
FDTD = SetBoundaryCond(FDTD, { 'MUR','MUR','MUR','MUR','MUR','MUR'});

# add two lumped ports
start_lumped1 = [-1.8/2,-substrate_length/2,-substrate_height];
stop_lumped1 = [1.8/2,-substrate_length/2,0];
[CSX port{1}] = AddLumpedPort(CSX, 1,1,50, start_lumped1, stop_lumped1,[0,0,1], true);

start_lumped2 = [-1.8/2,substrate_length/2,-substrate_height];
stop_lumped2 = [1.8/2,substrate_length/2,0];
[CSX port{2}] = AddLumpedPort(CSX, 1,2,50, start_lumped2, stop_lumped2,[0,0,1], false);


# save the file to uste it using openEMS


mkdir('stripline_simulation');
WriteOpenEMS('stripline_simulation/stripline.xml', FDTD, CSX);

# display  3D model

CSXGeomPlot('stripline_simulation/stripline.xml');
#comment above for not open the CAD




#uncomment below for not simulating,
return;
################################################################################
#                                 FDTD SIMULATION                              #
################################################################################

RunOpenEMS('stripline_simulation', 'stripline.xml');

# dispay results

close all % close existing graph windows if any
freq = linspace(f0-Fc, f0+Fc, 201);
port = calcPort(port, 'stripline_simulation', freq);
s11 = port{1}.uf.ref./port{1}.uf.inc;
s21 = port{2}.uf.ref./port{1}.uf.inc;

figure
hold on;
plot( freq/1e6, 20*log10(abs(s11)), 'r-');
plot( freq/1e6, 20*log10(abs(s21)), 'b-');
grid on
title({'Reflection Coefficients {\color{red}|S_{11}|} and {\color{blue}|S_{21}|}'});
xlabel('frequency f / MHz');
ylabel('Magnitude, dB');
ylim([-50 5]);


% draw electromagnetic field distribution
[myField myMesh] = ReadHDF5Dump(['temp' '/E_field.h5']);
myField2 = GetField_TD2FD(myField, F0);
sx=size(myField2.FD.values{1})(1);
sy=size(myField2.FD.values{1})(2);


figure;
hold on;

colormap('jet');
[xx,yy]=meshgrid(myMesh.lines{1},myMesh.lines{2});
cc=zeros(sy,sx);

for ii = 1:sx
  for kk = 1:sy
    fz = myField2.FD.values{1}(ii,kk,1,3);
    amp=abs(fz);
    cc(kk,ii)=sin(arg(fz))*abs(fz);
  endfor
endfor

ss=pcolor(xx,yy,cc);

set(ss,'FaceColor','interp','EdgeColor','none'); % replace 'none' with 'black' to view mesh

SCALE=1/1000; % to meters

% draw layout (metal layers)
metalN=size(CSX.Properties.Metal)(2);
for nn = 1:metalN
  primitives=CSX.Properties.Metal{1,nn}.Primitives.Box;
  primitivesN=size(primitives)(2);
  for tt= 1:primitivesN
    X1=primitives{1,tt}.P1.ATTRIBUTE.X;
    Y1=primitives{1,tt}.P1.ATTRIBUTE.Y;
    X2=primitives{1,tt}.P2.ATTRIBUTE.X;
    Y2=primitives{1,tt}.P2.ATTRIBUTE.Y;
    SX=X2-X1;
    SY=Y2-Y1;
    rectangle("Position", [X1*SCALE, Y1*SCALE, SX*SCALE, SY*SCALE], "EdgeColor", "black", "FaceColor", "none");
  endfor
endfor

title(sprintf("Ez field distribution @ %.2f GHz",F0/1e9));

X1=abs(CSX.Properties.Material{1,1}.Primitives.Box{1,1}.P1.ATTRIBUTE.X);
Y1=abs(CSX.Properties.Material{1,1}.Primitives.Box{1,1}.P1.ATTRIBUTE.Y);
X2=abs(CSX.Properties.Material{1,1}.Primitives.Box{1,1}.P2.ATTRIBUTE.X);
Y2=abs(CSX.Properties.Material{1,1}.Primitives.Box{1,1}.P2.ATTRIBUTE.Y);

% scale
DIM1=X1*SCALE;
DIM2=X2*SCALE;
DIM3=Y1*SCALE;
DIM4=Y2*SCALE;
DIM=max([DIM1,DIM2,DIM3,DIM4])*1.25; % leave 25% empty from the sides

disp(DIM)
axis ([-DIM, DIM, -DIM, DIM], "square");


