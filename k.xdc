## ===========================================
## CLOCK INPUT (100 MHz onboard oscillator)
## ===========================================
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## ===========================================
## RESET BUTTON (BTNC)
## ===========================================
set_property PACKAGE_PIN N17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## ===========================================
## PAUSE/RESUME SWITCH
## ===========================================
set_property PACKAGE_PIN J15 [get_ports sw]
set_property IOSTANDARD LVCMOS33 [get_ports sw]

## ===========================================
## Increment +10 Button
## ===========================================
set_property PACKAGE_PIN M18 [get_ports btn10]
set_property IOSTANDARD LVCMOS33 [get_ports btn10]

## Increment +100 Button
## ===========================================
set_property PACKAGE_PIN M17 [get_ports btn100]
set_property IOSTANDARD LVCMOS33 [get_ports btn100]

## Increment +1000 Button
## ===========================================
set_property PACKAGE_PIN P18 [get_ports btn1000]
set_property IOSTANDARD LVCMOS33 [get_ports btn1000]

## Increment +10000 Button
## ===========================================
set_property PACKAGE_PIN P17 [get_ports btn10000]
set_property IOSTANDARD LVCMOS33 [get_ports btn10000]

## ===========================================
## 7-SEGMENT DISPLAY SEGMENTS (CA-CG)
## ===========================================
set_property PACKAGE_PIN T10 [get_ports {seg[0]}] ; # CA
set_property PACKAGE_PIN R10 [get_ports {seg[1]}] ; # CB
set_property PACKAGE_PIN K16 [get_ports {seg[2]}] ; # CC
set_property PACKAGE_PIN K13 [get_ports {seg[3]}] ; # CD
set_property PACKAGE_PIN P15 [get_ports {seg[4]}] ; # CE
set_property PACKAGE_PIN T11 [get_ports {seg[5]}] ; # CF
set_property PACKAGE_PIN L18 [get_ports {seg[6]}] ; # CG
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

## ===========================================
## ANODE CONTROL (AN0-AN7)
## ===========================================
set_property PACKAGE_PIN J17 [get_ports {an[0]}] ; # AN0
set_property PACKAGE_PIN J18 [get_ports {an[1]}] ; # AN1
set_property PACKAGE_PIN T9  [get_ports {an[2]}] ; # AN2
set_property PACKAGE_PIN J14 [get_ports {an[3]}] ; # AN3
set_property PACKAGE_PIN P14 [get_ports {an[4]}] ; # AN4
set_property PACKAGE_PIN T14 [get_ports {an[5]}] ; # AN5
set_property PACKAGE_PIN K2  [get_ports {an[6]}] ; # AN6
set_property PACKAGE_PIN U13 [get_ports {an[7]}] ; # AN7
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]
