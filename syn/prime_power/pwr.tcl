#################################################################################
# PrimePower Reference Methodology Script
# Script: pwr.tcl
# Version: O-2018.06 (Jul 17, 2018)
# Copyright (C) 2008-2018 Synopsys All rights reserved.
################################################################################




# Please do not modify the sdir variable.
# Doing so may cause script to fail.
set sdir "." 



##################################################################
#    Source common and pwr_setup.tcl File                         #
##################################################################

source $sdir/rm_setup/common_setup.tcl
source $sdir/rm_setup/pwr_setup.tcl


# make REPORTS_DIR
file mkdir $REPORTS_DIR

# make RESULTS_DIR
file mkdir $RESULTS_DIR 



##################################################################
#    Search Path, Library and Operating Condition Section        #
##################################################################

# Under normal circumstances, when executing a script with source, Tcl
# errors (syntax and semantic) cause the execution of the script to terminate.
# Uncomment the following line to set sh_continue_on_error to true to allow 
# processing to continue when errors occur.
#set sh_continue_on_error true 


# Enabling CCS-based waveform propagation. This variable needs to be set before link_design.
# CCS waveform analysis requires libraries that contain CCS timing and CCS noise data. 
# Please make sure the libraries have passed check_library checks in Library Compiler.  
set delay_calc_waveform_analysis_mode  full_design
  
set power_enable_timing_analysis true 
set power_enable_multi_rail_analysis true 
if {[string equal [getenv "ANALYSIS_MODE"] "timebased"]} {
        set power_analysis_mode time_based
} else {
        set power_analysis_mode averaged
}

set report_default_significant_digits 3 ;
set sh_source_uses_search_path true ;
set search_path ". $search_path" ;


##################################################################
#    Netlist Reading Section                                     #
##################################################################
set link_path "* $link_path"
read_verilog $NETLIST_FILES

current_design $DESIGN_NAME 
link


##################################################################
#    Back Annotation Section                                     #
##################################################################
if { [info exists PARASITIC_PATHS] && [info exists PARASITIC_FILES] } {
foreach para_path $PARASITIC_PATHS para_file $PARASITIC_FILES {
   if {[string compare $para_path $DESIGN_NAME] == 0} {
      read_parasitics $para_file 
   } else {
      read_parasitics -path $para_path $para_file 
   }
}
}



##################################################################
#    Reading Constraints Section                                 #
##################################################################
if  {[info exists CONSTRAINT_FILES]} {
        foreach constraint_file $CONSTRAINT_FILES {
                if {[file extension $constraint_file] eq ".sdc"} {
                        ;# NOTE: when using sdc, make sure the same library set is used both in synthesis and here, as libraries are part of the sdc file
                        read_sdc -echo $constraint_file >> ${REPORTS_DIR}/read_constraints.report 
                } else {
                        source -echo $constraint_file
                }
        }
}





##################################################################
#    Update_timing and check_timing Section                      #
##################################################################

update_timing -full
check_timing -verbose > $REPORTS_DIR/${DESIGN_NAME}_check_timing.report


##################################################################
#    Save_Session Section                                        #
##################################################################
save_session ${DESIGN_NAME}_ss


##################################################################
#    Report_timing Section                                       #
##################################################################
report_global_timing > $REPORTS_DIR/${DESIGN_NAME}_report_global_timing.report
report_clock -skew -attribute > $REPORTS_DIR/${DESIGN_NAME}_report_clock.report 
report_analysis_coverage > $REPORTS_DIR/${DESIGN_NAME}_report_analysis_coverage.report
report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net  > $REPORTS_DIR/${DESIGN_NAME}_report_timing.report
report_constraints -all_violators -verbose > $REPORTS_DIR/${DESIGN_NAME}_report_constraints.report
report_design > $REPORTS_DIR/${DESIGN_NAME}_report_design.report
report_net > $REPORTS_DIR/${DESIGN_NAME}_report_net.report


##################################################################  
#    Power Switching Activity Annotation Section                 #  
##################################################################  
source $NAME_MAP_FILE                                   

if {[string equal [getenv "ANALYSIS_MODE"] "timebased"]} {
        ;#read_fsdb "${ACTIVITY_FILE}" -strip_path $STRIP_PATH -rtl -format systemverilog ;#-time {200000 300000}
        ;# using the command red_vcd with an fsdb file converts it automatically, and gives higher annotation than read_fsdb
        read_vcd "${ACTIVITY_FILE}" -strip_path $STRIP_PATH -rtl -format systemverilog
        set_power_analysis_options -waveform_format fsdb -waveform_output ${RESULTS_DIR}/powerWave -separate_power_waveform all ;# write power waveforms to file
} elseif {[string equal [getenv "ANALYSIS_MODE"] "averaged"]} {
        ;#read_saif "${ACTIVITY_FILE}" -strip_path $STRIP_PATH ;# could also create saif file, but vcd can be used directly
        read_vcd "${ACTIVITY_FILE}" -strip_path $STRIP_PATH -rtl -format systemverilog
} else {
        set power_default_toggle_rate 0.1 ;# clocks are annotated by the contraints file
        ;#set_switching_activity -toggle_rate 0.1 -static_probability 0.5 ;# possibility for more control
}


report_switching_activity -list_not_annotated -sort_by name > $REPORTS_DIR/${DESIGN_NAME}_report_switching_activity.report

##################################################################
#    Power Analysis Section                                      #
##################################################################
## run power analysis
check_power   > $REPORTS_DIR/${DESIGN_NAME}_check_power.report
update_power  

# needs to run "update_power" for the signals to propagate
report_switching_activity -list_not_annotated -sort_by name > $REPORTS_DIR/${DESIGN_NAME}_report_switching_activity_post_update_power.report


## report_power
report_power > $REPORTS_DIR/${DESIGN_NAME}_report_power.report


# Clock Gating & Vth Group Reporting Section
report_clock_gate_savings  > $REPORTS_DIR/${DESIGN_NAME}_report_clock_gate_savings.report

# Set Vth attribute for each library if not set already
foreach_in_collection l [get_libs] {
        if {[get_attribute [get_lib $l] default_threshold_voltage_group] == ""} {
                set lname [get_object_name [get_lib $l]]
                set_user_attribute [get_lib $l] default_threshold_voltage_group $lname -class lib
        }
}
report_power -threshold_voltage_group > $REPORTS_DIR/${DESIGN_NAME}_pwr.per_lib_leakage
report_threshold_voltage_group > $REPORTS_DIR/${DESIGN_NAME}_pwr.per_volt_threshold_group



exit

