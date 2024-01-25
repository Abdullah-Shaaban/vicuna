# IP name, usually from ip/Example: Example
IP_NAME     = vicunas_datapath
# Design name, usually Example, when using a synthesis/lec/lint wrapper: ExampleTestWrapper
DESIGN_NAME = vicunas_datapath
# the results directory for the synthesis of this design
SYN_DELIV_DIR = $(VC_WORKSPACE)/ip/$(DESIGN_NAME)/syn/results

# Default library and operating condition if not set on command line:
# SC9T_H or SC9T_UH
LIB_SET ?= SC9T_H
NOM_VOLTAGE ?= 0P80V

# default   - default toggle rate averaged
# averaged  - switching information from saif file, averaged
# timebased - switching information from vcd, timebased
ANALYSIS_MODE ?= default

export

power:
	pwr_shell -f rm_pwr_scripts/pwr.tcl | tee pwr.log
	date > power

clean:
	rm reports results power IntroProject_ss -rf
