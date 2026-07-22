##================================================
## AD7606
## XC7A35TI FGG484
##================================================

## TEST CLOCK
set_property PACKAGE_PIN Y18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]


## TEST UART TX
set_property PACKAGE_PIN AB18 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]

## AD DATA[15:0]
set_property PACKAGE_PIN W22 [get_ports ad_data[0]]
set_property PACKAGE_PIN W21 [get_ports ad_data[1]]
set_property PACKAGE_PIN V20 [get_ports ad_data[2]]
set_property PACKAGE_PIN U20 [get_ports ad_data[3]]

set_property PACKAGE_PIN U21 [get_ports ad_data[4]]
set_property PACKAGE_PIN T21 [get_ports ad_data[5]]
set_property PACKAGE_PIN Y22 [get_ports ad_data[6]]
set_property PACKAGE_PIN Y21 [get_ports ad_data[7]]

set_property PACKAGE_PIN AA21 [get_ports ad_data[8]]
set_property PACKAGE_PIN AA20 [get_ports ad_data[9]]
set_property PACKAGE_PIN R19 [get_ports ad_data[10]]
set_property PACKAGE_PIN P19 [get_ports ad_data[11]]

set_property PACKAGE_PIN AB22 [get_ports ad_data[12]]
set_property PACKAGE_PIN AB21 [get_ports ad_data[13]]
set_property PACKAGE_PIN V16 [get_ports ad_data[14]]
set_property PACKAGE_PIN V17 [get_ports ad_data[15]]


set_property IOSTANDARD LVCMOS33 [get_ports ad_data[*]]


## BUSY
set_property PACKAGE_PIN W20 [get_ports ad_busy]
set_property IOSTANDARD LVCMOS33 [get_ports ad_busy]


## CONVST
set_property PACKAGE_PIN AB20 [get_ports ad_convst]


## RD
set_property PACKAGE_PIN T18 [get_ports ad_rd]


## CS
set_property PACKAGE_PIN Y19 [get_ports ad_cs]


set_property IOSTANDARD LVCMOS33 [get_ports {ad_convst ad_rd ad_cs}]