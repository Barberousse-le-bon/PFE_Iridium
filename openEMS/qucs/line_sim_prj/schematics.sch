<Qucs Schematic 0.0.19>
<Properties>
  <View=-93,0,1061,800,1,0,0>
  <Grid=10,10,1>
  <DataSet=schematics.dat>
  <DataDisplay=schematics.dpl>
  <OpenDisplay=1>
  <Script=schematics.m>
  <RunScript=0>
  <showFrame=0>
  <FrameText0=Titre>
  <FrameText1=Auteur :>
  <FrameText2=Date :>
  <FrameText3=Version :>
</Properties>
<Symbol>
</Symbol>
<Components>
  <GND * 1 40 150 0 0 0 0>
  <MLIN MS1 1 130 50 -26 15 0 0 "Subst1" 1 "2.9575 mm" 1 "40 mm" 1 "Hammerstad" 0 "Kirschning" 0 "26.85" 0>
  <Pac P1 1 40 120 -93 -26 0 3 "1" 1 "50 Ohm" 1 "0 dBm" 0 "1 GHz" 0 "26.85" 0>
  <Pac P2 1 300 80 -93 -26 0 3 "2" 1 "50 Ohm" 1 "0 dBm" 0 "1 GHz" 0 "26.85" 0>
  <.SP SP1 1 360 120 0 63 0 0 "lin" 1 "1 GHz" 1 "2.3 GHz" 1 "1000" 1 "no" 0 "1" 0 "2" 0 "no" 0 "no" 0>
  <Eqn Eqn1 1 710 340 -30 16 0 0 "dBS11=dB(S[1,1])" 1 "yes" 0>
  <SUBST Subst1 1 600 90 -30 24 0 0 "4.4" 1 "1.6 mm" 1 "30 um" 1 "perte" 1 "0.022e-6" 1 "0.15e-6" 1>
  <.SW SW1 1 440 370 0 63 0 0 "SP1" 1 "lin" 1 "perte" 1 "1e-6" 1 "0.1" 1 "20" 1>
  <GND * 1 260 170 0 0 0 0>
</Components>
<Wires>
  <40 50 40 90 "" 0 0 0 "">
  <40 50 100 50 "" 0 0 0 "">
  <160 50 300 50 "" 0 0 0 "">
  <260 110 300 110 "" 0 0 0 "">
  <260 110 260 170 "" 0 0 0 "">
</Wires>
<Diagrams>
  <Rect 70 450 240 160 3 #c0c0c0 1 00 1 1e+09 5e+08 3e+09 1 -0.00138832 0.01 0.0157241 1 -1 1 1 315 0 225 "" "" "">
	<"S[1,1]" #0000ff 0 3 0 0 0>
  </Rect>
</Diagrams>
<Paintings>
</Paintings>
