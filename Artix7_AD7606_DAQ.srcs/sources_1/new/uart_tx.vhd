----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.07.2026 20:17:02
-- Design Name: 
-- Module Name: uart_rx - Behavioral
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

entity uart_tx is
 generic(clk_freq:integer := 50;
         baud_rate:integer :=2000000;
         parity_on:integer := 0;
         parity_type:integer :=0;
         data_width:integer := 8);
--  Port ( );
 port(clk:in std_logic;
      rst:in std_logic;
      tx_data:in std_logic_vector((data_width - 1) downto 0);
      data_valid:in std_logic;
      tx_busy:out std_logic;
      tx:out std_logic);
end uart_tx;

architecture Behavioral of uart_tx is
 --out buffer
 signal rx_parity_reg:std_logic :='0';

 --狀態機定義
 type state_type is(STATE_IDLE,
                    STATE_START,
                    STATE_DATA,
                    STATE_PARITY,
                    STATE_END);
 signal r_current_state:state_type:=STATE_IDLE;
 signal r_next_state   :state_type:=STATE_IDLE;
 
 --時鐘計數周期
 constant CYCLE: integer := clk_freq * 1000000 / baud_rate;
 
 --波特率計數定義
 signal baud_valid:std_logic;                      --波特率計數有效位
 signal baud_cnt  :std_logic_vector(15 downto 0);  --波特率計數器
 signal baud_pulse:std_logic;                      --波特率采樣脈衝
 
 --接收數據計數定義
 signal r_tx_cnt :std_logic_vector(3 downto 0);   --接收數據位計數
 
 --接收數據校驗定義
 signal r_data_tx:std_logic_vector((data_width -1) downto 0);
 signal r_parity_check:std_logic;
begin
  
 --波特率計數器實現
 process(clk,rst)
  begin
   if(rst = '0')then
    baud_cnt<=(others=>'0');
   elsif(clk'event and clk='1')then
    if(baud_valid = '0')then
     baud_cnt<=(others=>'0');
    elsif(baud_cnt = CYCLE -1)then
     baud_cnt<=(others=>'0');
    else
     baud_cnt<=baud_cnt+1;
    end if;
   end if;
  end process;  

 --波特率采樣脈衝實現
 process(clk,rst)
  begin
   if(rst = '0')then
    baud_pulse<='0';
   elsif(clk'event and clk='1')then
    if(baud_cnt = CYCLE/2-1)then
     baud_pulse<='1';
    else
     baud_pulse<='0';
    end if;
   end if;
  end process;

 --狀態機狀態變化定義
 process(clk,rst)
  begin
   if(rst = '0')then
    r_current_state<=STATE_IDLE;
   elsif(clk'event and clk='1')then
    if(baud_valid = '0')then
     r_current_state<=STATE_IDLE;
     elsif(baud_valid = '1')then
      if(baud_cnt = 0)then
       r_current_state<=r_next_state;
      end if;
    end if;
   end if;
  end process;
 
 --狀態機次態定義
 process(r_current_state, r_tx_cnt)
  begin
   case r_current_state is
    when STATE_IDLE=>
     r_next_state<=STATE_START;
    when STATE_START=>
     r_next_state<=STATE_DATA;
    when STATE_DATA=>
     if(r_tx_cnt = data_width)then
       if(parity_on = 0)then
        r_next_state<=STATE_END;
       else
        r_next_state<=STATE_PARITY;  --校驗位開啓時進入校驗狀態
       end if;
      else
        r_next_state<=STATE_DATA;
      end if;
    when STATE_PARITY=>
     r_next_state<=STATE_END;
    when STATE_END=>
     r_next_state<=STATE_IDLE;
    when others=>
     r_next_state<=STATE_IDLE;
    end case;
   end process;
   
 --狀態機輸出邏輯實現
 process(clk,rst)
  begin
   if(rst = '0')then
    baud_valid<='0';
    r_tx_cnt<=(others=>'0');
    r_data_tx<=(others=>'0');
    r_parity_check<='0';
    tx_busy<='0';
    tx<='0';
   elsif(clk'event and clk='1')then
    case r_current_state is
     when STATE_IDLE=>
      r_tx_cnt<=(others=>'0');
      tx<='1';
      r_parity_check<='0';
      if(data_valid = '1')then
       tx_busy<='1';
       baud_valid<='1';
       r_data_tx<=tx_data;
      end if;
     when STATE_START=>
      if(baud_pulse = '1')then
       tx<='0';
      end if;
     when STATE_DATA=>
      if(baud_pulse='1') then
        tx<=r_data_tx(0);
        r_tx_cnt<=r_tx_cnt+1;
        r_parity_check<=r_parity_check xor r_data_tx(0);
        r_data_tx<='0'&(r_data_tx(DATA_WIDTH-1 downto 1));
      end if;
     when STATE_PARITY=>
      if(baud_pulse = '1')then
       if(parity_type = 1)then 
        tx <=not r_parity_check;
        else
         tx<=r_parity_check;
       end if;
      end if;
     when STATE_END=>
      if(baud_pulse = '1')then
       tx<='1';
       tx_busy<='0';
       baud_valid<='0';
      end if;
     end case;
    end if;
   end process;
end Behavioral;
