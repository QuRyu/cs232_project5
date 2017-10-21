-- Qingbo Liu

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lights is

    port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        pause    : in  std_logic;
        add      : in  std_logic; -- input for accelerating execution speed
        minus    : in  std_logic; -- input for slowing down execution speed
        lights   : out std_logic_vector(7 downto 0);
        IRView   : out std_logic_vector(3 downto 0)
    );

end entity;

architecture rtl of lights is

    -- Build an enumerated type for the state machine
    type state_type is (sFetch, sExecute);

    -- Register to hold the current state
    signal state   : state_type := sFetch;

    signal IR : std_logic_vector (3 downto 0) := "0000";
    signal PC : unsigned (3 downto 0) := "0000";
    signal LR : unsigned (7 downto 0) := "00000000";
    signal ROMvalue : std_logic_vector(3 downto 0);

    signal slowclock : std_logic;
    signal counter : unsigned (23 downto 0);
	 
    signal speed : unsigned (1 downto 0) := "00";

    component lightrom 
        port (
            addr : in std_logic_vector (3 downto 0);
            data : out std_logic_vector (3 downto 0)
        );
    end component;

begin

    -- Logic to advance to the next state
    process (slowclock, reset)
    begin
        if reset = '0' then
            state <= sFetch;
            IR <= "0000";
            PC <= "0000";
            LR <= "00000000";
            speed <= "00";
        elsif (rising_edge(slowclock)) then
            case state is
                when sFetch =>
                    PC <= PC + 1;
                    IR <= ROMvalue;
                    state <= sExecute;
                when sExecute =>
                    case IR is 
                        when "0000" => LR <= "00000000";
                        when "0001" => LR <= '0' & LR(7 downto 1); -- LR >> 1                          
                        when "0010" => LR <= LR(6 downto 0) & '0'; -- LR << 1
                        when "0011" => LR <= LR + 1; -- add 1 
                        when "0100" => LR <= LR - 1; -- subtract 1 
                        when "0101" => LR <= not LR; -- invert all bits
                        when "0110" => LR <= LR ror 1; -- rotate right by one 
                        when "0111" => LR <= LR rol 1; -- rotate left by one 
                        when others => -- conditional branch jump
                            if LR(0) = '1' then 
                                PC <= unsigned(IR);
                            end if;
                    end case;
                    state <= sFetch;
            end case;

            if add = '0' then 
                speed <= speed + 1;
            elsif minus = '0' then 
                speed <= speed - 1;
            end if;
        end if;
    end process;

    -- slow down the clock
    process (clk, reset, pause)
    begin 
        if reset = '0' then 
            counter <= "000000000000000000000000";
        elsif (rising_edge(clk) and pause = '1') then 
            counter <= counter + 1;
        end if;

    end process;

    slowclock <= counter(20) when speed = "11" else 
                 counter(21) when speed = "10" else 
                 counter(22) when speed = "01" else 
                 counter(23);

    IRview <= IR;
    lights <= std_logic_vector(LR);
    
rom : lightrom 
    port map (
        addr => std_logic_vector(PC),
        data => ROMvalue
);

end rtl;
