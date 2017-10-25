library ieee;
use ieee.std_logic_1164.all;

entity ROM_0 is 
    port (
        addr : in std_logic_vector (3 downto 0);
        data : out std_logic_vector (9 downto 0)
    );
end entity;

architecture rlt of ROM_0 is 

begin

  data <= 
    "0001110000"  when addr = "0000" else -- move 1s to LR
    "0010010111"  when addr = "0001" else -- Move 0111 to ACC low 4 bits
    "0011010000"  when addr = "0010" else -- move 0000 to ACC high 4 bits
    "0110000100"  when addr = "0011" else -- xor ACC and LR
    "0101001100"  when addr = "0100" else -- shift LR left
    "0100001100"  when addr = "0101" else -- bitwise and LR with LR 
    "0110110101"  when addr = "0110" else -- and LR with 000000001
    "1110000000"  when addr = "0111" else -- if LR 0 branch to 0000
    "1000000011";                         -- jump tp 0011

end rlt;
