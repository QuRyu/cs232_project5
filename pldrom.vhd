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
    "0010100101" when addr = "00000" else -- move 0101 to ACC low 4 bits
    "0011100101" when addr = "00001" else -- move 0101 to ACC high 4 bits
    "0001000000" when addr = "00010" else -- move ACC to LR 
    "0000110000" when addr = "00011" else -- move 1s to ACC
    "0100010101" when addr = "00100" else -- add 1 to LR
    "0100010101" when addr = "00101" else -- add 1 to LR
    "0100010101" when addr = "00110" else -- add 1 to LR
    "0100010101" when addr = "00111" else -- add 1 to LR
    "0101001100" when addr = "01000" else -- shift LR left 
    "0101101100" when addr = "01001" else -- shift LR right
    "0101001100" when addr = "01010" else -- shift LR left 
    "0101101100" when addr = "01011" else -- shift LR right
    "0101001100" when addr = "01100" else -- shift LR left 
    "0101101100" when addr = "01101" else -- shift LR right
    "0101001100" when addr = "01110" else -- shift LR left 
    "0101101100" when addr = "01111" else -- shift LR right
    "0101001100" when addr = "10000" else -- shift LR left 
    "0101101100" when addr = "10001" else -- shift LR right
    "0100010101" when addr = "10010" else -- add 1 to LR 
    "0100110101" when addr = "10011" else -- sub 1 from LR
    "0100010101" when addr = "10100" else -- add 1 to LR 
    "0100010101" when addr = "10101" else -- add 1 to LR
    "0100010101" when addr = "10110" else -- add 1 to LR
    "0100110101" when addr = "10111" else -- sub 1 from LR
    "0100110101" when addr = "11000" else -- sub 1 from LR
    "0100110101" when addr = "11001" else -- sub 1 from LR
    "0100001100" when addr = "11010" else -- add 1 to LR
    "0110001100" when addr = "11011" else -- xor LR with LR
    "0100001100" when addr = "11100" else -- add 0 to LR
    "0110001100" when addr = "11101" else -- xor LR with LR 
    "0100001100" when addr = "11110" else -- add 0 to LR 
    "0100001100";                         -- add 0 to LR

end rlt;
