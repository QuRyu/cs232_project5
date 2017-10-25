-- Qingbo Liu

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pld2 is

    port(
        clk        : in  std_logic;
        reset      : in  std_logic;
        freeze     : in  std_logic;
        lights     : out std_logic_vector(7 downto 0);
        IRView     : out std_logic_vector(9 downto 0)
    );

end entity;

architecture rtl of pld2 is

    -- Build an enumerated type for the state machine
    type state_type is (sFetch, sExecute1, sExecute2);

    -- Register to hold the current state
    signal state   : state_type := sFetch;

    signal IR : std_logic_vector (10 downto 0) := "00000000000";
    signal PC : unsigned (4 downto 0) := "00000";
    signal LR : unsigned (7 downto 0) := "00000000";
    signal ROMvalue : std_logic_vector(9 downto 0);

    signal slowclock : std_logic;
    signal counter : unsigned (23 downto 0);
	 
    signal ACC : unsigned (7 downto 0);
    signal SRC : unsigned (7 downto 0);

    component ROM_task7 
        port (
            addr : in std_logic_vector (3 downto 0);
            data : out std_logic_vector (10 downto 0)
        );
    end component;

begin

    -- Logic to advance to the next state
    process (slowclock, reset)
    begin
        if reset = '0' then
            state <= sFetch;
            IR <= "00000000000";
            PC <= "00000";
            LR <= "00000000";
        elsif (rising_edge(slowclock)) then
            case state is
                when sFetch =>
                    PC <= PC + 1;
                    IR <= ROMvalue;
                    state <= sExecute1;
                when sExecute1 =>
                    case IR(10 downto 9) is 
                        when "00" =>  -- move instruction
                            case IR(6 downto 5) is 
                                when "00" => -- ACC  
                                    SRC <= ACC;
                                when "01" => -- LR
                                    SRC <= LR;
                                when "10" => -- IR low 4 bis sign extended
                                    if IR(3) = '0' then -- extend 0
                                        SRC <= unsigned("0000" & IR(3 downto 0));
                                    else -- extend 1
                                        SRC <= unsigned("1111" & IR(3 downto 0));
                                    end if;
                                when others => -- all 1s
                                    SRC <= "11111111";
                            end case;
                        when "01" =>  -- binary operator 
                            case IR(5 downto 4) is 
                                when "00" => -- ACC
                                    SRC <= ACC;
                                when "01" => -- LR
                                    SRC <= LR;
                                when "10" => -- IR low 2 bits sign extended
                                    if IR(1) = '0' then 
                                        SRC <= unsigned("000000" & IR(1 downto 0));
                                    else 
                                        SRC <= unsigned("111111" & IR(1 downto 0));
                                    end if;
                                when others => -- all 1s
                                    SRC <= "11111111";
                            end case;
                        when "10" =>  -- unconditional branch
                            PC <= unsigned(IR(4 downto 0));
                        when others =>  -- conditional branch
                            if IR(8) = '0' then  -- SRC is ACC
                                    if ACC = 0 then 
                                        PC <= unsigned(IR(4 downto 0));
                                    end if;
                            else -- SRC is LR
                                    if LR = 0 then 
                                        PC <= unsigned(IR(4 downto 0));
                                    end if;
                            end if;
                    end case;
                    state <= sExecute2;
                when sExecute2 =>
                    case IR(10 downto 9) is 
                        when "00"   => -- move instruction
                            case IR(8 downto 7) is  -- dst
                                when "00" => -- ACC
                                    ACC <= SRC;
                                when "01" => -- LR 
                                    LR <= SRC;
                                when "10" => -- ACC low 4 bits
                                    ACC(3 downto 0) <= SRC(3 downto 0);
                                when others => -- ACC high 4 bits
                                    ACC(7 downto 4) <= SRC(7 downto 4);
                            end case;
                        when "01"   => -- binary operation
                            if IR(3) = '0' then -- dst is ACC
                            case IR(8 downto 6) is 
                                when "000" => -- add 
                                    ACC <= SRC + ACC;
                                when "001" => -- sub
                                    ACC <= ACC - SRC;
                                when "010" => -- shift left
                                    ACC <= shift_left(ACC, 1);
                                when "011" => -- shift right with sign bit
                                    ACC <= shift_right(ACC, 1);
                                when "100" => -- xor
                                    ACC <= ACC xor SRC;
                                when "101" => -- and 
                                    ACC <= ACC and SRC;
                                when "110" => -- rotate left
                                    ACC <= rotate_left(ACC, 1);
                                when others => -- rotate right
                                    ACC <= rotate_right(ACC, 1);
                            end case;
									 
                            else 
                            case IR(8 downto 6) is 
                                when "000" => -- add 
                                    LR <= SRC + LR;
                                when "001" => -- sub
                                    LR <= LR - SRC;
                                when "010" => -- shift left
                                    LR <= shift_left(LR, 1);
                                when "011" => -- shift right with sign bit
                                    LR <= shift_right(LR, 1);
                                when "100" => -- xor
                                    LR <= LR xor SRC;
                                when "101" => -- and 
                                    LR <= LR and SRC;
                                when "110" => -- rotate left
                                    LR <= rotate_left(LR, 1);
                                when others => -- rotate right
                                    LR <= rotate_right(LR, 1);
                            end case;
                            end if;
                    when others =>
                    end case;
                    state <= sFetch;
            end case;

        end if;
    end process;

    -- slow down the clock
    process (clk, reset, freeze)
    begin 
        if reset = '0' then 
            counter <= "000000000000000000000000";
        elsif (rising_edge(clk) and freeze = '1') then 
            counter <= counter + 1;
        end if;

    end process;

    slowclock <=  counter(20);

    IRview <= IR;
    lights <= std_logic_vector(LR);
    
lightrom : ROM_task7
    port map (
        addr => std_logic_vector(PC),
        data => ROMvalue
);

end rtl;
