-- Qingbo Liu

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pld2 is

    port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        lights   : out std_logic_vector(7 downto 0);
        IRView   : out std_logic_vector(9 downto 0)
    );

end entity;

architecture rtl of pld2 is

    -- Build an enumerated type for the state machine
    type state_type is (sFetch, sExecute1, sExecute2);

    -- Register to hold the current state
    signal state   : state_type := sFetch;

    signal IR : std_logic_vector (9 downto 0) := "0000000000";
    signal PC : unsigned (3 downto 0) := "0000";
    signal LR : unsigned (7 downto 0) := "00000000";
    signal ROMvalue : std_logic_vector(9 downto 0);

    signal slowclock : std_logic;
    signal counter : unsigned (23 downto 0);
	 
    signal ACC : unsigned (7 downto 0);
    signal SRC : unsigned (7 downto 0);
	 
	 signal temp : unsigned (7 downto 0);

    component ROM 
        port (
            addr : in std_logic_vector (3 downto 0);
            data : out std_logic_vector (9 downto 0)
        );
    end component;

begin

    -- Logic to advance to the next state
    process (slowclock, reset)
    begin
        if reset = '0' then
            state <= sFetch;
            IR <= "0000000000";
            PC <= "0000";
            LR <= "00000000";
        elsif (rising_edge(slowclock)) then
            case state is
                when sFetch =>
                    PC <= PC + 1;
                    IR <= ROMvalue;
                    state <= sExecute1;
                when sExecute1 =>
                    case IR(9 downto 8) is 
                        when "00" =>  -- move instruction
                            case IR(5 downto 4) is 
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
                                when "11" => -- all 1s
                                    SRC <= "11111111";
                            end case;
                        when "01" =>  -- binary operator 
                            case IR(4 downto 3) is 
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
                                when "11" => -- all 1s
                                    SRC <= "11111111";
                            end case;
                        when "10" =>  -- unconditional branch
                            PC <= unsigned(IR(3 downto 0));
                        when "11" =>  -- conditional branch
                            case IR(7) is -- determine the SRC specified
                                when '0' => -- SRC is ACC
                                    if ACC = 0 then 
                                        PC <= unsigned(IR(3 downto 0));
                                    end if;
                                when '1' =>  -- SRC is LR
                                    if LR = 0 then 
                                        PC <= unsigned(IR(3 downto 0));
                                    end if;
                            end case;
                    end case;
                    state <= sExecute2;
                when sExecute2 =>
                    case IR(9 downto 8) is 
                        when "00"   => -- move instruction
                            case IR(7 downto 6) is  -- dst
                                when "00" => -- ACC
                                    ACC <= SRC;
                                when "01" => -- LR 
                                    LR <= SRC;
                                when "10" => -- ACC low 4 bits
                                    ACC(3 downto 0) <= SRC(3 downto 0);
                                when "11" => -- ACC high 4 bits
                                    ACC(7 downto 4) <= SRC(7 downto 4);
                            end case;
                        when "01"   => 
                            if IR(2) = '0' then 
                                temp <= ACC;
                            else 
                                temp <= LR;
                            end if;

                            case IR(7 downto 5) is 
                                when "000" => -- add 
                                    temp <= SRC + temp;
                                when "001" => -- sub
                                    temp <= temp - SRC;
                                when "010" => -- shift left
                                    temp <= shift_left(temp, to_integer(SRC));
                                when "011" => -- shift right with sign bit
                                    temp <= shift_right(temp, to_integer(SRC));
                                when "100" => -- xor
                                    temp <= temp xor SRC;
                                when "101" => -- and 
                                    temp <= temp and SRC;
                                when "110" => -- rotate left
                                    temp <= rotate_left(temp, to_integer(SRC));
                                when "111" => -- rotate right
                                    temp <= rotate_right(temp, to_integer(SRC));
                            end case;
									 
									 if IR(2) = '0' then 
									     ACC <= temp;
								    else 
										  LR <= temp;
								    end if;
                        when others => 
                            temp <= "00000000";
                    end case;
                    state <= sFetch;
            end case;

        end if;
    end process;

    -- slow down the clock
    process (clk, reset)
    begin 
        if reset = '0' then 
            counter <= "000000000000000000000000";
        elsif (rising_edge(clk)) then 
            counter <= counter + 1;
        end if;

    end process;

    slowclock <= clk;

    IRview <= IR;
    lights <= std_logic_vector(LR);
    
lightrom : ROM 
    port map (
        addr => std_logic_vector(PC),
        data => ROMvalue
);

end rtl;
