ghdl -a pldbench.vhd pld.vhd pldrom.vhd
ghdl -e pldbench
ghdl -r pldbench --vcd=pldbench.vhd
gtkwave lightsbench.vcd
