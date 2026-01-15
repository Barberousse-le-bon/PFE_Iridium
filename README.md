# Final year project

The goal of the project is to make a create a PCB archimedean spiral antenna used for intercept messages from the IRIDIUM satellite constellation to prove that satellites transmit messages to eachother to cover greater distances.

![3D model of the spiral using pyvista](/pictures/image_spirale.png)

## Current state

### Work done

- An example model of what the antenna should look like in the final state can be seen in the pyvisa folder using :
- The projet has berrn redefined and the objective is to make simpler things before :

  - Creating and validating a simple line (status: goal)
  - Creating and validating a simple patch (status: goal)
  - Creating and validating a one arm spiral (status: goal)

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

![3D model of the spiral using CSXCAD](/pictures/spiral_antenna_CSXCAD.png)

### Results of the tutorial

Here are the result using the youtube tutorial at :
[Youtube tutorial](https://youtu.be/SPlrcp-gCKk?si=wbu3DHEVbzqxzVoI)

![visual representation of the file with the stub](/pictures/stripline_of_the_tutorial.png)
![field distribution of a simple line with a stub ](/pictures/field_distribution.png)
![S11 and S21](/pictures/s11_and_s21.png)

### FDTD course

To uderstand better how the FDTD simulation method works, I followed the course of Loïc Le Cunff on youtube :

[Online video course](https://youtu.be/Rs8xp6A1qQo?si=FOTdidkYZpudTVB7)

### Model comparasion between QUCS and OpenEMS

A simple model of a microstrip has been made on openEMS.

![openEMS line model](/pictures/openEMS_microstrip.png)

And the equivalent model on QUCS :

![QUCS line model](/pictures/QUCS_microstrip.png)

Then here are the results given by both simulations :

![QUCS line simulation results](/pictures/QUCS_microstrip_result.png)
![OpenEMS line simulation results](/openEMS/Tutorials/tutorials_octave/microstrip_screen_save/wrong_s11.jpg)

#### Note

We notice a significant shift of the sharp part of the graph, this means there is probably someting wrong on the OpenEMS simulation. To inversigate futhermore, a sweep parameter simulation has been made on the tand paramter on QUCS. As seen on the graph, it only affect the Q factor, so this is not the issue. The boundaries conditions are not the issue. 

Other suspects are either too big yee cells our wrong ports placement. To verify this hypotheis, more simulations will be made.

we will compare a model of a notch filter between both software as there is already an example available on OpenEMS :

![OpenEMS notch filter model](/pictures/OpenEMS_notch_filter.png)

And its replica on QUCS :

![QUCS notch filter model](/pictures/QUCS_notch_filter.png)

The results are much closer than on the previous simulation :

![QUCS notch filter results](/pictures/QUCS_notch_filter_results.png)
![OpenEMS notch filter results](/openEMS/Tutorials/tutorials_octave/notch_filter_screen_save/notch_filter_results.png)

This time, except the Q factor being better on the OpenEMS simulation the results are much closer.

### Next step

Redo the microstrip line simulation with different placements of the ports and making sure the cells are small enough

## Tools used

### Programming and modelisation

- pyvista: for 3D modeling
- openEMS + CSXCAD: for EM simulation and testing
- octave: to run openEMS and CSXCAD

### Hardware

- RaspberryPi
- rtlSDR
- PlutoSDR
