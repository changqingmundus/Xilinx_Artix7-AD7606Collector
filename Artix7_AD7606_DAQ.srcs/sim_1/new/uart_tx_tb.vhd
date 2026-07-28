----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2026/07/28 11:24:50
-- Design Name: 
-- Module Name: uart_tx_tb - Behavioral
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

entity uart_tx_tb is
--  Port ( );
end uart_tx_tb;

architecture Behavioral of uart_tx_tb is
 signal clk:std_logic :='0';
 signal rst:std_logic :='0';
 signal uart_tx:std_logic :='0';
 signal data_valid:std_logic :='0';
 signal tx_data:std_logic_vector(7 downto 0);
 
 constant CLK_PERIOD: time:=20ns;
begin
 CLK<=not CLK after CLK_PERIOD/2;

 uut:entity work.uart_tx
 generic map(
  clk_freq=>50,
  baud_rate=>2000000,
  parity_on=>0,
  data_width=>8)
 port map(
  clk=>clk,
  rst=>rst,
  tx_data=>tx_data,
  tx=>uart_tx,
  data_valid=>data_valid);
 process
  begin
   rst<='0';
   wait for 200ns;
   
   rst<='1';
   wait for 100ns;
   
   tx_data<="01010101";
   data_valid<='1';
   wait for 20us;
   data_valid<='0';
   
   wait;
  end process;
 
end Behavioral;
