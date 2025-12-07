% Copyright 2024 by Georgy Moshkin <georgy.moshkin@outlook.com>
%
% Proprietary and confidential.
% To use contents of this file, you need to purchase a license.
% THE CONTENTS ARE PROVIDED "AS IS", WITH NO WARRANTIES OR INDEMNITIES.


% 1. Init "CSX" 3D CAD data structure
CSX = InitCSX();

% 2. Define materials
CSX = AddMetal(CSX, 'my_line');
CSX = AddMetal(CSX, 'my_ground');
CSX = AddMaterial(CSX, 'my_substrate');
CSX = SetMaterialProperty( CSX, 'my_substrate', 'Epsilon', 4.8); % Er = 4.8 for substrate

% 3. Define geometry
% AddBox(CSX, property_name, priority, [x1 y1 z1], [x2 y2 z2])
CSX = AddBox(CSX, 'my_substrate', 0, [-10 -20 -1], [10 20 0]); % z1=-1, substrate thickness is 1 mm
CSX = AddBox(CSX, 'my_ground', 1, [-10 -20 -1], [10 20 -1]);   % z1=z2=-1, because of zero thickness
CSX = AddBox(CSX, 'my_line', 1, [-1.8/2 -20 0], [1.8/2 20 0]); % z1=z2=0, because of zero thickness
#CSX = AddBox(CSX, 'my_line', 1, [1.8/2 -1.8/2 0], [6.7 1.8/2 0]);  % quarterwave stub

% Field dump for electromagnetic field visualization
CSX = AddDump(CSX,'E_field','FileType',1);
CSX = AddBox(CSX,'E_field',10,[-10 -20 -0.5], [10 20 -0.5]); % -0.5mm is inside substrate

# 4. Add two lumped ports
% ( CSX, priority, port_number, R, [x1 y1 z1], [x2 y2 z2], [nx ny nz], excitation)
% For both ports impedance is set to R = 50 Ohm
% For port {2}, we set port_number = 2, Y coordinate to 20 mm and "excitation" to false
[CSX port{1}] = AddLumpedPort(CSX, 1, 1, 50, [-1.8/2 -20 -1], [1.8/2 -20 0], [0 0 1], true);
[CSX port{2}] = AddLumpedPort(CSX, 1, 2, 50, [-1.8/2 20 -1], [1.8/2 20 0], [0 0 1], false);

% 5. Slice 3D space using 2D planes through shape edges added using AddBox() function
% It creates a very rough mesh that is not sufficient for correct simulation
% Mesh contains array of coordinates of 2D planes (XY, XZ, YZ)
% Not going to use "1/3" meshing rule in this example for simplicity!
mesh = DetectEdges(CSX);

% 6. Append mesh with surrounding empty space boundary coordinates
% appending principle: mesh.x already contains array of X coordinates
% filled by DetectEdges() function.
% Assume that mesh.x contains 3-element array [1 2 3]
% Then mesh.x = [mesh.x 4 5] creates a new array [1 2 3 4 5] with two new elements [4 5]
mesh.x = [mesh.x -25 25]; % two YZ planes at X=-25 and X=25
mesh.y = [mesh.y -25 25]; % two XZ planes at Y=-25 and Y=25
mesh.z = [mesh.z -15 15]; % two XY planes at Z=-15 and Z=15

% 7. Smooth rough mesh
% Basically subdivides space by more 2D planes in a such way
% that distance between adjacent planes is not larger than "max_res",
% and distance ratio between adjacent planes doesn't exceed "ratio"
mesh = SmoothMesh(mesh, 0.5, 1.25); % (mesh, max_res, ratio)

% 8. Define rectangular grid
% Note that "mesh" was filled with coordinates in millimeters
% We use deltaUnit=1/1000 to convert this to meters, because
% this is standard unit which used in FDTD calculation formulas.
CSX = DefineRectGrid(CSX, 1/1000, mesh); % (CSX, deltaUnit, mesh)

% 9. Set parameters used by FDTD algorithm
% Excitation pulse at F0 = 5.8 GHz with FC = 3 GHz
% Later, math is used to extract frequency-domain simulation
% results based on excitation pulse parameters.
F0 = 5.8*10^9; % center frequency
FC = 3*10^9; % corner frequency
FDTD = InitFDTD('EndCriteria', 10^-4);
FDTD = SetGaussExcite(FDTD, F0, FC); % (FDTD, F0, FC)
FDTD = SetBoundaryCond(FDTD, {'MUR' 'MUR' 'MUR' 'MUR' 'MUR' 'MUR'}); % Faster than PML_8

% 10. Write CSX CAD data structure to XML file
% This file includes all parameters we have eneterd and generated above
mkdir('temp'); % create temporary directory
WriteOpenEMS('temp/test.xml', FDTD, CSX);

% 11. Show 3D model of CSX CAD data structure
% Runs AppCSXCAD.exe to preview "test.xml" 3D model
% AppCSXCAD.exe resides in openEMS directory
CSXGeomPlot('temp/test.xml');

% 12. Run FDTD simulation
% Runs openEMS.exe which initializes FDTD arrays according to test.xml data
% and runs FDTD loop
RunOpenEMS( 'temp', 'test.xml'); % (path, file_name)

% 13. Process and display FDTD output
% In previous step, openEMS.exe saved FDTD loop calculation results in
% temporary directory. This data is opened, processed and dispayed in format
% of various graphs.

set(0, "defaulttextfontsize", 24)  % title
set(0, "defaultaxesfontsize", 16)  % axes labels
set(0, "defaultlinelinewidth", 1)

close all % close existing graph windows if any
freq = linspace(F0-FC, F0+FC, 201);
port = calcPort(port, 'temp', freq);
s11 = port{1}.uf.ref./port{1}.uf.inc;
s21 = port{2}.uf.ref./port{1}.uf.inc;

figure
hold on;
plot( freq/1e6, 20*log10(abs(s11)), 'r-');
plot( freq/1e6, 20*log10(abs(s21)), 'b-');
grid on
title({'Reflection Coefficients {\color{red}|S_{11}|} and {\color{blue}|S_{21}|}','Copyright 2024 by Georgy Moshkin'});
xlabel('frequency f / MHz');
ylabel('Magnitude, dB');
ylim([-50 5]);

%{
figure
plot( freq/1e6, 20*log10(abs(s21)), 'k-');
grid on
title( 'reflection coefficient S_{21}' );
xlabel( 'frequency f / MHz' );
ylabel( 'reflection coefficient |S_{21}|' );
ylim([-50 5]);
%}

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

title(sprintf("Ez field distribution @ %.2f GHz, \nCopyright 2024 by Georgy Moshkin",F0/1e9));

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

