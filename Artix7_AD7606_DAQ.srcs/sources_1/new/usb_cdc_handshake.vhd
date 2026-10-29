----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2026/10/29 14:27:19
-- Design Name: 
-- Module Name: usb_cdc_handshake - Behavioral
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

entity usb_cdc_handshake is
--  Port ( );
 port(
  -- 50 MHz source domain
  src_clk     : in std_logic;
  src_rst     : in std_logic;
  src_valid   : in std_logic;
  src_data    : in std_logic_vector(7 downto 0);
  src_ready   : out std_logic;
  
  -- 60 MHz destination domain
  dst_clk     : in std_logic;
  dst_rst     : in std_logic;
  dst_ready   : in std_logic;
  dst_valid   : out std_logic;
  dst_data    : out std_logic_vector(7 downto 0));
  
end usb_cdc_handshake;

architecture Behavioral of usb_cdc_handshake is
 signal data_hold : std_logic_vector(7 downto 0) := (others=>'0');
 signal req       : std_logic := '0';
 signal ack       : std_logic := '0';
 signal req_sync1 : std_logic := '0';
 signal req_sync2 : std_logic := '0';
 signal ack_sync1 : std_logic := '0';
 signal ack_sync2 : std_logic := '0';
 
begin

 -- Source can submit a byte only when the previous byte is acknowledged.
 src_ready<='1' when req = ack_sync2 else '0';
 
 dst_data<=data_hold;
 dst_valid<='1' when req/= ack else '0';
 
 -- Synchronize request into 60 MHz domain
 process(dst_clk, dst_rst)
  begin
   if(dst_rst = '0')then
    req_sync1<='0';
    req_sync2<='0';
   elsif rising_edge(dst_clk) then
    req_sync1<=req;
    req_sync2<=req_sync1;
   end if;
  end process;
  
 -- Synchronize acknowledge into 50 MHz domain
 process(src_clk, src_rst)
  begin
   if(src_rst = '0')then
    ack_sync1<='0';
    ack_sync2<='0';
   elsif rising_edge(src_clk) then
    ack_sync1<=ack;
    ack_sync2<=ack_sync1;
   end if;
  end process;
  
 -- Source: hold data stable until acknowledge returns
 process(src_clk, src_rst)
  begin
   if(src_rst = '0')then
    data_hold<=(others=>'0');
    req<='0';
   elsif rising_edge(src_clk) then
    if(src_valid = '1' and req = ack_sync2)then
     data_hold<=src_data;
     req<=not req;
    end if;
   end if;
  end process;
   
 -- Destination: accept one byte, then wait until consumer is ready
 process(dst_clk, dst_rst)
  begin
   if(dst_rst = '0')then
    ack<='0';
   elsif rising_edge(dst_clk) then
    if(req_sync2 /= ack and dst_ready = '1')then
      ack<=req_sync2;
    end if;
   end if;
  end process;

end Behavioral;
