----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.10.2026 20:26:19
-- Design Name: 
-- Module Name: ft232h_control_tb - Behavioral
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

entity ft232h_control_tb is
--  Port ( );
end ft232h_control_tb;

architecture Behavioral of ft232h_control_tb is
 signal clkout  : std_logic := '0';
 signal rst     : std_logic := '0';
 signal rxf     : std_logic := '1';
 signal txe     : std_logic := '1';
      
 signal ft232h_data_in : std_logic_vector(7 downto 0) := x"00";
       
 signal rd_length: unsigned(15 downto 0) := to_unsigned(1, 16);
 signal wr_length: unsigned(15 downto 0) := to_unsigned(1, 16);
      
 signal rd      : std_logic := '1';
 signal wr      : std_logic := '1';
 signal oe      : std_logic := '1';
      
 signal ft232h_data_out : std_logic_vector(7 downto 0) := (others => '0');
 signal data    : std_logic_vector(7 downto 0) := (others => 'Z');
begin
  -- 60 MHz clock: period = 16.667 ns
    clk_process : process
    begin
        clkout <= '0';
        wait for 8.333 ns;
        clkout <= '1';
        wait for 8.334 ns;
    end process;

    -- Device Under Test
    uut : entity work.ft232h_control
        port map (
            clkout          => clkout,
            rst             => rst,
            rxf              => rxf,
            txe              => txe,
            ft232h_data_in  => ft232h_data_in,
            rd_length        => rd_length,
            wr_length        => wr_length,
            rd               => rd,
            wr               => wr,
            oe               => oe,
            ft232h_data_out => ft232h_data_out,
            data             => data
        );

    -- Simulate FT232H driving the bus during FPGA read
    data <= x"A5" when oe = '0' and rd = '0'
            else (others => 'Z');

    stimulus : process
    begin

        -- Reset
        rst <= '0';
        wait for 500 ns;
        rst <= '1';
        wait for 50 ns;

        -- Test 1: FT232H has data for FPGA to read
        rxf <= '0';
        wait for 100 ns;
        rxf <= '1';
        wait for 100 ns;

        -- Test 2: FT232H can accept data from FPGA
        txe <= '0';
        ft232h_data_in <= x"3C";
        wait for 100 ns;
        txe <= '1';
        wait for 100 ns;

        -- End simulation
        wait;
    end process;


end Behavioral;
