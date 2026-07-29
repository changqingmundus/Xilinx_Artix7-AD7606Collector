----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2026 22:40:19
-- Design Name: 
-- Module Name: ad7606_ctrl - Behavioral
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

entity ad7606_ctrl is
--  Port ( );
 port(
  clk               :in std_logic;
  rst               :in std_logic;
  
  busy              :in std_logic;
  frst              :in std_logic;
  data_in           :in std_logic_vector(15 downto 0);
  
  convstA,convstB   :out std_logic;
  ad_rst            :out std_logic;
  ad_cs             :out std_logic;
  rd                :out std_logic;
  os                :out std_logic_vector(2 downto 0);
  rage              :out std_logic;
  
  data_out          :out std_logic_vector(15 downto 0);
  data_valid        :out std_logic);
  
end ad7606_ctrl;

architecture Behavioral of ad7606_ctrl is
 signal ad_ch1 : std_logic_vector(15 downto 0);
 signal ad_ch2 : std_logic_vector(15 downto 0);
 signal ad_ch3 : std_logic_vector(15 downto 0);
 signal ad_ch4 : std_logic_vector(15 downto 0);
 signal ad_ch5 : std_logic_vector(15 downto 0);
 signal ad_ch6 : std_logic_vector(15 downto 0);
 signal ad_ch7 : std_logic_vector(15 downto 0);
 signal ad_ch8 : std_logic_vector(15 downto 0);

 signal channel_cnt : integer range 0 to 7;

 type state_type is(
  AD_RESET,
  IDLE,
  CONV,
  WAIT_BUSY_LOW,
  READ_DATA,
  READ_DONE);
  
 signal state  :state_type:=AD_RESET;
 signal cnt    :integer range 0 to 100:=0;
 signal i      :integer range 0 to 1000:=0;
 signal cnt50us:integer range 0 to 2500:=0;
begin
 process(clk,rst)
  begin
   if(rst = '0')then
    cnt50us<=0;
    elsif rising_edge(clk) then
     if(cnt50us<2499)then
      cnt50us<=cnt50us+1;
     else
      cnt50us<=0;
     end if;
    end if;
   end process;

 process(clk)
  begin
   if (clk'event and clk='1') then
    case state is
    
    when AD_RESET =>
     ad_rst<='1';
     if(i = 255)then
      i<=0;
      ad_rst<='0';
      state<=IDLE;
     else
      i<=i+1;
     end if;
     
    when IDLE =>
      convstA <= '1';
      convstB <= '1';
      rd <= '1';
      ad_cs <= '1';
      data_valid <= '0';
      if(cnt = 20)then
       cnt<=0;
       state <= CONV;
      else
       cnt<=cnt+1;
      end if;
    -- 產生CONVST脈衝
    when CONV =>
     if(cnt = 2)then
      cnt<=0;
      state<=WAIT_BUSY_LOW;
      convstA <= '1';
      convstB <= '1';
     else 
      cnt<=cnt+1;
      convstA <= '0';
      convstB <= '0';
     end if;

    -- 等轉換完成
    when WAIT_BUSY_LOW =>
     if(busy='0')then
      state <= READ_DATA;
     end if;
        
    -- 讀數據
    when READ_DATA =>
     ad_cs<='0';
     if(cnt = 3)then
      rd<='1';
      cnt<=0;
      case channel_cnt is
       when 0 =>
        ad_ch1<=data_in;
       when 1 =>
        ad_ch2<=data_in;
       when 2 =>
        ad_ch3<=data_in;
       when 3 =>
        ad_ch4<=data_in;
       when 4 =>
        ad_ch5<=data_in;
       when 5 =>
        ad_ch6<=data_in;
       when 6 =>
        ad_ch7<=data_in;
       when 7 =>
        ad_ch8<=data_in;
       when others =>
        null;
      end case;
      if(channel_cnt = 7)then
       channel_cnt<=0;
       state<=READ_DONE;
      else
       channel_cnt<=channel_cnt+1;
      end if;
     else
      rd<='0';
      cnt<=cnt+1;
     end if;
      
    when READ_DONE =>
     ad_cs<='1';
     rd<='1';
     if(cnt50us = 2499)then
      state<=IDLE;
     else
      state<=READ_DONE;
      data_valid<='1';
     end if;
    end case;
  end if;
 end process;

end Behavioral;
