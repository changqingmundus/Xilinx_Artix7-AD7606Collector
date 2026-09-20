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
use IEEE.NUMERIC_STD.ALL;

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
   clk            :in std_logic;
   led            :out std_logic;
   
   -- AD7606 interface
   ad_busy        :in std_logic;
   ad_frst        :in std_logic;
   ad_data        :in std_logic_vector(15 downto 0);
  
   ad_convstA     :out std_logic;
   ad_convstB     :out std_logic;
   ad_rst         :out std_logic;
   ad_cs          :out std_logic;
   ad_rd          :out std_logic;
   os             :out std_logic_vector(2 downto 0);
   ad_rage        :out std_logic;
   
   --UART interface
   uart_rx        :in std_logic;
   uart_tx        :out std_logic);
end top;

architecture Behavioral of top is
 signal rst       : std_logic;

 --uart_rx define
 signal rx_data   : std_logic_vector(7 downto 0);
 signal rx_parity : std_logic;
 signal rx_done   : std_logic;
 
 --uart_rx_cmd
 signal cmd_valid :std_logic;
 signal cmd_start :std_logic_vector(7 downto 0);
 signal cmd_count :std_logic_vector(7 downto 0);
 
 --ad7606 define
 signal ad_ch1    :std_logic_vector(15 downto 0);
 signal ad_ch2    :std_logic_vector(15 downto 0);
 signal ad_ch3    :std_logic_vector(15 downto 0);
 signal ad_ch4    :std_logic_vector(15 downto 0);
 signal ad_ch5    :std_logic_vector(15 downto 0);
 signal ad_ch6    :std_logic_vector(15 downto 0);
 signal ad_ch7    :std_logic_vector(15 downto 0);
 signal ad_ch8    :std_logic_vector(15 downto 0);
 signal ad_valid  :std_logic;
 
 --fifo define
 signal fifo_srst : std_logic;
 signal fifo_start:std_logic;
 signal ch_cnt    :integer range 0 to 7;
 signal fifo_rd_en:std_logic;
 signal fifo_din  :std_logic_vector(15 downto 0);
 signal fifo_wr_en:std_logic;
 signal fifo_empty:std_logic;
 signal fifo_dout :std_logic_vector(7 downto 0);
 signal fifo_full :std_logic;
 signal fifo_rd   :std_logic; 
 
 --signal processor define
 signal data_A      : std_logic_vector(15 downto 0);
 signal data_B      : std_logic_vector(15 downto 0);
 signal adc_valid   : std_logic;
 signal start       : std_logic;
 signal sample_cnt_set : std_logic_vector(15 downto 0);
 signal A_max_value : std_logic_vector(15 downto 0);
 signal A_min_value : std_logic_vector(15 downto 0);
 signal A_amplitude : std_logic_vector(15 downto 0);
 signal A_offset    : std_logic_vector(15 downto 0);
 signal B_max_value : std_logic_vector(15 downto 0);
 signal B_min_value : std_logic_vector(15 downto 0);
 signal B_amplitude : std_logic_vector(15 downto 0);
 signal B_offset    : std_logic_vector(15 downto 0);
 signal calcul_done : std_logic;
 
 --uart_tx define
 signal tx_active     :std_logic;
 signal tx_count      :std_logic_vector(7 downto 0);
 signal read_wait     : std_logic := '0';
 signal byte_sel      : std_logic := '0';
 signal tx_data_reg   : std_logic_vector(7 downto 0);
 signal data_valid_seg: std_logic;
 signal tx_busy       : std_logic;
 
--led test
signal cnt : integer range 0 to 50000000:=0;
signal led_reg : std_logic := '0';

begin
 fifo_srst <= not rst;
 
 os<="000";
 ad_rage<='0';
 
 --poweron reset
 process(clk)
  begin 
   if rising_edge(clk) then
    if(cnt<100)then
    --if(cnt<50000000)then
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
     fifo_start<='1';
     ch_cnt<=0;
    elsif(fifo_start='1')then
     if(fifo_full = '0')then
      fifo_wr_en<='1';
       if(ch_cnt=7) then
        ch_cnt<=0;
        fifo_start<='0';
       else
        ch_cnt<=ch_cnt+1;
       end if;
     end if;
    end if;
   end if;
 end process;
 
 process(ch_cnt)
  begin
   case ch_cnt is 
    when 0 =>
     fifo_din<=x"1001";
    when 1 =>
     fifo_din<=x"2002";
    when 2 =>
     fifo_din<=x"3003";
    when 3 =>
     fifo_din<=x"4004";
    when 4 =>
     fifo_din<=x"5005";
    when 5 =>
     fifo_din<=x"6006";
    when 6 =>
     fifo_din<=x"7007";
    when 7 =>
     fifo_din<=x"8008";
    when others =>
     fifo_din<=(others=>'0');
   end case;
 end process;
     
 --fifo to uart_tx
 process(clk)
  begin
   if rising_edge(clk) then
    fifo_rd_en<= '0';
    data_valid_seg <= '0';
    if(cmd_valid = '1')then
     tx_active<='1';
     tx_count <= std_logic_vector(to_unsigned(to_integer(unsigned(cmd_count)) * 2, tx_count'length));
     read_wait<='0';
    elsif(tx_active = '1')then
     if(tx_busy='0' and fifo_empty='0') then
      if(read_wait = '0')then
       fifo_rd_en<= '1';
       read_wait<= '1';
      else
       tx_data_reg<=fifo_dout;
       data_valid_seg<= '1';
       read_wait<='0';
       if(tx_count = 1)then
        tx_count<=(others=>'0');
        tx_active<='0';
       else 
        tx_count<=tx_count - 1;
       end if;
      end if;
     end if;
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
  
 --uart_rx_cmd port
 uart_cmd_parser:entity work.uart_cmd_parser
 port map(
  clk       =>clk,
  rst       =>rst,
  rx_data   =>rx_data,
  --rx_valid  =>rx_valid,
  rx_valid  =>rx_done,
  cmd_valid =>cmd_valid,
  cmd_start =>cmd_start,
  cmd_count =>cmd_count);
 
 --ad7606 port 
 u_ad7606_ctrl:entity work.ad7606_ctrl
 port map(
  clk       =>clk,
  rst       =>rst,
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
  ad_ch1    =>ad_ch1,
  ad_ch2    =>ad_ch2,
  ad_ch3    =>ad_ch3,
  ad_ch4    =>ad_ch4,
  ad_ch5    =>ad_ch5,
  ad_ch6    =>ad_ch6,
  ad_ch7    =>ad_ch7,
  ad_ch8    =>ad_ch8,
  data_valid=>ad_valid);
  
 fifo_generator_0_inst:entity work.fifo_generator_0
 port map(
  clk=>clk,
  srst=>fifo_srst,
  din=>fifo_din,
  wr_en=>fifo_wr_en,
  rd_en=>fifo_rd_en,
  dout=>fifo_dout,
  full=>fifo_full,
  empty=>fifo_empty,
  almost_full=>open,
  almost_empty=>open);
  
 u_signal_processor:entity work.signal_processor
  port map(
   clk    =>clk,
   rst    =>rst,
   data_A=>data_A,
   data_B=>data_B,
   adc_valid=>adc_valid,
   start=>start,
   sample_cnt_set=>sample_cnt_set,
   A_max_value=>A_max_value,
   A_min_value=>A_min_value,
   A_amplitude=>A_amplitude,
   A_offset=>A_offset,
   B_max_value=>B_max_value,
   B_min_value=>B_min_value,
   B_amplitude=>B_amplitude,
   B_offset=>B_offset,
   calcul_done=>calcul_done);

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
   data_valid=>data_valid_seg,
   tx_busy   =>tx_busy,
   tx        =>uart_tx);

end Behavioral;
