----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2026 14:53:56
-- Design Name: 
-- Module Name: signal_processor - Behavioral
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

entity signal_processor is
--  Port ( );
 port(
    clk             : in std_logic;
    rst             : in std_logic;

    data_A          : in std_logic_vector(15 downto 0);
    data_B          : in std_logic_vector(15 downto 0);

    adc_valid       : in std_logic;

    start           : in std_logic;
    sample_cnt_set  : in std_logic_vector(15 downto 0);


    A_max_value     : out std_logic_vector(15 downto 0);
    A_min_value     : out std_logic_vector(15 downto 0);
    A_amplitude     : out std_logic_vector(15 downto 0);
    A_offset        : out std_logic_vector(15 downto 0);


    B_max_value     : out std_logic_vector(15 downto 0);
    B_min_value     : out std_logic_vector(15 downto 0);
    B_amplitude     : out std_logic_vector(15 downto 0);
    B_offset        : out std_logic_vector(15 downto 0);


    calcul_done     : out std_logic);
end signal_processor;

architecture Behavioral of signal_processor is
 signal A_max_reg:std_logic_vector(15 downto 0);
 signal A_min_reg:std_logic_vector(15 downto 0);
 
 signal B_max_reg:std_logic_vector(15 downto 0);
 signal B_min_reg:std_logic_vector(15 downto 0);
 
 signal A_sum_reg:std_logic_vector(31 downto 0);
 signal B_sum_reg:std_logic_vector(31 downto 0);
 
 signal sample_cnt:std_logic_vector(15 downto 0);
 
 type state_type is(
  IDLE,
  SAMPLE,
  CALCULATE,
  DONE);
 signal state:state_type:=IDLE;
begin
 process(clk,rst)
  begin
   if rising_edge(clk)then
    if(rst = '0')then
     state<=IDLE;
    else
     case state is
      when IDLE =>
       if(start = '1')then
        A_max_reg<=(others=>'0');
        B_max_reg<=(others=>'0');
        
        A_min_reg<=(others=>'0');
        B_min_reg<=(others=>'0');
        
        A_sum_reg<=(others=>'0');
        B_sum_reg<=(others=>'0');
        
        state<=SAMPLE;
       end if;
      when SAMPLE =>
        if(adc_valid = '1')then
         if(data_A > A_max_reg)then
          A_max_reg<=data_A;
         end if;
         if(data_A < A_min_reg)then
          A_min_reg<=data_A;
         end if;
         A_sum_reg<=A_sum_reg+data_A;
         sample_cnt<=sample_cnt+1;
        if(sample_cnt = sample_cnt_set - 1)then
         state<=CALCULATE;
        end if;
       end if;
      when others =>
       null;
    end case;
   end if;
  end if;
 end process;

end Behavioral;
