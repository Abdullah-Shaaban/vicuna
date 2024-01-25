puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Variables common to all reference methodology scripts
# Script: common_setup.tcl
# Version: O-2018.06 (July 23, 2018)
# Copyright (C) 2007-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

### Nordic: Project path from environment
set VC_WORKSPACE [getenv "VC_WORKSPACE"]

set IP_NAME     [getenv "IP_NAME"]      ;#  The name of the IP, used for paths and report names
set DESIGN_NAME [getenv "DESIGN_NAME"]  ;#  The name of the top-level design, which is the IP itself or a wrapper

set SYN_DELIV_DIR     [getenv "SYN_DELIV_DIR"]       ;# The path of the the synthesis directory

set DESIGN_REF_DATA_PATH          ""  ;#  Absolute path prefix variable for library/design data.
                                       #  Use this variable to prefix the common absolute path
                                       #  to the common variables defined below.
                                       #  Absolute paths are mandatory for hierarchical
                                       #  reference methodology flow.

##########################################################################################
# Library Setup Variables
##########################################################################################

# For the following variables, use a blank space to separate multiple entries.
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"
set LIB_PATH_IP                   "$VC_WORKSPACE/externals/data"
set LIB_PATH                      "$VC_WORKSPACE"
set LIB_PATH_TECH                 "$LIB_PATH_IP/technology/lib_ip"
set LIB_PATH_ANA                  "$LIB_PATH_IP/wireless/ana_ip"



set LIB_SET        [getenv "LIB_SET"]
set NOM_VOLTAGE    [getenv "NOM_VOLTAGE"]

###############################################
# library folders and files are inserted here #
###############################################
source -echo -verbose ./rm_setup/library.tcl

set ADDITIONAL_SEARCH_PATH        "$ ${liberty_paths}"  ;#  Additional search path to be added to the default search path

set TARGET_LIBRARY_FILES          ${synth_libraries}  ;#  Target technology logical libraries

set ADDITIONAL_LINK_LIB_FILES     ""  ;#  Extra link logical libraries not included in TARGET_LIBRARY_FILES

set MIN_LIBRARY_FILES             ""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

puts "RM-Info: Completed script [info script]\n"
