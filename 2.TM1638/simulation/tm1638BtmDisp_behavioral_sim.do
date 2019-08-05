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
vlog  ../src/tm1638BtmDisp.v
vlog  ../simulation/tm1638BtmDisp_tb.v
#
# Call vsim to invoke simulator
#
vsim -L eg_4_5 -gui -novopt work.tm1638BtmDisp_tb
#
# Add waves
#
add wave -noupdate /tm1638BtmDisp_tb/CLK_IN
add wave -noupdate /tm1638BtmDisp_tb/RST_IN
add wave -noupdate /tm1638BtmDisp_tb/TM1638_STB
add wave -noupdate /tm1638BtmDisp_tb/TM1638_CLK
add wave -noupdate /tm1638BtmDisp_tb/TM1638_DIO
add wave -noupdate /tm1638BtmDisp_tb/byte
add wave -noupdate /tm1638BtmDisp_tb/dio
add wave -noupdate -divider tm1638
add wave -noupdate /tm1638BtmDisp_tb/uut/tm1638_1/CLK_IN
add wave -noupdate -radix hexadecimal /tm1638BtmDisp_tb/uut/tm1638_1/ADDR
add wave -noupdate -radix hexadecimal /tm1638BtmDisp_tb/uut/tm1638_1/DATA_IN
add wave -noupdate /tm1638BtmDisp_tb/uut/tm1638_1/READY
add wave -noupdate /tm1638BtmDisp_tb/uut/tm1638_1/WRITE
add wave -noupdate -divider btmDisp
add wave -noupdate /tm1638BtmDisp_tb/uut/clkSlowCpt
add wave -noupdate /tm1638BtmDisp_tb/uut/writeSlowCpt
add wave -noupdate /tm1638BtmDisp_tb/uut/readSlowCpt
add wave -noupdate -radix hexadecimal /tm1638BtmDisp_tb/uut/data
add wave -noupdate -radix hexadecimal /tm1638BtmDisp_tb/uut/hexaIndex
#
# Run simulation
#
run -all
#
# End
