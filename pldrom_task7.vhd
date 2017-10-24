library ieee;
use ieee.std_logic_1164.all;

entity ROM_task7 is 
    port (
        addr : in std_logic_vector (3 downto 0);
        data : out std_logic_vector (9 downto 0)
    );
end entity;

architecture rlt of ROM_task7 is 

begin

  data <= 
    "0010100000" when addr = "0000" else -- move 0s to ACC low 
    "0011100001" when addr = "0001" else -- move 0001 to ACC high 
    "0001001010" when addr = "0010" else -- move acc to LR 
    "0100110101" when addr = "0011" else -- LR minus -1 
    "1110000011" when addr = "0100" else -- test if LR is 0; if not jump to 0011
    "1000010000" when addr = "0101" else -- jump to 0000

end rlt;
