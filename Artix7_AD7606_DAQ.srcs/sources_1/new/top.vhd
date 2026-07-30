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
   clk               :in std_logic;
   led               :out std_logic;
   
   -- AD7606 interface
   ad_busy           :in std_logic;
   ad_frst           :in std_logic;
   ad_data           :in std_logic_vector(15 downto 0);
  
   ad_convstA        :out std_logic;
   ad_convstB        :out std_logic;
   ad_rst            :out std_logic;
   ad_cs             :out std_logic;
   ad_rd             :out std_logic;
   os                :out std_logic_vector(2 downto 0);
   ad_rage           :out std_logic;
   
   --UART interface
   uart_rx           :in std_logic;
   uart_tx           :out std_logic);
end top;

architecture Behavioral of top is
 signal rst       : std_logic;

 --uart_rx define
 signal rx_data   : std_logic_vector(7 downto 0);
 signal rx_parity : std_logic;
 signal rx_done   : std_logic;
 
 --ad7606 define
 signal ad_data_reg: std_logic_vector(15 downto 0);
 signal ad_valid:    std_logic;
 
 --fifo define
 signal ch_cnt    :integer range 0 to 7;
 signal fifo_din  :std_logic_vector(15 downto 0);
 signal fifo_wr_en:std_logic;
 signal fifo_dout :std_logic_vector(7 downto 0);
 signal fifo_full :std_logic;
 signal fifo_rd   :std_logic; 
 
 --uart_tx define
 signal tx_data_reg:std_logic_vector(7 downto 0);
 signal data_valid_seg:std_logic;
 
--led test
signal cnt : integer range 0 to 50000000:=0;
signal led_reg : std_logic := '0';

begin

 --poweron reset
 process(clk)
  begin 
   if rising_edge(clk) then
    if(cnt<50000000)then
     rst<='0';
     cnt<=cnt+1;
    else
     rst<='1';
    end if;
   end if;
  end process;
 
 --ad_data to fifo
 process(clk)
  begin
   if rising_edge (clk)then
    fifo_wr_en<='0';
    if(ad_valid = '1')then
     ch_cnt<=0;
    elsif(ch_cnt < 8)then 
     if(fifo_full = '0')then
      fifo_wr_en<='1';
      case ch_cnt is 
       when 0 =>
        fifo_din<=ad_ch1;
       when 1 =>
        fifo_din<=ad_ch2;
       when 2 =>
        fifo_din<=ad_ch3;
       when 3 =>
        fifo_din<=ad_ch4;
       when 4 =>
        fifo_din<=ad_ch5;
       when 5 =>
        fifo_din<=ad_ch6;
       when 6 =>
        fifo_din<=ad_ch7;
       when 7 =>
        fifo_din<=ad_ch8;
       when others =>
        fifo_din<=(others=>'0');
      end case;
     else
      ch_cnt<=ch_cnt+1;
     end if;
    end if;
   end if;
  end process;
 
 process(clk)
  begin
   if rising_edge(clk) then
    data_valid_seg<='0';
    if(rx_done='1') then
      tx_data_reg <= rx_data;
      data_valid_seg<= '1';
    end if;
   end if;
  end process;
  
 --uart_rx port
 u_uart_rx:entity work.uart_rx
  generic map(
  clk_freq=>50,
  baud_rate=>2000000,
  parity_on=>0,
  data_width=>8)
  port map(
   clk=>clk,
   rst=>rst,
   rx=>uart_rx,
   rx_data=>rx_data,
   rx_parity=>rx_parity,
   rx_done=>rx_done);
   
 u_ad7606_ctrl:entity work.ad7606_ctrl
 port map(
  clk       =>clk,
  ad_rst    =>ad_rst,
  busy      =>ad_busy,
  frst      =>ad_frst,
  data_in   =>ad_data,
  convstA   =>ad_convstA,
  convstB   =>ad_convstB,
  os        =>os,
  rd        =>ad_rd,
  rage      =>ad_rage,
  ad_cs     =>ad_cs,
  data_out  =>ad_data_reg,
  data_valid=>ad_valid);
  
 fifo_generator_0_inst:entity work.fifo_generator_0
 port map(
  clk=>clk,
  srst=>rst,
  din=>fifo_din,
  wr_en=>fifo_wr_en,
  rd_en=>fifo_rd_en,
  dout=>fifo_dout,
  full=>fifo_full,
  empty=>fifo_empty,
  almost_full=>open,
  almost_empty=>open);

 u_uart_tx:entity work.uart_tx
  generic map(
  clk_freq=>50,
  baud_rate=>2000000,
  parity_on=>0,
  data_width=>8)
  port map(
   clk       =>clk,
   rst       =>rst,
   tx_data   =>tx_data_reg,
   data_valid =>data_valid_seg,
   tx        =>uart_tx);

end Behavioral;
