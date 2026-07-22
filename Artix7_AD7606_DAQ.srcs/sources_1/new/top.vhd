----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2026 22:39:51
-- Design Name: 
-- Module Name: top - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
--  Port ( );
 port(
   --FPGA clock
   clk:in std_logic;
   
   -- AD7606 interface
   ad_busy:  in std_logic;
   ad_data:  in std_logic_vector(15 downto 0);
   ad_convst:out std_logic;
   ad_rd:    out std_logic;
   ad_cs:    out std_logic;
   
   --UART interface
   uart_rx:  in std_logic;
   uart_tx:  out std_logic);
end top;

architecture Behavioral of top is
 signal ad_data_reg: std_logic_vector(15 downto 0);
 signal ad_valid:    std_logic;

begin
 u_ad7606_ctrl:entity work.ad7606_ctrl
 port map(
  clk       =>clk,
  busy      =>ad_busy,
  data_in   =>ad_data,
  convst    =>ad_convst,
  rd        =>ad_rd,
  cs        =>ad_cs,
  data_out  =>ad_data_reg,
  data_valid=>ad_valid);

 u_uart_tx:entity work.uart_tx
  port map(
   clk       =>clk,
   data_in   =>ad_data_reg,
   data_valid=>ad_valid,
   tx        =>uart_tx,
   rx        =>uart_rx);

end Behavioral;
