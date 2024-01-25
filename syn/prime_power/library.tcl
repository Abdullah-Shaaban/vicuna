
set lib_folders "\
${LIB_PATH_TECH}/ICE22N_9T_20H_S2 \
${LIB_PATH_TECH}/ICE22N_9T_28H_S2 \
${LIB_PATH_TECH}/ICE22N_9T_32H_S2 \
${LIB_PATH_TECH}/ICE22N_9T_36H_S2 \
${LIB_PATH_TECH}/ICE22N_9T_32H_L101 \
${LIB_PATH_TECH}/ICE22N_9T_32H_S301 \
${LIB_PATH_TECH}/ICE22N_9T_28UH_S1 \
${LIB_PATH_TECH}/ICE22N_9T_32UH_S1 \
${LIB_PATH_TECH}/ICE22N_9T_36UH_S1 \
${LIB_PATH_TECH}/ICE22N_9T_32HUH_S53 \
${LIB_PATH_TECH}/ICE22N_9T_32UH_S52"

set liberty_paths  {}
set all_milkyway_paths {}
foreach folder ${lib_folders} {
  lappend liberty_paths  [glob -nocomplain ${folder}/liberty]
  lappend all_milkyway_paths [glob -nocomplain ${folder}/milkyway/9M_2Mx_3Cx_2Bx_1Ix_1Ox_LB/*/*]
  lappend all_milkyway_paths [glob -nocomplain ${folder}/milkyway/*/9M_2Mx_3Cx_2Bx_1Ix_1Ox_LB/*]
  lappend all_milkyway_paths [glob -nocomplain ${folder}/milkyway/*]
}
set all_milkyway_paths [lminus ${all_milkyway_paths} {{}}]

#
# NOTE: different library naming style for Invecas and Nordic libraries.
switch ${LIB_SET} {
  SC9T_UH { 
    switch ${NOM_VOLTAGE} {
	0P65V {set synth_voltage 0V65}
	0P80V {set synth_voltage 0V8}
  	  default {puts "Error:  NOM_VOLTAGE NOT SET TO ALLOWED VALUE"; exit}
    }
    set mess "9T UHVT libaries chosen for synthesis. Nominal Voltage ${NOM_VOLTAGE} synthesis voltage ${synth_voltage}"
    set mess_length [string length ${mess}]
    puts "[string repeat # ${mess_length}]\n${mess}\n[string repeat # ${mess_length}]"

    set synth_hinst HINST_GF22FDX_SC9T_116CPP_UHVT
    set synth_corner PW0V0_NW0V0_${synth_voltage}TT25C
    set max_tim_library ICE22N_9T_28UH_S1_${synth_corner}
    set synth_libraries "ICE22N_9T_28UH_S1_${synth_corner}.ccs.db ICE22N_9T_32UH_S1_${synth_corner}.ccs.db ICE22N_9T_36UH_S1_${synth_corner}.ccs.db ICE22N_9T_32UH_S52_${synth_corner}.ccs.db "

    set milkyway_paths {}
    foreach m_path ${all_milkyway_paths} {
      if {[regexp ICE22N_9T ${m_path}]} {
        lappend milkyway_paths ${m_path}
      }
    }
  }
  SC9T_H { 
    switch ${NOM_VOLTAGE} {
	0P80V {set synth_voltage 0V8}
  	  default {puts "Error:  NOM_VOLTAGE NOT SET TO ALLOWED VALUE"; exit}
    }
    set mess "9T HVT libaries chosen for synthesis. Nominal Voltage ${NOM_VOLTAGE} synthesis voltage ${synth_voltage}"
    set mess_length [string length ${mess}]
    puts "[string repeat # ${mess_length}]\n${mess}\n[string repeat # ${mess_length}]"

    set synth_hinst HINST_GF22FDX_SC9T_116CPP_HVT
    set synth_corner PW0V0_NW0V0_${synth_voltage}TT25C
    set max_tim_library ICE22N_9T_28H_S2_${synth_corner}
    set synth_libraries "ICE22N_9T_28H_S2_${synth_corner}.ccs.db ICE22N_9T_32H_S2_${synth_corner}.ccs.db ICE22N_9T_36H_S2_${synth_corner}.ccs.db ICE22N_9T_32H_S301_${synth_corner}.ccs.db ICE22N_9T_32HUH_S53_${synth_corner}.ccs.db "

    set milkyway_paths {}
    foreach m_path ${all_milkyway_paths} {
	if {[regexp ICE22N_9T ${m_path}]} {
        lappend milkyway_paths ${m_path}
      }
    }
  }


  default {
    puts "Error:  NO LIBRARY SET CHOSEN";exit
  }
}

