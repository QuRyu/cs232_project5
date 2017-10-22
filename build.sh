ghdl -a pldbench.vhd pld2.vhd pldrom.vhd
ghdl -e pldbench
ghdl -r pldbench --vcd=pldbench.vhd
gtkwave lightsbench.vcd
