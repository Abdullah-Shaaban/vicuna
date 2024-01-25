# Defines global settings that are common for all spyglass tools.
# For details, see https://projecttools.nordicsemi.no/confluence/display/QPDA/Spyglass

#-------------------------------------------------------------------------------
# [START] Global Section For Spyglass
#-------------------------------------------------------------------------------

# prevent spyglass from checking out unneeded licenses. IMPORTANT.
set_option nosavepolicy all

# Enable SV 2012 constructs
set_option enableSV12 yes

# specify common VHDL/Mixed language options
set_option sort yes

# avoid overwrite of this file from the GUI
set_option project_read_only yes

# enable synthesis during the design-read process
# set_option designread_enable_synthesis yes

# Disables flattening during the compile_design command in the sg_shell
set_option designread_disable_flatten no

# Use this design-read option to allow duplicate module/UDP definitions.
set_option allow_module_override no

# Use this command to enable reporting of incremental messages so that you can compare results of a previously run goal with the current goal.
set_option report_incr_messages yes

# map Synopsys DesignWare components in terms of technological gates
set_option dw yes

# Enables save of design query data as part of the goal execution
set_option auto_save yes

# Use this design-read option to enable the design save-restore feature.
set_option enable_save_restore yes

# set this to yes in project file if SDC is used
set_option sdc2sgdc no

# SIG-1859
# Use this command to provide higher preference to technology library definitions present in the .lib/.sglib file over user-specified definitions present in source HDL files, precompiled libraries, and simulation models while searching for the master of an instance.
set_option prefer_tech_lib yes

# sets the SPYGLASS macro for the complete project.
# For more information on the SPYGLASS macro, see here: https://projecttools.nordicsemi.no/confluence/display/QPDA/RTL+meant+only+for+Spyglass+checks
set_option define { SPYGLASS=1 }

# will show error count >1M
set_option lvpr -1

# Prevents the tool from hanging/waiting for related licenses
set_option disable_html_report {datasheet dashboard html}

# Print all un-annotated nets
set_option pe_num_unset_nets -1
#-------------------------------------------------------------------------------
# [END] Global section
#-------------------------------------------------------------------------------
