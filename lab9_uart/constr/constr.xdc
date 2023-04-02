#Clock signal
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { clk }]; 
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

#Switches
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { rd_uart }];     #rx on sw1
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { wr_uart }];     #tx on sw2
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { reset }];       #reset
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { data }];       #w_data  

#LEDs
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { r_data[0] }]; #r_data[0]
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { r_data[1] }]; #r_data[0]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { r_data[2] }]; #r_data[2]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { r_data[3] }]; #r_data[3]

##Pmod Header JC (pin 0 -> pin 7)                                                                                                                 
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33     } [get_ports { r_data[7] }]; 		 
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33     } [get_ports { tx }]; #pmod pin2 (tx) routed to fpga rx signal 
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33     } [get_ports { rx }]; #pmod pin3 (rx) routed to fpga tx signal
#set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33     } [get_ports {  }];            
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33     } [get_ports {  }];         
#set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33     } [get_ports {  }];           
#set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33     } [get_ports {  }];             
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33     } [get_ports {  }]; 
    #pmod pin2 = rx
    #pmod pin3 = tx
    
    
##RGB LED 6
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { r_data[4] }]; #IO_L18P_T2_34 Sch=led6_r
set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { r_data[5] }]; #IO_L6N_T0_VREF_35 Sch=led6_g
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { r_data[6] }]; #IO_L8P_T1_AD10P_35 Sch=led6_b

#need to map to something to synt
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { r_data[7] }]; 
