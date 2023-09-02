vlib work
vlog part3.sv
vsim part3

log {/*}
add wave {/*}

########### Testing Basic Functionality ###########

force {Clock} 0,1 1 ns -r 2ns
force {Reset} 1
run 3ns

# Load divisor and dividend
force {Reset} 0
force {Go} 1
force {Divisor} 0101
force {Dividend} 1000
run 2ns

# Shift 1
force {Go} 0
run 2ns

# Shift 2
run 2ns

# Shift 3
run 2ns

# Shift 4
run 10ns

# Load again
force {Go} 1
force {Divisor} 0101
force {Dividend} 1000
run 2ns

# Shift 1
force {Go} 0
run 2ns

# Shift 2
run 2ns

# Shift 3
run 2ns

# Shifft 4
run 6ns

# Reset
force {Reset} 1
run 2ns

force {Reset} 0
run 2ns