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
   
   led:out std_logic;
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
 --uart_rx define
 signal rx_rst    : std_logic := '0';
 signal rx_data   : std_logic_vector(7 downto 0);
 signal rx_parity : std_logic;
 signal rx_done   : std_logic;
 
 --ad7606 define
 signal ad_data_reg: std_logic_vector(15 downto 0);
 signal ad_valid:    std_logic;
 
signal test_data  : std_logic_vector(15 downto 0);
signal test_valid : std_logic;

signal cnt : integer range 0 to 50000000:=0;

signal led_reg : std_logic := '0';
signal rx_debug : std_logic;

begin
led<=rx_done;
 process(clk)
  begin
   if rising_edge(clk) then
    if(rx_done = '1')then
     led_reg<=not led_reg;
    end if;
   end if;
 end process;
 
 --uart_rx port
 u_uart_rx:entity work.uart_rx
  generic map(
  clk_freq=>50,
  baud_rate=>2000000,
  parity=>0,
  data_width=>8)
  port map(
   clk=>clk,
   rx_rst=>rx_rst,
   rx_debug=>rx_debug,
   rx=>uart_rx,
   rx_data=>rx_data,
   rx_parity=>rx_parity,
   rx_done=>rx_done);
   
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
   --data_in   =>test_data,
   --data_valid=>test_valid,
   tx        =>uart_tx);

end Behavioral;
