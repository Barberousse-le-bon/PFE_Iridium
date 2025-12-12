% OpenEMS FDTD Analysis Automation Script
%
% To be run with GNU Octave or MATLAB.
% FreeCAD to OpenEMS plugin by Lubomir Jagos, 
% see https://github.com/LubomirJagos/FreeCAD-OpenEMS-Export
%
% This file has been automatically generated. Manual changes may be overwritten.
%

close all
clear
clc

%% Change the current folder to the folder of this m-file.
if(~isdeployed)
  mfile_name          = mfilename('fullpath');
  [pathstr,name,ext]  = fileparts(mfile_name);
  cd(pathstr);
end

%% constants
physical_constants;
unit    = 0.001; % Model coordinates and lengths will be specified in mm.
fc_unit = 0.001; % STL files are exported in FreeCAD standard units (mm).

%% switches & options
postprocessing_only = 0;
draw_3d_pattern = 0; % this may take a while...
use_pml = 0;         % use pml boundaries instead of mur

currDir = strrep(pwd(), '\', '\\');
display(currDir);

% --no-simulation : dry run to view geometry, validate settings, no FDTD computations
% --debug-PEC     : generated PEC skeleton (use ParaView to inspect)
openEMS_opts = '';

%% prepare simulation folder
Sim_Path = 'simulation_output';
Sim_CSX = '.xml';
[status, message, messageid] = rmdir( Sim_Path, 's' ); % clear previous directory
[status, message, messageid] = mkdir( Sim_Path ); % create empty simulation folder

%% setup FDTD parameter & excitation function
max_timesteps = 1000000;
min_decrement = 0.01; % 10*log10(min_decrement) dB  (i.e. 1E-5 means -50 dB)
FDTD = InitFDTD( 'NrTS', max_timesteps, 'EndCriteria', min_decrement);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BOUNDARY CONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BC = {"PML_8","PML_8","PML_8","PML_8","PML_8","PML_8"};
FDTD = SetBoundaryCond( FDTD, BC );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COORDINATE SYSTEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSX = InitCSX('CoordSystem', 0); % Cartesian coordinate system.
mesh.x = []; % mesh variable initialization (Note: x y z implies type Cartesian).
mesh.y = [];
mesh.z = [];
CSX = DefineRectGrid(CSX, unit, mesh); % First call with empty mesh to set deltaUnit attribute.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXCITATION gauss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f0 = 1.0*1000000000.0;
fc = 0.01*1000000000.0;
FDTD = SetGaussExcite( FDTD, f0, fc );
max_res = c0 / (f0 + fc) / 20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATERIALS AND GEOMETRY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSX = AddMetal( CSX, 'PEC' );

%% MATERIAL - PEC
CSX = AddMetal(CSX, 'PEC');
CSX = ImportSTL(CSX, 'PEC', 9800, [currDir '/gnd_gen_model.stl'], 'Transform', {'Scale', fc_unit/unit});

%% MATERIAL - copper
CSX = AddMetal(CSX, 'copper');
CSX = ImportSTL(CSX, 'copper', 9900, [currDir '/trace_gen_model.stl'], 'Transform', {'Scale', fc_unit/unit});

%% MATERIAL - air
CSX = AddMaterial(CSX, 'air');
CSX = SetMaterialProperty(CSX, 'air', 'Epsilon', 1.0, 'Mue', 1.0, 'Kappa', 0.0, 'Sigma', 0.0);
CSX = ImportSTL(CSX, 'air', 9600, [currDir '/air_gen_model.stl'], 'Transform', {'Scale', fc_unit/unit});

%% MATERIAL - fr4
CSX = AddMaterial(CSX, 'fr4');
CSX = SetMaterialProperty(CSX, 'fr4', 'Epsilon', 4.6, 'Mue', 1.0, 'Kappa', 0.0, 'Sigma', 0.0);
CSX = ImportSTL(CSX, 'fr4', 9700, [currDir '/pcb_gen_model.stl'], 'Transform', {'Scale', fc_unit/unit});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRID LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% GRID - xyz - air (Fixed Distance)
mesh.x(mesh.x >= -11 & mesh.x <= 14) = [];
mesh.x = [ mesh.x (-11:0.1:14) ];
mesh.y(mesh.y >= -13 & mesh.y <= 12) = [];
mesh.y = [ mesh.y (-13:0.1:12) ];
mesh.z(mesh.z >= -5 & mesh.z <= 5) = [];
mesh.z = [ mesh.z (-5:0.1:5) ];
CSX = DefineRectGrid(CSX, unit, mesh);

%% GRID - fine_xy - trace (Fixed Distance)
mesh.x(mesh.x >= -6.5 & mesh.x <= 6.5) = [];
mesh.x = [ mesh.x (-6.5:0.05:6.5) ];
mesh.y(mesh.y >= -0.5 & mesh.y <= 7.325) = [];
mesh.y = [ mesh.y (-0.5:0.05:7.325) ];
CSX = DefineRectGrid(CSX, unit, mesh);

%% GRID - fine_z - h_field (Fixed Count)
mesh.z(mesh.z >= 0.9 & mesh.z <= 0.95) = [];
mesh.z = [ mesh.z linspace(0.9,0.95,3) ];
CSX = DefineRectGrid(CSX, unit, mesh);

%% GRID - fine_z - e_field (Fixed Count)
mesh.z(mesh.z >= 1 & mesh.z <= 1.05) = [];
mesh.z = [ mesh.z linspace(1,1.05,3) ];
CSX = DefineRectGrid(CSX, unit, mesh);

%% GRID - fine_z - gnd (Fixed Count)
mesh.z(mesh.z >= -0.05 & mesh.z <= 0) = [];
mesh.z = [ mesh.z linspace(-0.05,0,3) ];
CSX = DefineRectGrid(CSX, unit, mesh);

%% GRID - fine_z - trace (Fixed Count)
mesh.z(mesh.z >= 1.6 & mesh.z <= 1.65) = [];
mesh.z = [ mesh.z linspace(1.6,1.65,3) ];
CSX = DefineRectGrid(CSX, unit, mesh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PORTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
portNamesAndNumbersList = containers.Map();

%% PORT -  - port_in
portStart = [ -6.5, -0.5, -0.05 ];
portStop  = [ -5.5, 0.5, 1.65 ];
portR = 50.0;
portUnits = 1;
portExcitationAmplitude = 1000.0;
portDirection = [0 0 1]*portExcitationAmplitude;
[CSX port{1}] = AddLumpedPort(CSX, 10000, 1, portR*portUnits, portStart, portStop, portDirection, true);
portNamesAndNumbersList("port_in") = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROBES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROBE - e_field_probe - e_field
CSX = AddDump(CSX, 'e_field_probe_e_field', 'DumpType', 0, 'DumpMode', 2);
dumpboxStart = [ -11, -13, 1 ];
dumpboxStop  = [ 14, 12, 1.05 ];
CSX = AddBox(CSX, 'e_field_probe_e_field', 0, dumpboxStart, dumpboxStop );

%% PROBE - h_field_probe - h_field
CSX = AddDump(CSX, 'h_field_probe_h_field', 'DumpType', 1, 'DumpMode', 2);
dumpboxStart = [ -11, -13, 0.9 ];
dumpboxStop  = [ 14, 12, 0.95 ];
CSX = AddBox(CSX, 'h_field_probe_h_field', 0, dumpboxStart, dumpboxStop );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WriteOpenEMS( [Sim_Path '/' Sim_CSX], FDTD, CSX );
CSXGeomPlot( [Sim_Path '/' Sim_CSX] );

if (postprocessing_only==0)
    %% run openEMS
    RunOpenEMS( Sim_Path, Sim_CSX, openEMS_opts );
end
