# Frequency constraint: 250MHz
create_clock "clk_i" -period 2.5
# set_max_delay 4.0 -to [get_clocks clk_i]
# Set the input delay for a clock
# set_input_delay -clock clk -max 2.0 [get_ports input_data]

# Set the output delay for a clock
# set_output_delay -clock clk -max 1.0 [get_ports output_data]

# Set the clock uncertainty
# set_clock_uncertainty 0.2 [get_clocks clk]

# Set the clock period
# set_clock_period -min 5.0 [get_clocks clk]

# Specify a false path (for paths that should not be analyzed)
# set_false_path -from [get_pins async_signal] -to [get_pins some_other_signal]

# Specify a multi-cycle path (for paths that have a different timing relationship)
# set_multicycle_path -setup 3 -from [get_registers source_reg] -to [get_registers dest_reg]

# Set exceptions for specific paths
# set_max_delay -from [get_pins source_reg] -to [get_pins dest_reg] 1.0
