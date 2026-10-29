----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.10.2026 22:31:48
-- Design Name: 
-- Module Name: ft232h_control - Behavioral
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

entity ft232h_control is
--  Port ( );
 port(clkout         : in std_logic;
      rst            : in std_logic;
      rxf            : in std_logic;
      txe            : in std_logic;
      
      data_rd_en     : in std_logic;
      data_wr_en     : in std_logic;
      ft232h_data_in : in std_logic_vector(7 downto 0);
       
      rd_length      : in unsigned(15 downto 0);
      wr_length      : in unsigned(15 downto 0);
      
      rd_s_done      : out std_logic;
      wr_s_done      : out std_logic;
      
      rd             : out std_logic;
      wr             : out std_logic;
      oe             : out std_logic;
      
      ft232h_data_out: out std_logic_vector(7 downto 0);
      data           : inout std_logic_vector(7 downto 0);
      
      -- USB CDC handshake
      usb_data_valid : in std_logic;
      usb_data       : in std_logic_vector(7 downto 0);
      usb_data_ready : out std_logic);
end ft232h_control;

architecture Behavioral of ft232h_control is

 type ft232h_state_type is(STATE_IDLE,
                           STATE_READ,
                           STATE_READ_START,
                           STATE_READ_DATA,
                           STATE_WRITE_START,
                           STATE_WRITE_DATA,
                           STATE_END);
 signal state : ft232h_state_type := STATE_IDLE;
 signal rd_cnt: unsigned(15 downto 0);
 signal wr_cnt: unsigned(15 downto 0);
 
 signal usb_write_active   : std_logic := '0';
 signal usb_data_ready_reg : std_logic := '0';
 
begin

 usb_data_ready <= usb_data_ready_reg;

 -- Select the data source for the FT232H bus.
 data <= usb_data when
        state = STATE_WRITE_DATA and usb_write_active = '1'
        --else ft232h_data_in when state = STATE_WRITE_DATA
        else (others => 'Z');
 
 process(clkout,rst)
  begin
  if(rst = '0')then
   rd<='1';
   wr<='1';
   oe<='1';
   rd_s_done<='0';
   wr_s_done<='0';
  elsif(clkout'event and clkout = '1')then
   rd_s_done<='0';
   wr_s_done<='0';
   usb_data_ready_reg<='0';
   case state is
   
    when STATE_IDLE =>
     if(data_rd_en = '1' and rxf = '0')then
      state<=STATE_READ;
     elsif(usb_data_valid = '1' and txe = '0')then
      usb_write_active<='1';
      state<=STATE_WRITE_DATA;
     end if;
     
    when STATE_READ =>
     oe<='0';
     rd_cnt<=(others=>'0');
     state<=STATE_READ_START;
     
    when STATE_READ_START =>
     rd<='0';
     state<=STATE_READ_DATA;
     
    when STATE_READ_DATA =>
     if(rxf = '1')then
      state<=STATE_END;
     elsif(rd_cnt = rd_length)then
      state<=STATE_END;
     else
      ft232h_data_out<=data;
      rd_s_done<='1';
      rd_cnt<=rd_cnt+1;
     end if;
     
    when STATE_WRITE_START =>
     wr<='1';
     wr_cnt<=(others=>'0');
     state<=STATE_WRITE_DATA;
   
    when STATE_WRITE_DATA =>
     wr<='0';
     --if (txe = '0') then
      state<=STATE_END;
      --if (wr_cnt = wr_length) then
       if(usb_write_active = '1')then
        usb_data_ready_reg<='1';
      --else
       --wr_s_done<='1';
       --wr_cnt<=wr_cnt + 1;
      --end if;
       --end if;
     --else
       state<=STATE_END;
     end if;
     
    when STATE_END =>
     rd<='1';
     wr<='1';
     oe<='1';
     state<=STATE_IDLE;
     
    when others =>
     state<=STATE_IDLE;
     
   end case;
  end if;
 end process;

end Behavioral;
