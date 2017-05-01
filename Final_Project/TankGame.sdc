# Create Clocks
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_generated_clock -name {soc|sdram_pll|sd1|pll7|clk[0]} -source [get_pins {soc|sdram_pll|sd1|pll7|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -phase -54.000 -master_clock {CLOCK_50} [get_pins {soc|sdram_pll|sd1|pll7|clk[0]}] 

# Constrain the input I/O path
set_input_delay -clock {CLOCK_50} -max 3 [all_inputs]
set_input_delay -clock {CLOCK_50} -min 2 [all_inputs]

# Constrain the output I/O path
set_output_delay -clock {CLOCK_50} 2 [all_outputs]
