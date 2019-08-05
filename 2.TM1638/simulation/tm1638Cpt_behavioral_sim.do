#
# Create work library
#
if {[file exists work]} {vdel -all -lib work}
vlib work
#
# Compile sources
#
vlog  ../src/tm1638.v
vlog  ../src/hexTo7Seg.v
vlog  ../src/tm1638Cpt.v
vlog  ../simulation/tm1638Cpt_tb.v
#
# Call vsim to invoke simulator
#
vsim -L eg_4_5 -gui -novopt work.tm1638Cpt_tb
#
# Add waves
#
add wave *
#
# Run simulation
#
run -all
#
# End
