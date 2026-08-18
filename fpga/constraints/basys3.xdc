## ============================================================
## Basys 3 Constraints for Microprogrammed Mano Computer
## Only constrains ports that actually exist on fpga_top.v:
## clk, rst, sw0, led[7:0]
## ============================================================

## Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Reset - Center button (BTNC)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## sw0 - Slide switch 0: selects LED display mode (AC vs CAR)
set_property PACKAGE_PIN V17 [get_ports sw0]
set_property IOSTANDARD LVCMOS33 [get_ports sw0]

## LEDs - show AC[7:0] or CAR[7:0], selected by sw0
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]