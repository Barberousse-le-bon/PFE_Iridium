<Qucs Schematic 0.0.19>
<Properties>
  <View=0,-220,1167,710,1,0,0>
  <Grid=10,10,1>
  <DataSet=schem_notvh_filter.dat>
  <DataDisplay=schem_notvh_filter.dpl>
  <OpenDisplay=1>
  <Script=schem_notvh_filter.m>
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
  <Pac P1 1 80 270 18 -26 0 1 "1" 1 "50 Ohm" 1 "0 dBm" 0 "1 GHz" 0 "26.85" 0>
  <Pac P2 1 510 270 18 -26 0 1 "2" 1 "50 Ohm" 1 "0 dBm" 0 "1 GHz" 0 "26.85" 0>
  <MTEE MS1 1 270 180 -26 -110 1 2 "Subst1" 1 "600um" 1 "600um" 1 "600um" 1 "Hammerstad" 0 "Kirschning" 0 "26.85" 0 "showNumbers" 0>
  <MOPEN MS5 1 310 400 -26 15 0 0 "Subst1" 1 "600 um" 1 "Hammerstad" 0 "Kirschning" 0 "Kirschning" 0>
  <MLIN MS2 1 160 180 -26 15 0 0 "Subst1" 1 "600um" 1 "50000 um" 1 "Hammerstad" 0 "Kirschning" 0 "26.85" 0>
  <MLIN MS3 1 390 180 -26 15 0 0 "Subst1" 1 "600um" 1 "50000um" 1 "Hammerstad" 0 "Kirschning" 0 "26.85" 0>
  <MLIN MS4 1 270 300 15 -26 0 1 "Subst1" 1 "600um" 1 "12000um" 1 "Hammerstad" 0 "Kirschning" 0 "26.85" 0>
  <GND * 1 510 300 0 0 0 0>
  <GND * 1 80 300 0 0 0 0>
  <.SP SP1 1 860 20 0 63 0 0 "lin" 1 "0 GHz" 1 "7 GHz" 1 "70001" 1 "no" 0 "1" 0 "2" 0 "no" 0 "no" 0>
  <SUBST Subst1 1 650 190 -30 24 0 0 "3.66" 1 "254 um" 1 "0" 1 "2e-4" 1 "0.022e-6" 1 "0.15e-6" 1>
  <Eqn Eqn1 1 700 -130 -30 16 0 0 "DBS11=dB(S[1,1])" 1 "yes" 0>
  <Eqn Eqn2 1 900 -130 -30 16 0 0 "DBs21=dB(S[2,1])" 1 "yes" 0>
</Components>
<Wires>
  <190 180 240 180 "" 0 0 0 "">
  <300 180 360 180 "" 0 0 0 "">
  <270 210 270 270 "" 0 0 0 "">
  <80 180 80 240 "" 0 0 0 "">
  <80 180 130 180 "" 0 0 0 "">
  <420 180 510 180 "" 0 0 0 "">
  <510 180 510 240 "" 0 0 0 "">
  <270 330 270 370 "" 0 0 0 "">
  <280 370 280 400 "" 0 0 0 "">
  <270 370 280 370 "" 0 0 0 "">
</Wires>
<Diagrams>
  <Rect 880 400 240 160 3 #c0c0c0 1 00 1 0 0.2 1 1 -0.1 0.5 1.1 1 -0.1 0.5 1.1 315 0 225 "" "" "">
	<"S[1,1]" #0000ff 0 3 0 0 0>
	<"S[2,1]" #ff0000 0 3 0 0 0>
  </Rect>
  <Tab 270 30 300 200 3 #c0c0c0 1 00 1 0 1 1 1 0 1 1 1 0 1 70001 315 0 225 "" "" "">
	<"S[1,1]" #0000ff 0 3 1 0 0>
  </Tab>
</Diagrams>
<Paintings>
</Paintings>
