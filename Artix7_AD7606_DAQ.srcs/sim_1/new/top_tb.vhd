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
 signal clk        :std_logic :='0';
 
 signal ad_busy : std_logic := '0';
 signal ad_frst : std_logic := '0';
 signal ad_data : std_logic_vector(15 downto 0);
 signal ad_convstA : std_logic;
 signal ad_convstB : std_logic;
 signal ad_rst : std_logic;
 signal ad_cs : std_logic;
 signal ad_rd : std_logic;
 signal os : std_logic_vector(2 downto 0);
 signal ad_rage : std_logic;
 
 signal uart_rx : std_logic := '1';
 signal uart_tx : std_logic;
 
 constant CLK_PERIOD: time:=20ns;
begin
 clk<=not clk after CLK_PERIOD/2;
 
 uut:entity work.top
 port map(
  clk=>clk,
  ad_rst=>ad_rst,
  ad_busy=>ad_busy,
  ad_convstA=>ad_convstA,
  ad_convstB=>ad_convstB,
  ad_frst=>ad_frst,
  ad_data=>ad_data,
  ad_cs => ad_cs,
  ad_rd => ad_rd,
  os => os,
  ad_rage => ad_rage,
  uart_rx=>uart_rx,
  uart_tx=>uart_tx);
 process
  begin
   ad_busy<='0';
   ad_data<=x"0000";
   wait for 1us;
   
   wait until ad_convstA='0';
   
   ad_busy<='1';
   wait for 5us;
   ad_busy<='0';
   
   wait until ad_rd='0';
   ad_data<=x"1011";
   
   wait until ad_rd='0';
   ad_data<=x"1022";
   
   wait until ad_rd='0';
   ad_data<=x"1033";
   
   wait until ad_rd='0';
   ad_data<=x"1044";
   
   wait until ad_rd='0';
   ad_data<=x"1055";
   
   wait until ad_rd='0';
   ad_data<=x"1066";
   
   wait until ad_rd='0';
   ad_data<=x"1077";
   
   wait until ad_rd='0';
   ad_data<=x"1088";
  wait;
 end process;
end Behavioral;
