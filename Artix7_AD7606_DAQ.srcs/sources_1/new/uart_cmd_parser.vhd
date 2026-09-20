----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2026/09/20 08:51:10
-- Design Name: 
-- Module Name: uart_cmd_parser - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_cmd_parser is
--  Port ( );
 port(clk,rst :in std_logic;
          rx_data :in std_logic_vector(7 downto 0);
          rx_valid:in std_logic;
          
          cmd_valid:out std_logic;
          cmd_start:out std_logic_vector(7 downto 0);
          cmd_count:out std_logic_vector(7 downto 0));
end uart_cmd_parser;

architecture Behavioral of uart_cmd_parser is
 type state_type is(
      IDLE,
      CMD,
      START_CH,
      COUNT);
 signal state : state_type := IDLE;
 signal start_reg : std_logic_vector(7 downto 0) := (others=>'0');
 signal count_reg : std_logic_vector(7 downto 0) := (others=>'0');
begin
 process(clk)
  begin
   if(clk'event and clk = '1')then
    if(rst = '0')then
     state<=IDLE;
     cmd_valid<='0';
     cmd_start<=(others=>'0');
     cmd_count<=(others=>'0');
    else
     cmd_valid<='0';
     if(rx_valid = '1')then
      case state is
       when IDLE =>
        if(rx_data = x"AA")then
         state<=CMD;
        end if;
       when CMD =>
        if(rx_data = x"01")then
         state<=START_CH;
        else
         state<=IDLE;
        end if;
       when START_CH =>
        start_reg<=rx_data;
        state<=COUNT;
       when COUNT =>
        count_reg<=rx_data;
        cmd_start<=start_reg;
        cmd_count<=rx_data;
        cmd_valid<='1';
        state<=IDLE;
       when others =>
        state<=IDLE;
      end case;
     end if;
    end if;
   end if;
  end process;
end Behavioral;
