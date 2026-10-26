----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.10.2026 22:32:08
-- Design Name: 
-- Module Name: ft232h_cmd_parser - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ft232h_cmd_parser is
--  Port ( );
 port(clk             :in std_logic;
      rst             :in std_logic;
      data_in         :in std_logic_vector(7 downto 0);
      uart_data_en    :in std_logic;
      rxf             :in std_logic;
      
      ft232h_data_en  :out std_logic;
      ft232h_cmd_valid:out std_logic;
      ft232h_cmd_start:out std_logic_vector(7 downto 0);
      ft232h_cmd_count:out std_logic_vector(7 downto 0));
      
end ft232h_cmd_parser;

architecture Behavioral of ft232h_cmd_parser is

 type cmd_state_tpye is(IDLE,
                        CMD,
                        START_CH,
                        COUNT);
 signal state:cmd_state_tpye:=IDLE;
 signal start_reg : std_logic_vector(7 downto 0) := (others=>'0');
 signal count_reg : std_logic_vector(7 downto 0) := (others=>'0');
 
begin
 process(clk)
  begin
   if rising_edge(clk) then
    if(rst = '0')then
     ft232h_cmd_valid<='0';
     ft232h_data_en<='0';
     ft232h_cmd_start<=(others=>'0');
     ft232h_cmd_count<=(others=>'0');
    else
     ft232h_cmd_valid<='0';
     if(rxf = '0')then
      case state is
       when IDLE =>
        if(data_in = x"BB")then
         state<=CMD;
        end if;
       when CMD =>
        if(data_in = x"01")then
         state<=START_CH;
        else
         state<=IDLE;
        end if;
       when START_CH =>
        start_reg<=data_in;
        state<=COUNT;
       when COUNT =>
        if(uart_data_en = '0')then
         count_reg<=data_in;
         ft232h_cmd_start<=start_reg;
         ft232h_cmd_count<=data_in;
         ft232h_cmd_valid<='1';
         --uart_data_en<='1';
         ft232h_data_en<='1';
         state<=IDLE;
        else
         state<=IDLE;
        end if;
       when others =>
        state<=IDLE;
      end case;
     end if;
    end if;
   end if;
  end process;
        
end Behavioral;
