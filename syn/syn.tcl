# Setting paths
set LIB_PATH_TECH "/pri/abal/V_Unit/synth_lib/tcbn55lpbwp7t/200b/liberty"
set TARGET_LIBRARY_FILES " $LIB_PATH_TECH/tcbn55lpbwp7t_1V0SS-40C.db"
set TARGET_LIBRARY_FILES_TYP [subst {$LIB_PATH_TECH/tcbn55lpbwp7t_1V0TT25C.db}]
set MIN_LIBRARY_FILES             " \
  $LIB_PATH_TECH/tcbn55lpbwp7t_1V0SS-40C.db \
  $LIB_PATH_TECH/tcbn55lpbwp7t_1V32FF-40C.db \
  " 
# set MAP_FILE "/n/library/tsmc/55n/libraries/tcbn55lpbwp7t/200b/milkyway/tcbn55lpbwp7t_200a/techfiles/tluplus/star.map_5M"  ;#  Mapping file for TLUplus
# set TLUPLUS_MAX_FILE "/n/library/tsmc/55n/libraries/tcbn55lpbwp7t/200b/milkyway/tcbn55lpbwp7t_200a/techfiles/tluplus/cln55lp_1p05m_and_28k_alrdl_3x1z_cworst.tluplus"  ;#  Max TLUplus file
# set TLUPLUS_MIN_FILE "/n/library/tsmc/55n/libraries/tcbn55lpbwp7t/200b/milkyway/tcbn55lpbwp7t_200a/techfiles/tluplus/cln55lp_1p05m_and_28k_alrdl_3x1z_rcbest.tluplus"  ;#  Min TLUplus file

# set rtl_path "../rtl"
# set ADDITIONAL_SEARCH_PATH "$rtl_path"
set constraints_file cons.tcl
set REPORTS_DIR "/pri/abal/V_Unit/vicuna/syn/reports"
set RESULTS_DIR "/pri/abal/V_Unit/vicuna/syn/results"

# Set synthesis Target
# set DESIGN_NAME $1
set DESIGN_NAME vicunas_datapath

# Set the target library and technology
set_app_var target_library ${TARGET_LIBRARY_FILES}
set_app_var synthetic_library dw_foundation.sldb
set_app_var link_library "* $target_library $synthetic_library"
foreach {max_library min_library} $MIN_LIBRARY_FILES {
    set_min_library $max_library -min_version $min_library
}
# These seem to be used when DC flow is coupled with ICC (DC does initial floorplan)
# set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE \
#                        -min_tluplus $TLUPLUS_MIN_FILE \
#                        -tech2itf_map $MAP_FILE

# Set the input SystemVerilog files
set RTL_SOURCE_FILES {
    "../rtl/vproc_pkg.sv"
    "../rtl/vproc_config.sv"
    "synth_wrappers/synth_pkg.sv"
    "../rtl/vproc_alu.sv"
    "../rtl/vproc_mul_block.sv"
    "../rtl/vproc_mul.sv"
    "../rtl/vproc_sld.sv"
    "../rtl/vproc_elem.sv"
    "ara-div/lzc.sv"
    "ara-div/serdiv.sv"
    "ara-div/simd_div.sv"
    "synth_wrappers/alu_wrapper.sv"
    "synth_wrappers/vicunas_datapath.sv"
}
# set_app_var search_path "${ADDITIONAL_SEARCH_PATH}"

# Analyze the design
define_design_lib WORK -path ./WORK
analyze -format sverilog $RTL_SOURCE_FILES

# Elaborate the design
elaborate $DESIGN_NAME

# Specify any constraints
source  -echo -verbose ${constraints_file}

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants


# Link the design
link

# Check the current design for consistency
check_design -summary
check_design > ${REPORTS_DIR}/${DESIGN_NAME}.check_design.rpt

# Compile the design
compile_ultra -gate_clock -no_seq_output_inversion -no_autoungroup

#################################################################################
# High-effort area optimization
#The command improves area without degrading timing or leakage. 
#################################################################################
# optimize_netlist -area

# Save the synthesized design
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output ${RESULTS_DIR}/${DESIGN_NAME}.v
write -format ddc     -hierarchy -output ${RESULTS_DIR}/${DESIGN_NAME}.ddc
write_sdc -nosplit ${RESULTS_DIR}/${DESIGN_NAME}.sdc


# Generate reports
report_qor > ${REPORTS_DIR}/${DESIGN_NAME}.qor.rpt
report_timing -transition_time -nets -attributes -nosplit -max_paths 50 > ${REPORTS_DIR}/${DESIGN_NAME}.timing.rpt
report_area -nosplit > ${REPORTS_DIR}/${DESIGN_NAME}.area.rpt
report_area -hier > ${REPORTS_DIR}/${DESIGN_NAME}.area_hier.rpt
report_power -nosplit > ${REPORTS_DIR}/${DESIGN_NAME}.power.rpt


# Exit Design Compiler
exit
