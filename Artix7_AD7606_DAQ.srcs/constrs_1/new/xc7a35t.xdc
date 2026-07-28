##================================================
## Artix7 AD7606 DAQ
## XC7A35TI FGG484
##================================================


##================================================
## FPGA CLOCK
## 50MHz oscillator
##================================================

set_property PACKAGE_PIN R4 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 20.000 [get_ports clk]

set_property PACKAGE_PIN T1 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]

##================================================
## AD7606 DATA[15:0]
##================================================

set_property PACKAGE_PIN P15 [get_ports {ad_data[0]}]
set_property PACKAGE_PIN R16 [get_ports {ad_data[1]}]
set_property PACKAGE_PIN V18 [get_ports {ad_data[2]}]
set_property PACKAGE_PIN V19 [get_ports {ad_data[3]}]
set_property PACKAGE_PIN P19 [get_ports {ad_data[4]}]
set_property PACKAGE_PIN R17 [get_ports {ad_data[5]}]
set_property PACKAGE_PIN N17 [get_ports {ad_data[6]}]
set_property PACKAGE_PIN P17 [get_ports {ad_data[7]}]
set_property PACKAGE_PIN Y18 [get_ports {ad_data[8]}]
set_property PACKAGE_PIN Y19 [get_ports {ad_data[9]}]
set_property PACKAGE_PIN R18 [get_ports {ad_data[10]}]
set_property PACKAGE_PIN T18 [get_ports {ad_data[11]}]
set_property PACKAGE_PIN AA19 [get_ports {ad_data[12]}]
set_property PACKAGE_PIN AB20 [get_ports {ad_data[13]}]
set_property PACKAGE_PIN W19 [get_ports {ad_data[14]}]
set_property PACKAGE_PIN W20 [get_ports {ad_data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ad_data[*]}]


##================================================
## AD7606 Busy
##================================================

set_property PACKAGE_PIN K18 [get_ports ad_busy]
set_property IOSTANDARD LVCMOS33 [get_ports ad_busy]


##================================================
## AD7606 CONTROL
##================================================

set_property PACKAGE_PIN M22 [get_ports os0]
set_property IOSTANDARD LVCMOS33 [get_ports os0]
set_property PACKAGE_PIN N22 [get_ports os1]
set_property IOSTANDARD LVCMOS33 [get_ports os1]
set_property PACKAGE_PIN M20 [get_ports os2]
set_property IOSTANDARD LVCMOS33 [get_ports os2]

set_property PACKAGE_PIN N20 [get_ports ad_rage]
set_property IOSTANDARD LVCMOS33 [get_ports ad_rage]

set_property PACKAGE_PIN L20 [get_ports ad_convstA]
set_property IOSTANDARD LVCMOS33 [get_ports ad_convstA]
set_property PACKAGE_PIN L19 [get_ports ad_convstB]
set_property IOSTANDARD LVCMOS33 [get_ports ad_convstB]

set_property PACKAGE_PIN N19 [get_ports ad_rst]
set_property IOSTANDARD LVCMOS33 [get_ports ad_rst]

set_property PACKAGE_PIN N18 [get_ports ad_rd]
set_property IOSTANDARD LVCMOS33 [get_ports ad_rd]

set_property PACKAGE_PIN K19 [get_ports ad_cs]
set_property IOSTANDARD LVCMOS33 [get_ports ad_cs]



##================================================
## UART
##================================================
set_property PACKAGE_PIN P20 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN T20 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
