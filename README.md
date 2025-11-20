# Final year project

The goal of the project is to make a create a PCB archimedean spiral antenna used for intercept messages from the IRIDIUM satellite constellation to prove that satellites transmit messages to eachother to cover greater distances.

![3D model of the spiral using pyvista](image_spirale.png)

## Current state
### Work done
- An example model of what the antenna should look like in the final state can be seen in the pyvisa folder using :

```bash

pyhton3 spiral_antenna_pyvista.py

```


- The CAD using CSXCAD is done and can be seen in openEMS/simulation folder and run by using : 

```bash

python3 spiral_patch.py

```

or 

```bash 

AppCSXCAD patch_antenna.xml 

```
![3D model of the spiral using CSXCAD](spiral_antenna_CSXCAD.png)

### Next step

Adding the EMS simulation for the CSXCAD model 
## Tools used

### Programming and modelisation

- pyvista : for 3D modeling
- openEMS + CSXCAD: for EM simulation and testing

### Hardware

- RaspberryPi
- rtlSDR
- PlutoSDR
- CNC  
