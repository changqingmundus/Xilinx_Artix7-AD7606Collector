----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.07.2026 18:09:04
-- Design Name: 
-- Module Name: uart_rx_tb - Behavioral
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

entity uart_rx_tb is
--  Port ( );
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is
 signal clk:std_logic :='0';
 signal rx_rst:std_logic :='0';
 signal uart_rx:std_logic:='0';
 signal rx_data:std_logic_vector(7 downto 0);
 signal rx_parity:std_logic;
 signal rx_done:std_logic;
 
 constant CLK_PERIOD : time:=20ns; --50MHz
begin
 CLK<=not CLK after CLK_PERIOD/2;
 
 uut:entity work.uart_rx
 generic map(
  clk_freq=>50,
  baud_rate=>2000000,
  parity=>0,
  data_width=>8)
 port map(
  clk=>clk,
  rx_rst=>rx_rst,
  rx=>uart_rx,
  rx_data=>rx_data,
  rx_parity=>rx_parity,
  rx_done=>rx_done);
  
 process
  constant BIT_TIME:time:=500 ns; --2M
   begin
    
    --reset
    rx_rst<='0';
    wait for 200ns;
    
    --release reset
    rx_rst<='1';
    
    --UART IDLE
    uart_rx<='1';
    wait for 1000ns;
    
    --send 0x55
    -- UART:8N1
    
    --startt bit
    uart_rx<='0';
    wait for BIT_TIME;
    
    --bit0  --1
    uart_rx<='1';
    wait for BIT_TIME;
    
    --bit1  --0
    uart_rx<='0';
    wait for BIT_TIME;
    
    --bit2  --1
    uart_rx<='1';
    wait for BIT_TIME;
    
    --bit3  --0
    uart_rx<='0';
    wait for BIT_TIME;
    
    --bit4  --1
    uart_rx<='1';
    wait for BIT_TIME;
    
    --bit5  --0
    uart_rx<='0';
    wait for BIT_TIME;
    
    --bit6  --1
    uart_rx<='1';
    wait for BIT_TIME;
    
    --bit7  --0
    uart_rx<='0';
    wait for BIT_TIME;
    
    --stop bit
    uart_rx<='1';
    wait for BIT_TIME;
    
    uart_rx<='0';
    wait for BIT_TIME;
    
    wait;
   end process;
end Behavioral;
