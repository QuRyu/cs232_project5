library ieee;
use ieee.std_logic_1164.all;

entity ROM is 
    port (
        addr : in std_logic_vector (3 downto 0);
        data : out std_logic_vector (9 downto 0)
    );
end entity;

architecture rlt of ROM is 

begin

  data <= 
    "0000110000"  when addr = "0000" else -- move 1s to ACC
    "0001110000"  when addr = "0001" else -- move 1s to LR
    "0010101011"  when addr = "0010" else -- move 1011 to ACC low 4 bits
    "0101101100"  when addr = "0011" else -- shift LR right 
    "0101000100"  when addr = "0100" else -- shift the value of  ACC left and put the result in LR
    "0111001100"  when addr = "0101" else -- rotate LR left 
    "0111101100"  when addr = "0110" else -- rotate LR right
    "0110010100"  when addr = "0111" else -- xor IR and LR and put the result in LR 
    "0100010111"  when addr = "1000" else -- add 11111111 to LR
    "0100100100"  when addr = "1001" else -- sub ACC from LR 
    "0101000100"  when addr = "1010" else -- shift ACC left and put result in LR
    "0101100000"  when addr = "1011" else -- shift ACC right
    "0000010000"  when addr = "1100" else -- move LR to ACC
    "0100000100"  when addr = "1101" else -- add ACC and LR and put the result in LR
    "0001110000"  when addr = "1110" else -- move 1s to LR
    "0000110000";                         -- move 1s to ACC

end rlt;
