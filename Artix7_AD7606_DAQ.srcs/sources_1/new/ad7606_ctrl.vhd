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
  
  busy              :in std_logic;
  frst              :in std_logic;
  data_in           :in std_logic_vector(15 downto 0);
  
  convstA,convstB   :out std_logic;
  ad_rst            :out std_logic;
  ad_cs             :out std_logic;
  rd                :out std_logic;
  os0,os1,os2       :out std_logic;
  rage              :out std_logic;
  
  data_out          :out std_logic_vector(15 downto 0);
  data_valid        :out std_logic);
  
end ad7606_ctrl;

architecture Behavioral of ad7606_ctrl is

 type state_type is(
  IDLE,
  CONV,
  WAIT_BUSY_HIGH,
  WAIT_BUSY_LOW,
  READ_DATA);
 signal state:state_type:=IDLE;
 signal cnt:integer range 0 to 100:=0;
begin
 process(clk)
  begin
   if (clk'event and clk='1') then
    case state is
    when IDLE =>
        convstA <= '1';
        rd <= '1';
        ad_cs <= '1';
        data_valid <= '0';
        cnt <= 0;
        state <= CONV;
    -- 產生CONVST脈衝
    when CONV =>
        convstA <= '0';
        if cnt = 5 then
            cnt <= 0;
            state <= WAIT_BUSY_HIGH;
        else
            cnt <= cnt + 1;
        end if;

    -- 等BUSY變高
    when WAIT_BUSY_HIGH =>
        convstA <= '1';
        if busy='1' then
            state <= WAIT_BUSY_LOW;
        end if;
    -- 等轉換完成
    when WAIT_BUSY_LOW =>
        if busy='0' then
            state <= READ_DATA;
        end if;
    -- 讀數據
    when READ_DATA =>
        ad_cs <= '0';
        rd <= '0';
        data_out <= data_in;
        data_valid <= '1';
        state <= IDLE;
    end case;
  end if;
 end process;

end Behavioral;
