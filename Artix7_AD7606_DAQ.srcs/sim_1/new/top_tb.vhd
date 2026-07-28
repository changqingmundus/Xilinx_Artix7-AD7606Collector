----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2026/07/28 09:28:51
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is
 signal clk:std_logic :='0';
 signal rst:std_logic :='0';
 signal uart_rx:std_logic:='1';
 signal uart_tx:std_logic;
 signal data_valid:std_logic := '0';
 signal rx_data   : std_logic_vector(7 downto 0);
 signal tx_data_reg:std_logic_vector(7 downto 0);
 
 constant CLK_PERIOD: time:=20ns;
 constant BIT_TIME: time:=500ns; --2Mbps
begin
 clk<=not clk after CLK_PERIOD/2;
 
 uut:entity work.top
 port map(
  clk=>clk,
  rst=>rst,
  ad_busy=>'0',
  ad_frst=>'0',
  ad_data=>(others=>'0'),
  uart_rx=>uart_rx,
  uart_tx=>uart_tx);
 process
  begin
   rst<='0';
   wait for 200ns;
   
   rst<='1';
   wait for 200ns;
   
   uart_rx<='1';
   wait for BIT_TIME;
   
   uart_rx<='0';
   wait for BIT_TIME;
   
   uart_rx <= '1';
   wait for BIT_TIME;
   uart_rx <= '0';
   wait for BIT_TIME;
   uart_rx <= '1';
   wait for BIT_TIME;
   uart_rx <= '0';
   wait for BIT_TIME;
   uart_rx <= '1';
   wait for BIT_TIME;
   uart_rx <= '0';
   wait for BIT_TIME;
   uart_rx <= '1';
   wait for BIT_TIME;
   uart_rx <= '0';
   wait for BIT_TIME;
   
   uart_rx<='1';
   wait for BIT_TIME;
  
  wait;
 end process;
end Behavioral;
