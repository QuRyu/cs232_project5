ghdl -a pldbench.vhd pld2.vhd pldrom.vhd
ghdl -e pldbench
ghdl -r pldbench --vcd=pldbench.vcd
gtkwave lightsbench.vcd
