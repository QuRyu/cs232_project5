library ieee;
use ieee.std_logic_1164.all;

entity ROM is 
    port (
        addr : in std_logic_vector (3 downto 0);
        data : out std_logic_vector (10 downto 0)
    );
end entity;

architecture rlt of ROM is 

begin

  data <= 
    "00101001010" when addr = "00000" else -- move 0101 to ACC low 4 bits
    "00111001010" when addr = "00001" else -- move 0101 to ACC high 4 bits
    "00010000000" when addr = "00010" else -- move ACC to LR 
    "00001100000" when addr = "00011" else -- move 1s to ACC
    "01000101010" when addr = "00100" else -- add 1 to LR
    "01000101010" when addr = "00101" else -- add 1 to LR
    "01000101010" when addr = "00110" else -- add 1 to LR
    "01000101010" when addr = "00111" else -- add 1 to LR
    "01010011000" when addr = "01000" else -- shift LR left 
    "01011011000" when addr = "01001" else -- shift LR right
    "01010011000" when addr = "01010" else -- shift LR left 
    "01011011000" when addr = "01011" else -- shift LR right
    "01010011000" when addr = "01100" else -- shift LR left 
    "01011011000" when addr = "01101" else -- shift LR right
    "01010011000" when addr = "01110" else -- shift LR left 
    "01011011000" when addr = "01111" else -- shift LR right
    "01010011000" when addr = "10000" else -- shift LR left 
    "01011011000" when addr = "10001" else -- shift LR right
    "01000101010" when addr = "10010" else -- add 1 to LR 
    "01001101010" when addr = "10011" else -- sub 1 from LR
    "01000101010" when addr = "10100" else -- add 1 to LR 
    "01000101010" when addr = "10101" else -- add 1 to LR
    "01000101010" when addr = "10110" else -- add 1 to LR
    "01001101010" when addr = "10111" else -- sub 1 from LR
    "01001101010" when addr = "11000" else -- sub 1 from LR
    "01001101010" when addr = "11001" else -- sub 1 from LR
    "01000011000" when addr = "11010" else -- add 1 to LR
    "01100011000" when addr = "11011" else -- xor LR with LR
    "01000011000" when addr = "11100" else -- add 0 to LR
    "01100011000" when addr = "11101" else -- xor LR with LR 
    "01000011000" when addr = "11110" else -- add 0 to LR 
    "01000011000";                         -- add 0 to LR

end rlt;
