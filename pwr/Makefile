
DESIGN_NAME ?= vproc_top

# find scenarios from .sgdc files in scenario directory
SDIR = scenarios
SCENARIOS = $(patsubst $(SDIR)/%.sgdc,%, $(wildcard scenarios/*.sgdc))

power_audit:
	spyglass -project ${DESIGN_NAME}.prj -batch -goal power/power_audit -licqueue

define make-pe-target
  pe_$1:
	spyglass -project ${DESIGN_NAME}.prj -batch -goal power/power_est_average@$1 -licqueue
  all_pe:: pe_$1
endef

define make-ac-target
  ac_$1:
	spyglass -project ${DESIGN_NAME}.prj -batch -goal power/power_activity_check@$1 -licqueue
  all_ac:: ac_$1
endef

ac_vsld:
	spyglass -project ${DESIGN_NAME}.prj -batch -goal power/power_activity_check@vsld -licqueue

# define power-est and activity-check targets for all scenarios
$(foreach scen,$(SCENARIOS),$(eval $(call make-pe-target,$(scen))))
$(foreach scen,$(SCENARIOS),$(eval $(call make-ac-target,$(scen))))

print_scenarios:
	echo ${SCENARIOS}

clean:
	rm -rf *.log
	rm -rf *.out
	rm -rf *.rpt

delete:
	rm results WORK -rf
