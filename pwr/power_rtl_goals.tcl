# Defines all goals for running Spyglass on RTL
# For details, see https://projecttools.nordicsemi.no/confluence/display/QPDA/Spyglass

set DESIGN_STAGE "block/rtl_handoff"

# set path to project specific SpyGlass Methodology installation
current_methodology /cad/synopsys/Spyglass/2022.06-SP1-1/SPYGLASS_HOME/GuideWare/latest/$DESIGN_STAGE

#-------------------------------------------------------------------------------
# [START] Globally used Power goal settings
#-------------------------------------------------------------------------------
# Technology library settings
# set_option prefer_tech_lib yes    # Already in spyglassCommon.tcl
set_option include_opt_data yes
set_option enable_power_platform_flow yes


# ignore code included in // synopsys translate_off
# // synopsys translate_on
set_option pragma { spyglass synopsys synthesis pragma }

#---------------------------------------
# Globally used parameter settings
#---------------------------------------
proc pwr_recommended_global_setting_proc {} {
    # Set preference of sim data from Sim file not SGDC
    set_parameter pe_activity_priority sim
    # Enable auto inference of slew instead of default
    set_parameter pe_auto_infer_slew yes
    set_parameter pe_sim_enable_save_restore no
}

proc pwr_recommended_est_setting_proc {} {
    # Set the clock gating threshold to match that used by power synthesis
    set_goal_option sgsyn_clock_gating_threshold 3
    # Set the targeted synthesis to select scan flops
    set_goal_option use_scan_flops yes
    # To enable clock browser in Power Explorer
    set_parameter pe_enable_clock_browser yes
}

#-------------------------------------------------------------------------------
# -> END
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# [START] Power Goal Setup Section
#-------------------------------------------------------------------------------

################### power_audit ####################################
## Power Audit for checking the data integrity ##
####################################################################
current_goal power/power_audit
    # Use settings defined in the Tcl proc
    #pwr_recommended_global_setting_proc
    # Use settings defined in the Tcl proc
    pwr_recommended_est_setting_proc


################### power_activity_check ###########################
## Grading vectors and finding activity hotspots ##
####################################################################
current_goal power/power_activity_check
    # Specifies the intervals (in terms of number of cycles of the fastest clock)
    # at which activity values should be averaged.
    set_parameter pe_num_clock_cycles_avg_act 100
    # Enables monitor on clock and enable nets to improve accuracy
    set_parameter pe_enable_monitor_on_clock_nets  yes
    set_parameter pe_enable_monitor_on_enable_nets yes
    
 

################### Optional GOAL ##################################
## Grading vectors and finding activity hotspots ##
####################################################################
pwr_recommended_global_setting_proc
    # Specifies the intervals (in terms of number of cycles of the fastest clock)
    # at which activity values should be averaged.
    set_parameter pe_num_clock_cycles_avg_act 100


################### Optional GOAL ##################################
## Find scenarios ##
####################################################################
proc getScenarios { dir } {
    # Search for scenarios in scenario directory
    set paths [glob -directory $dir *.sgdc]
    foreach value $paths {lappend files [string trimright [file tail $value] .sgdc]}
    return $files
}


#################################################################
## Power Estimation Goal ##
##################################################################
proc estGoalCommon {goal_name scenario_name} {
    global ENABLE_CALIBRATION_FLOW
    global PE_CALIBRATION_DATA_DIR_PATH

    ################### with calibration data ########################
    ## Power Estimation on Original RTL with calibration data ##
    ##################################################################
    current_goal power/$goal_name -scenario $scenario_name
    read_file -type sgdc scenarios/$scenario_name.sgdc
    
    # Use settings defined in the Tcl proc
    # TODO do we need that?
    pwr_recommended_global_setting_proc
    # Use data extracted from netlist design
    pwr_recommended_est_setting_proc
    # To use data extracted from netlist design
    if { $ENABLE_CALIBRATION_FLOW == yes} {
        set_parameter pe_calibration_data_dir $PE_CALIBRATION_DATA_DIR_PATH
    }

    # To stop any DB consolidation for this goal in power explorer flow
    # TODO do we need that?
    set_parameter pe_disable_goal_consolidation yes
}

proc DefinePowerEstGoal {goal_name} {
    global PROJECT_DIR_PATH

    foreach scenario [getScenarios $PROJECT_DIR_PATH/scenarios] {
      puts $goal_name@$scenario
      estGoalCommon $goal_name $scenario
    }
}


# To sanity check of project setup and activity data
DefinePowerEstGoal power_activity_check

#power_est_average : power estimation. Requires only PE lic
DefinePowerEstGoal power_est_average

#power_est_profiling : power estimation + profiling. Requires PE and PR lic
DefinePowerEstGoal power_est_profiling

# reset current_goal scope back to global scope
current_goal none
