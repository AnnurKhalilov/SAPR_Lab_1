quit -sim
vlib work
vlog apb_slave.sv apb_master.sv TB.sv
vsim -voptargs=+acc work.TB

add wave -noupdate -radix binary /TB/DUT/pclk
add wave -noupdate -radix binary /TB/DUT/presetn
add wave -noupdate -radix hexadecimal /TB/DUT/paddr
add wave -noupdate -radix hexadecimal /TB/DUT/pwdata
add wave -noupdate -radix binary /TB/DUT/psel
add wave -noupdate -radix binary /TB/DUT/penable
add wave -noupdate -radix binary /TB/DUT/pwrite
add wave -noupdate -radix binary /TB/DUT/pready
add wave -noupdate -radix binary /TB/DUT/pslverr
add wave -noupdate -radix hexadecimal /TB/DUT/prdata
add wave -noupdate -radix hexadecimal /TB/DUT/register_with_some_name
add wave -noupdate -radix unsigned /TB/DUT/reg_group_num
add wave -noupdate -radix hexadecimal /TB/DUT/reg_date
add wave -noupdate -radix ascii /TB/DUT/reg_surname
add wave -noupdate -radix ascii /TB/DUT/reg_name
add wave -noupdate /TB/DUT/apb_st

run -all
wave zoom full